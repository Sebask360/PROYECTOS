# ==============================================================================
# VERIFICACIÓN DE PRIVILEGIOS DE ADMINISTRADOR (UAC)
# ==============================================================================
$identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object System.Security.Principal.WindowsPrincipal($identity)
if (-not $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
    [System.Windows.Forms.MessageBox]::Show(
        "Este script requiere permisos de Administrador para instalar software y gestionar usuarios localmente. Por favor, ejecútalo como Administrador.",
        "Acceso Denegado",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Warning
    ) | Out-Null
    Exit
}

Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase, System.Windows.Forms

# ==============================================================================
# 0. CONFIGURACIONES GLOBALES Y RED
# ==============================================================================
# Forzar TLS 1.2 / 1.3 e ignorar restricciones SSL para red local
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13
[Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}

# ==============================================================================
# 1. FUNCIONES AUXILIARES Y DE NEGOCIO
# ==============================================================================

# Función para forzar el refresco de eventos de la GUI sin congelar la ventana
function Update-UI {
    [System.Windows.Threading.Dispatcher]::CurrentDispatcher.Invoke(
        [System.Action]{}, 
        [System.Windows.Threading.DispatcherPriority]::Background
    )
}

# Función dinámica para inyectar el XML corporativo de SAP
function Set-SAPLandscapePopsy {
    param ([bool]$IncludePRD, [bool]$IncludeQA, [bool]$IncludeDEV)

    $landscapeDir = "$env:APPDATA\SAP\Common"
    $xmlPath      = "$landscapeDir\SAPUILandscape.xml"

    if (-not (Test-Path $landscapeDir)) { New-Item -ItemType Directory -Path $landscapeDir -Force | Out-Null }

    $xmlItems    = ""
    $xmlServices = ""
    $xmlRouters  = ""
    $needRouter1 = $false
    $needRouter2 = $false

    if ($IncludePRD) {
        $xmlItems    += "      <Item uuid=`"8a362934-12df-404c-bbcb-3bd12f711e42`" serviceid=`"a7ae92ec-e4bd-4e44-acf1-7d778e091c39`"/>`n"
        $xmlServices += "    <Service type=`"SAPGUI`" uuid=`"a7ae92ec-e4bd-4e44-acf1-7d778e091c39`" name=`"POPSY PRD`" systemid=`"P4P`" mode=`"1`" server=`"10.0.0.5:3200`" routerid=`"0b893123-f1ba-4cef-902d-6b3537829aef`" sncop=`"-1`" dcpg=`"2`"/>`n"
        $needRouter1 = $true
    }
    if ($IncludeQA) {
        $xmlItems    += "      <Item uuid=`"8e3e4589-37fb-4578-af44-f166e36fb58a`" serviceid=`"91d83f3d-df2b-4717-a025-a1ad35a9b668`"/>`n"
        $xmlServices += "    <Service type=`"SAPGUI`" uuid=`"91d83f3d-df2b-4717-a025-a1ad35a9b668`" name=`"POPSY QA`" systemid=`"P4Q`" mode=`"1`" server=`"10.0.0.3:3202`" routerid=`"8aeed703-b3da-460c-83ba-fb5cd1ed35e3`" sncop=`"-1`" dcpg=`"2`"/>`n"
        $needRouter2 = $true
    }
    if ($IncludeDEV) {
        $xmlItems    += "      <Item uuid=`"856ffcc8-413b-4466-82c6-e42186bbc00a`" serviceid=`"bb08a6cd-1897-46f4-9b05-664c073366a5`"/>`n"
        $xmlServices += "    <Service type=`"SAPGUI`" uuid=`"bb08a6cd-1897-46f4-9b05-664c073366a5`" name=`"POPSY DESARROLLO`" systemid=`"P4D`" mode=`"1`" server=`"10.0.0.3:3200`" routerid=`"0b893123-f1ba-4cef-902d-6b3537829aef`" sncop=`"-1`" dcpg=`"2`"/>`n"
        $needRouter1 = $true
    }

    if ($needRouter1) { $xmlRouters += "    <Router uuid=`"0b893123-f1ba-4cef-902d-6b3537829aef`" name=`"/H/200.91.193.73`" description=`"/H/200.91.193.73`" router=`"/H/200.91.193.73`"/>`n" }
    if ($needRouter2) { $xmlRouters += "    <Router uuid=`"8aeed703-b3da-460c-83ba-fb5cd1ed35e3`" name=`"/H/200.91.193.73|`" description=`"/H/200.91.193.73|`" router=`"/H/200.91.193.73|`"/>`n" }

    $xmlItems = $xmlItems.TrimEnd("`n"); $xmlRouters = $xmlRouters.TrimEnd("`n"); $xmlServices = $xmlServices.TrimEnd("`n")

    $landscapeContent = @"
<?xml version="1.0" encoding="UTF-8"?>
<Landscape updated="$((Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ"))" version="1" generator="SAP GUI for Windows v8000.1.15.155">
  <Workspaces><Workspace uuid="9a7bc45a-12fe-4bf6-bb32-29e67c6479e3" name="Local">
$xmlItems
  </Workspace></Workspaces>
  <Routers>$xmlRouters</Routers>
  <Services>$xmlServices</Services>
  <Includes><Include url="file:///$env:APPDATA/SAP/Common/SAPUILandscapeGlobal.xml" index="0" description="SAP Reserved"/></Includes>
</Landscape>
"@
    # Guardar archivo XML
    [System.IO.File]::WriteAllText($xmlPath, $landscapeContent, [System.Text.Encoding]::UTF8)

    # Depuración de la clave de registro de SAP Logon para evitar advertencias de servidor central
    $regPath = "HKCU:\Software\SAP\SAPLogon\Options"
    if (Test-Path $regPath) {
        Remove-ItemProperty -Path $regPath -Name "SapGui64.LandscapeFileOnServer" -ErrorAction SilentlyContinue
    }
}

# Función para crear/actualizar usuario local
function New-PopsyUser {
    param ([string]$Username, [string]$Password)
    $securePass = ConvertTo-SecureString $Password -AsPlainText -Force
    $userExists = Get-LocalUser -Name $Username -ErrorAction SilentlyContinue

    if (-not $userExists) { New-LocalUser -Name $Username -Password $securePass -FullName "Usuario $Username" -PasswordNeverExpires:$true -ErrorAction Stop | Out-Null }
    else { Set-LocalUser -Name $Username -Password $securePass -PasswordNeverExpires:$true -ErrorAction Stop | Out-Null }

    Enable-LocalUser -Name $Username -ErrorAction SilentlyContinue
    $adminGroup = if (Get-LocalGroup -Name "Administradores" -ErrorAction SilentlyContinue) { "Administradores" } else { "Administrators" }
    Add-LocalGroupMember -Group $adminGroup -Member $Username -ErrorAction SilentlyContinue
}

# ==============================================================================
# 2. DEFINICIÓN DE INTERFAZ (XAML)
# ==============================================================================
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="WinUtil - Suite de Instalación sistemas Popsy" Height="620" Width="820"
        WindowStartupLocation="CenterScreen" Background="#1F232A">
    <Window.Resources>
        <Style TargetType="TabItem">
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="TabItem">
                        <Border Name="Border" CornerRadius="3" Background="#191C21" Margin="2,0" Padding="14,6" BorderBrush="#2D323B" BorderThickness="1">
                            <ContentPresenter x:Name="ContentSite" VerticalAlignment="Center" HorizontalAlignment="Center" ContentSource="Header"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="Border" Property="Background" Value="#29303B" />
                                <Setter Property="Foreground" Value="#41C4E2" />
                            </Trigger>
                            <Trigger Property="IsSelected" Value="True">
                                <Setter TargetName="Border" Property="Background" Value="#3577A8" />
                                <Setter TargetName="Border" Property="BorderBrush" Value="#4B8EC4" />
                                <Setter Property="Foreground" Value="White" />
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
            <Setter Property="Foreground" Value="#A0A5B1"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
        </Style>
        <Style TargetType="Button">
            <Setter Property="Background" Value="#3577A8"/><Setter Property="Foreground" Value="White"/><Setter Property="BorderThickness" Value="0"/><Setter Property="Padding" Value="10,6"/><Setter Property="FontWeight" Value="Bold"/>
            <Setter Property="Template"><Setter.Value><ControlTemplate TargetType="Button"><Border Background="{TemplateBinding Background}" CornerRadius="3"><ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/></Border></ControlTemplate></Setter.Value></Setter>
            <Style.Triggers><Trigger Property="IsMouseOver" Value="True"><Setter Property="Background" Value="#4B8EC4"/></Trigger></Style.Triggers>
        </Style>
    </Window.Resources>

    <Grid Margin="10">
        <Grid.RowDefinitions>
            <RowDefinition Height="*"/> <!-- Área de Pestañas -->
            <RowDefinition Height="Auto"/> <!-- Barra Global Inferior -->
        </Grid.RowDefinitions>

        <!-- CONTENEDOR DE PESTAÑAS -->
        <TabControl Grid.Row="0" Background="Transparent" BorderThickness="0">
            <!-- PESTAÑA 1: INSTALACIONES -->
            <TabItem Header="Instalaciones">
                <Grid Margin="0,10,0,0">
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="220"/>
                        <ColumnDefinition Width="*"/>
                    </Grid.ColumnDefinitions>

                    <!-- Panel Izquierdo: Opciones Rápidas -->
                    <Border Grid.Column="0" Background="#16181D" CornerRadius="5" BorderBrush="#2D323B" BorderThickness="1" Padding="12" Margin="0,0,10,0">
                        <StackPanel>
                            <TextBlock Text="Opciones de Instalación" Foreground="#41C4E2" FontWeight="Bold" FontSize="14" Margin="0,0,0,10"/>
                            <CheckBox Name="chkLanzarAlFinal" Content="Abrir aplicaciones al finalizar" Foreground="#C5C8C6" IsChecked="True" Margin="0,5,0,15"/>
                            <TextBlock Text="Usa el botón de 'EJECUTAR SELECCIÓN GLOBAL' ubicado en la parte inferior para iniciar." Foreground="#A0A5B1" FontSize="11" TextWrapping="Wrap"/>
                        </StackPanel>
                    </Border>

                    <!-- Panel Derecho: Checkboxes de Software -->
                    <Border Grid.Column="1" Background="#16181D" CornerRadius="5" BorderBrush="#2D323B" BorderThickness="1" Padding="15">
                        <ScrollViewer VerticalScrollBarVisibility="Auto">
                            <StackPanel>
                                <TextBlock Text="- Software Corporativo" Foreground="#41C4E2" FontWeight="Bold" FontSize="15" Margin="0,0,0,5"/>
                                <CheckBox Name="chkSeleccionarTodo" Content="Seleccionar / Deseleccionar Todo" Foreground="#41C4E2" FontWeight="Bold" Margin="0,0,0,12"/>
                                
                                <WrapPanel>
                                    <Border Background="#1F232A" BorderBrush="#2D323B" BorderThickness="1" CornerRadius="4" Width="230" Padding="10" Margin="0,0,8,8">
                                        <CheckBox Name="chkLogMeIn" Content="LogMeIn Control Panel (.msi)" Foreground="White"/>
                                    </Border>
                                    <Border Background="#1F232A" BorderBrush="#2D323B" BorderThickness="1" CornerRadius="4" Width="230" Padding="10" Margin="0,0,8,8">
                                        <CheckBox Name="chkSAP" Content="SAP Logon 64 (Instalador)" Foreground="White"/>
                                    </Border>
                                    <Border Background="#1F232A" BorderBrush="#2D323B" BorderThickness="1" CornerRadius="4" Width="230" Padding="10" Margin="0,0,8,8">
                                        <CheckBox Name="chkChrome" Content="Google Chrome" Foreground="White"/>
                                    </Border>
                                    <Border Background="#1F232A" BorderBrush="#2D323B" BorderThickness="1" CornerRadius="4" Width="230" Padding="10" Margin="0,0,8,8">
                                        <CheckBox Name="chkDrive" Content="Google Drive" Foreground="White"/>
                                    </Border>
                                    <Border Background="#1F232A" BorderBrush="#2D323B" BorderThickness="1" CornerRadius="4" Width="230" Padding="10" Margin="0,0,8,8">
                                        <CheckBox Name="chkSonicWall" Content="SonicWall Global VPN Client" Foreground="White"/>
                                    </Border>
                                    <Border Background="#1F232A" BorderBrush="#2D323B" BorderThickness="1" CornerRadius="4" Width="230" Padding="10" Margin="0,0,8,8">
                                        <CheckBox Name="chkAdobe" Content="Adobe Acrobat Reader" Foreground="White"/>
                                    </Border>
                                    <Border Background="#1F232A" BorderBrush="#2D323B" BorderThickness="1" CornerRadius="4" Width="230" Padding="10" Margin="0,0,8,8">
                                        <CheckBox Name="chkStopUpdates" Content="StopUpdates10" Foreground="White"/>
                                    </Border>
                                </WrapPanel>
                            </StackPanel>
                        </ScrollViewer>
                    </Border>
                </Grid>
            </TabItem>

            <!-- PESTAÑA 2: CONFIGURACIONES -->
            <TabItem Header="Configuraciones">
                <ScrollViewer VerticalScrollBarVisibility="Auto" Margin="0,10,0,0">
                    <StackPanel>
                        <!-- SECCIÓN SAP -->
                        <Border Background="#16181D" CornerRadius="5" BorderBrush="#2D323B" BorderThickness="1" Padding="15" Margin="0,0,0,15">
                            <StackPanel HorizontalAlignment="Left">
                                <TextBlock Text="Configuración de Entornos SAP" Foreground="#41C4E2" FontWeight="Bold" FontSize="15" Margin="0,0,0,5"/>
                                <TextBlock Text="Selecciona los ambientes que deseas añadir al perfil de SAP del usuario actual:" Foreground="#A0A5B1" TextWrapping="Wrap" Margin="0,0,0,10"/>
                                <WrapPanel Margin="0,0,0,5">
                                    <CheckBox Name="chkSapPrd" Content="POPSY PRD (Productivo)" Foreground="White" IsChecked="True" Margin="0,0,15,0"/>
                                    <CheckBox Name="chkSapQa" Content="POPSY QA (Calidad)" Foreground="White" Margin="0,0,15,0"/>
                                    <CheckBox Name="chkSapDev" Content="POPSY DESARROLLO" Foreground="White"/>
                                </WrapPanel>
                            </StackPanel>
                        </Border>

                        <!-- SECCIÓN USUARIOS -->
                        <Border Background="#16181D" CornerRadius="5" BorderBrush="#2D323B" BorderThickness="1" Padding="15">
                            <StackPanel HorizontalAlignment="Left" Width="740">
                                <TextBlock Text="Gestión de Usuarios Locales (Administradores)" Foreground="#41C4E2" FontWeight="Bold" FontSize="15" Margin="0,0,0,5"/>
                                <TextBlock Text="Selecciona los usuarios predeterminados o crea uno personalizado para el sistema:" Foreground="#A0A5B1" TextWrapping="Wrap" Margin="0,0,0,10"/>
                                
                                <CheckBox Name="chkUserAdmin" Content="Usuario 'Administrador' (Clave: C4NT464L1&amp;)" Foreground="White" IsChecked="False" Margin="0,0,0,8"/>
                                <CheckBox Name="chkUserLogMeIn" Content="Usuario 'LogMeInRemoteUser' (Clave: C4NT464L1&amp;)" Foreground="White" IsChecked="False" Margin="0,0,0,12"/>
                                
                                <Border Background="#1F232A" BorderBrush="#2D323B" BorderThickness="1" CornerRadius="4" Padding="10">
                                    <StackPanel>
                                        <CheckBox Name="chkUserCustom" Content="Crear Usuario Personalizado (Administrador)" Foreground="#41C4E2" FontWeight="Bold" Margin="0,0,0,8"/>
                                        <Grid Name="panelCustomUser" IsEnabled="False">
                                            <Grid.ColumnDefinitions>
                                                <ColumnDefinition Width="Auto"/>
                                                <ColumnDefinition Width="200"/>
                                                <ColumnDefinition Width="Auto"/>
                                                <ColumnDefinition Width="200"/>
                                            </Grid.ColumnDefinitions>
                                            
                                            <TextBlock Grid.Column="0" Text="Usuario:" Foreground="White" VerticalAlignment="Center" Margin="0,0,8,0"/>
                                            <TextBox Grid.Column="1" Name="txtCustomUser" Background="#16181D" Foreground="White" BorderBrush="#2D323B" Padding="4" Margin="0,0,15,0"/>
                                            <TextBlock Grid.Column="2" Text="Contraseña:" Foreground="White" VerticalAlignment="Center" Margin="0,0,8,0"/>
                                            <PasswordBox Grid.Column="3" Name="txtCustomPass" Background="#16181D" Foreground="White" BorderBrush="#2D323B" Padding="4"/>
                                        </Grid>
                                    </StackPanel>
                                </Border>
                            </StackPanel>
                        </Border>
                    </StackPanel>
                </ScrollViewer>
            </TabItem>
        </TabControl>

        <!-- FOOTER GLOBAL DE EJECUCIÓN -->
        <Border Grid.Row="1" Background="#16181D" CornerRadius="5" BorderBrush="#2D323B" BorderThickness="1" Padding="15" Margin="0,10,0,0">
            <Grid>
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="Auto"/>
                </Grid.ColumnDefinitions>
                <StackPanel Grid.Column="0" VerticalAlignment="Center">
                    <TextBlock Text="Estado del Sistema:" Foreground="#A0A5B1" FontSize="12" Margin="0,0,0,2"/>
                    <TextBlock Name="TxtEstado" Text="Esperando ejecución..." Foreground="#41C4E2" FontSize="13" TextWrapping="Wrap" FontWeight="Bold"/>
                </StackPanel>
                <Button Name="BtnEjecutarGlobal" Grid.Column="1" Content="▶ EJECUTAR SELECCIÓN GLOBAL" Background="#107C41" Width="260" Height="40" FontSize="14" Cursor="Hand"/>
            </Grid>
        </Border>
    </Grid>
</Window>
"@

$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [System.Windows.Markup.XamlReader]::Load($reader)

# Mapeo de Variables XAML
$txtEstado         = $window.FindName("TxtEstado")
$btnEjecutarGlobal = $window.FindName("BtnEjecutarGlobal")
$chkSeleccionarTodo= $window.FindName("chkSeleccionarTodo")
$chkLanzarAlFinal  = $window.FindName("chkLanzarAlFinal")

# Controles Instalaciones
$chkLogMeIn     = $window.FindName("chkLogMeIn")
$chkSAP         = $window.FindName("chkSAP")
$chkChrome      = $window.FindName("chkChrome")
$chkDrive       = $window.FindName("chkDrive")
$chkSonicWall   = $window.FindName("chkSonicWall")
$chkAdobe       = $window.FindName("chkAdobe")
$chkStopUpdates = $window.FindName("chkStopUpdates")

# Controles Configuraciones (SAP & Usuarios)
$chkSapPrd      = $window.FindName("chkSapPrd")
$chkSapQa       = $window.FindName("chkSapQa")
$chkSapDev      = $window.FindName("chkSapDev")
$chkUserAdmin   = $window.FindName("chkUserAdmin")
$chkUserLogMeIn = $window.FindName("chkUserLogMeIn")
$chkUserCustom  = $window.FindName("chkUserCustom")
$panelCustomUser= $window.FindName("panelCustomUser")
$txtCustomUser  = $window.FindName("txtCustomUser")
$txtCustomPass  = $window.FindName("txtCustomPass")

# Matriz para Select All
$installCheckboxes = @($chkLogMeIn, $chkSAP, $chkChrome, $chkDrive, $chkSonicWall, $chkAdobe, $chkStopUpdates)

# Eventos UX
$chkUserCustom.Add_Checked({ $panelCustomUser.IsEnabled = $true })
$chkUserCustom.Add_Unchecked({ $panelCustomUser.IsEnabled = $false })

# Evento: Seleccionar/Deseleccionar Todo
$chkSeleccionarTodo.Add_Click({
    $estado = $chkSeleccionarTodo.IsChecked
    foreach ($chk in $installCheckboxes) {
        $chk.IsChecked = $estado
    }
})

# Función auxiliar de WinGet
function Install-App {
    param ([string]$id, [string]$nombre, [string]$exeRuta = "")
    $txtEstado.Text = "Instalando $nombre..."
    Update-UI
    winget install --id $id --silent --accept-package-agreements --accept-source-agreements | Out-Null
    if ($chkLanzarAlFinal.IsChecked -and $exeRuta -ne "") {
        if (Test-Path $exeRuta) { Start-Process -FilePath $exeRuta }
    }
}

# ==============================================================================
# 3. LÓGICA MODULAR (MÉTODOS DE EJECUCIÓN)
# ==============================================================================

function Invoke-Instalaciones {
    $haySeleccion = $false
    foreach ($chk in $installCheckboxes) { if ($chk.IsChecked) { $haySeleccion = $true; break } }
    if (-not $haySeleccion) { return }

    if ($chkChrome.IsChecked)    { Install-App "Google.Chrome" "Google Chrome" "C:\Program Files\Google\Chrome\Application\chrome.exe" }
    if ($chkDrive.IsChecked)     { Install-App "Google.Drive" "Google Drive" "C:\Program Files\Google\Drive File Stream\launch.exe" }
    if ($chkAdobe.IsChecked)     { Install-App "Adobe.Acrobat.Reader.64-bit" "Adobe Reader" "C:\Program Files\Adobe\Acrobat DC\Acrobat\Acrobat.exe" }
    if ($chkSonicWall.IsChecked) { Install-App "SonicWall.GlobalVPNClient" "SonicWall Global VPN Client" "C:\Program Files\SonicWall\Global VPN Client\SWGVC.exe" }

    if ($chkStopUpdates.IsChecked) { 
        $txtEstado.Text = "Instalando StopUpdates10..."
        Update-UI
        winget install --id Greatis.StopUpdates10 --silent --force --accept-package-agreements --accept-source-agreements | Out-Null
        $exeStop = "C:\Program Files (x86)\StopUpdates10\StopUpdates10.exe"
        if ($chkLanzarAlFinal.IsChecked -and (Test-Path $exeStop)) { Start-Process -FilePath $exeStop }
    }

    # DESCARGA E INSTALACIÓN DESDE REPOSITORIO PROXMOX (PUERTO 8080)
    if ($chkLogMeIn.IsChecked) {
        $txtEstado.Text = "Descargando e Instalando LogMeIn Control Panel desde servidor local..."
        Update-UI
        $localFolder  = "$env:TEMP\PopsyInstallers"
        $msiInstaller = "$localFolder\LogMeIn.msi"
        $proxmoxMsiUrl = "http://192.168.2.145:8080/popsy/LogMeInAdministrativo.msi"
        
        if (-not (Test-Path $localFolder)) { New-Item -ItemType Directory -Path $localFolder -Force | Out-Null }
        if (-not (Test-Path $msiInstaller)) {
            $oldProgress = $ProgressPreference; $ProgressPreference = 'SilentlyContinue'
            Invoke-WebRequest -Uri $proxmoxMsiUrl -OutFile $msiInstaller -UseBasicParsing -ErrorAction SilentlyContinue
            $ProgressPreference = $oldProgress
        }
        if (Test-Path $msiInstaller) {
            Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$msiInstaller`" /qn /norestart" -Wait
        }
        $logMeInExe = "C:\Program Files (x86)\LogMeIn\x64\ramui.exe"
        if ($chkLanzarAlFinal.IsChecked -and (Test-Path $logMeInExe)) { Start-Process -FilePath $logMeInExe }
    }

    if ($chkSAP.IsChecked) {
        $txtEstado.Text = "Descargando e Instalando SAP Logon 64 desde servidor local..."
        Update-UI
        $localFolder = "C:\SAP"
        $singleExe   = "$localFolder\SAP_PopsyPackage.exe"
        $proxmoxUrl  = "http://192.168.2.145:8080/popsy/SAP_PopsyPackage.exe"

        if (-not (Test-Path $localFolder)) { New-Item -ItemType Directory -Path $localFolder -Force | Out-Null }
        if (-not (Test-Path $singleExe)) {
            $oldProgress = $ProgressPreference; $ProgressPreference = 'SilentlyContinue'
            Invoke-WebRequest -Uri $proxmoxUrl -OutFile $singleExe -UseBasicParsing -ErrorAction SilentlyContinue
            $ProgressPreference = $oldProgress
        }
        if (Test-Path $singleExe) { Start-Process -FilePath $singleExe -ArgumentList "/Silent" -Wait }

        $sapExe = "C:\Program Files\SAP\FrontEnd\SAPgui\saplogon.exe"
        if ($chkLanzarAlFinal.IsChecked -and (Test-Path $sapExe)) { Start-Process -FilePath $sapExe }
    }
}

function Invoke-ConfiguracionesSAP {
    if ($chkSapPrd.IsChecked -or $chkSapQa.IsChecked -or $chkSapDev.IsChecked) {
        $txtEstado.Text = "Aplicando perfiles XML corporativos de SAP..."
        Update-UI
        Set-SAPLandscapePopsy -IncludePRD $chkSapPrd.IsChecked -IncludeQA $chkSapQa.IsChecked -IncludeDEV $chkSapDev.IsChecked
    }
}

function Invoke-CreacionUsuarios {
    $creados = @()
    if ($chkUserAdmin.IsChecked) { New-PopsyUser -Username "Administrador" -Password "C4NT464L1&"; $creados += "Administrador" }
    if ($chkUserLogMeIn.IsChecked){ New-PopsyUser -Username "LogMeInRemoteUser" -Password "C4NT464L1&"; $creados += "LogMeInRemoteUser" }
    
    if ($chkUserCustom.IsChecked) {
        $cUser = $txtCustomUser.Text.Trim()
        $cPass = $txtCustomPass.Password.Trim()
        if (-not [string]::IsNullOrWhiteSpace($cUser) -and -not [string]::IsNullOrWhiteSpace($cPass)) {
            New-PopsyUser -Username $cUser -Password $cPass
            $creados += "$cUser (Personalizado)"
        }
    }
    
    if ($creados.Count -gt 0) {
        $txtEstado.Text = "Usuarios locales creados: $($creados -join ', ')..."
        Update-UI
    }
}

# ==============================================================================
# 4. DISPARADOR DE EVENTO PRINCIPAL (EJECUTADOR GLOBAL)
# ==============================================================================

$btnEjecutarGlobal.Add_Click({
    $btnEjecutarGlobal.IsEnabled = $false
    $chkSeleccionarTodo.IsEnabled = $false

    try {
        Invoke-Instalaciones
        Invoke-ConfiguracionesSAP
        Invoke-CreacionUsuarios

        $txtEstado.Text = "¡Ejecución Global Completada Exitosamente!"
        [System.Windows.MessageBox]::Show("Todas las tareas de Instalación y Configuración marcadas han finalizado correctamente.", "Proceso Exitoso")
    }
    catch {
        $txtEstado.Text = "Ocurrió un error en el despliegue."
        [System.Windows.MessageBox]::Show("Ocurrió un error durante la ejecución: $_", "Error de Ejecución")
    }
    finally {
        $btnEjecutarGlobal.IsEnabled = $true
        $chkSeleccionarTodo.IsEnabled = $true
    }
})

$window.ShowDialog() | Out-Null