Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase, System.Windows.Forms

# ==============================================================================
# 1. FUNCIONES AUXILIARES
# ==============================================================================

# Función dinámica para inyectar el XML corporativo de SAP según selección
function Set-SAPLandscapePopsy {
    param (
        [bool]$IncludePRD,
        [bool]$IncludeQA,
        [bool]$IncludeDEV
    )

    $landscapeDir = "$env:APPDATA\SAP\Common"
    $xmlPath      = "$landscapeDir\SAPUILandscape.xml"

    # Crear carpeta destino si no existe
    if (-not (Test-Path $landscapeDir)) {
        New-Item -ItemType Directory -Path $landscapeDir -Force | Out-Null
    }

    # Inicializar bloques de construcción del XML
    $xmlItems    = ""
    $xmlServices = ""
    $xmlRouters  = ""

    $needRouter1 = $false
    $needRouter2 = $false

    # Construir Nodos dinámicamente
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

    # Añadir routers solo si los ambientes seleccionados los requieren
    if ($needRouter1) { 
        $xmlRouters += "    <Router uuid=`"0b893123-f1ba-4cef-902d-6b3537829aef`" name=`"/H/200.91.193.73`" description=`"/H/200.91.193.73`" router=`"/H/200.91.193.73`"/>`n" 
    }
    if ($needRouter2) { 
        $xmlRouters += "    <Router uuid=`"8aeed703-b3da-460c-83ba-fb5cd1ed35e3`" name=`"/H/200.91.193.73|`" description=`"/H/200.91.193.73|`" router=`"/H/200.91.193.73|`"/>`n" 
    }

    # Limpiar el último salto de línea
    $xmlItems    = $xmlItems.TrimEnd("`n")
    $xmlRouters  = $xmlRouters.TrimEnd("`n")
    $xmlServices = $xmlServices.TrimEnd("`n")

    # Ensamblar el XML Final
    $landscapeContent = @"
<?xml version="1.0" encoding="UTF-8"?>
<Landscape updated="$((Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ"))" version="1" generator="SAP GUI for Windows v8000.1.15.155">
  <Workspaces>
    <Workspace uuid="9a7bc45a-12fe-4bf6-bb32-29e67c6479e3" name="Local">
$xmlItems
    </Workspace>
  </Workspaces>
  <Routers>
$xmlRouters
  </Routers>
  <Services>
$xmlServices
  </Services>
  <Includes>
    <Include url="file:///$env:APPDATA/SAP/Common/SAPUILandscapeGlobal.xml" index="0" description="SAP Reserved"/>
  </Includes>
</Landscape>
"@

    # Guardar archivo con codificación UTF-8 sin BOM
    [System.IO.File]::WriteAllText($xmlPath, $landscapeContent, [System.Text.Encoding]::UTF8)
}

# ==============================================================================
# 2. DEFINICIÓN DE INTERFAZ (XAML)
# ==============================================================================
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="WinUtil - Suite de Instalación sistemas Popsy" Height="540" Width="800"
        WindowStartupLocation="CenterScreen" Background="#1F232A">
    
    <Window.Resources>
        <Style TargetType="TabItem">
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="TabItem">
                        <Border Name="Border" CornerRadius="3" Background="#191C21" 
                                Margin="2,0" Padding="14,6" BorderBrush="#2D323B" BorderThickness="1">
                            <ContentPresenter x:Name="ContentSite" VerticalAlignment="Center" 
                                              HorizontalAlignment="Center" ContentSource="Header"/>
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
            <Setter Property="Background" Value="#3577A8"/>
            <Setter Property="Foreground" Value="White"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Padding" Value="10,6"/>
            <Setter Property="FontWeight" Value="Bold"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border Background="{TemplateBinding Background}" CornerRadius="3">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
            <Style.Triggers>
                <Trigger Property="IsMouseOver" Value="True">
                    <Setter Property="Background" Value="#4B8EC4"/>
                </Trigger>
            </Style.Triggers>
        </Style>
    </Window.Resources>

    <Grid Margin="10">
        <TabControl Background="Transparent" BorderThickness="0">
            
            <!-- PESTAÑA 1: INSTALACIONES -->
            <TabItem Header="Instalaciones">
                <Grid Margin="0,10,0,0">
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="220"/>
                        <ColumnDefinition Width="*"/>
                    </Grid.ColumnDefinitions>

                    <Border Grid.Column="0" Background="#16181D" CornerRadius="5" BorderBrush="#2D323B" BorderThickness="1" Padding="12" Margin="0,0,10,0">
                        <StackPanel>
                            <TextBlock Text="Acciones" Foreground="#41C4E2" FontWeight="Bold" FontSize="14" Margin="0,0,0,10"/>
                            <Button Name="BtnInstalar" Content="Instalar Seleccionados" Height="35" Margin="0,0,0,10"/>
                            <CheckBox Name="chkLanzarAlFinal" Content="Abrir al finalizar" Foreground="#C5C8C6" IsChecked="True" Margin="0,5,0,15"/>
                            <TextBlock Text="Estado:" Foreground="#A0A5B1" FontSize="12" Margin="0,5,0,5"/>
                            <TextBlock Name="TxtEstado" Text="Esperando selección..." Foreground="#41C4E2" FontSize="11" TextWrapping="Wrap"/>
                        </StackPanel>
                    </Border>

                    <Border Grid.Column="1" Background="#16181D" CornerRadius="5" BorderBrush="#2D323B" BorderThickness="1" Padding="15">
                        <ScrollViewer VerticalScrollBarVisibility="Auto">
                            <StackPanel>
                                <TextBlock Text="- Software Seleccionado" Foreground="#41C4E2" FontWeight="Bold" FontSize="15" Margin="0,0,0,10"/>
                                <WrapPanel>
                                    <Border Background="#1F232A" BorderBrush="#2D323B" BorderThickness="1" CornerRadius="4" Width="230" Padding="10" Margin="0,0,8,8">
                                        <CheckBox Name="chkLogMeIn" Content="LogMeIn Client" Foreground="White"/>
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

            <!-- PESTAÑA 2: CONFIGURACIONES (Selección de Ambientes) -->
            <TabItem Header="Configuraciones">
                <Grid Margin="0,10,0,0">
                    <Border Background="#16181D" CornerRadius="5" BorderBrush="#2D323B" BorderThickness="1" Padding="15">
                        <StackPanel HorizontalAlignment="Left" VerticalAlignment="Top">
                            <TextBlock Text="Configuración de Entornos SAP" Foreground="#41C4E2" FontWeight="Bold" FontSize="15" Margin="0,0,0,10"/>
                            <TextBlock Text="Selecciona los ambientes que deseas añadir al perfil de SAP del usuario actual:" Foreground="#A0A5B1" TextWrapping="Wrap" Margin="0,0,0,15"/>
                            
                            <CheckBox Name="chkSapPrd" Content="POPSY PRD (Productivo)" Foreground="White" IsChecked="True" Margin="0,0,0,8"/>
                            <CheckBox Name="chkSapQa" Content="POPSY QA (Calidad)" Foreground="White" Margin="0,0,0,8"/>
                            <CheckBox Name="chkSapDev" Content="POPSY DESARROLLO" Foreground="White" Margin="0,0,0,20"/>
                            
                            <Button Name="BtnConfigurarSAP" Content="Aplicar Configuraciones SAP" Width="220" HorizontalAlignment="Left" Height="35"/>
                        </StackPanel>
                    </Border>
                </Grid>
            </TabItem>
            
            <TabItem Header="Notas">
                <TextBlock Text="Bloc de Notas" Foreground="White" Margin="20"/>
            </TabItem>

        </TabControl>
    </Grid>
</Window>
"@

# Cargar XAML
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [System.Windows.Markup.XamlReader]::Load($reader)

# Mapear Controles Pestaña Instalaciones
$btnInstalar     = $window.FindName("BtnInstalar")
$txtEstado       = $window.FindName("TxtEstado")
$chkLanzarAlFinal= $window.FindName("chkLanzarAlFinal")

$chkLogMeIn      = $window.FindName("chkLogMeIn")
$chkSAP          = $window.FindName("chkSAP")
$chkChrome       = $window.FindName("chkChrome")
$chkDrive        = $window.FindName("chkDrive")
$chkSonicWall    = $window.FindName("chkSonicWall")
$chkAdobe        = $window.FindName("chkAdobe")
$chkStopUpdates  = $window.FindName("chkStopUpdates")

# Mapear Controles Pestaña Configuraciones
$btnConfigurarSAP= $window.FindName("BtnConfigurarSAP")
$chkSapPrd       = $window.FindName("chkSapPrd")
$chkSapQa        = $window.FindName("chkSapQa")
$chkSapDev       = $window.FindName("chkSapDev")

# Función auxiliar de instalación mediante WinGet con opción de apertura
function Install-App {
    param ([string]$id, [string]$nombre, [string]$exeRuta = "")
    $txtEstado.Text = "Instalando $nombre..."
    $window.Dispatcher.Invoke([System.Action]{}, [System.Windows.Threading.DispatcherPriority]::Background)
    
    winget install --id $id --silent --accept-package-agreements --accept-source-agreements | Out-Null
    
    if ($chkLanzarAlFinal.IsChecked -and $exeRuta -ne "") {
        if (Test-Path $exeRuta) { Start-Process -FilePath $exeRuta }
    }
}

# ==============================================================================
# 3. LÓGICA DE EVENTOS (BOTONES)
# ==============================================================================

# Lógica del botón de Instalación Principal
$btnInstalar.Add_Click({
    $btnInstalar.IsEnabled = $false

    try {
        if ($chkChrome.IsChecked) { Install-App "Google.Chrome" "Google Chrome" "C:\Program Files\Google\Chrome\Application\chrome.exe" }
        if ($chkDrive.IsChecked)  { Install-App "Google.Drive" "Google Drive" "C:\Program Files\Google\Drive File Stream\launch.exe" }
        if ($chkAdobe.IsChecked)  { Install-App "Adobe.Acrobat.Reader.64-bit" "Adobe Reader" "C:\Program Files\Adobe\Acrobat DC\Acrobat\Acrobat.exe" }
        if ($chkSonicWall.IsChecked){ Install-App "SonicWall.GlobalVPNClient" "SonicWall Global VPN Client" "C:\Program Files\SonicWall\Global VPN Client\SWGVC.exe" }
        if ($chkLogMeIn.IsChecked){ Install-App "LogMeIn.LogMeInClient" "LogMeIn Client" "C:\Program Files (x86)\LogMeIn\x64\LogMeInSystray.exe" }

        if ($chkStopUpdates.IsChecked) { 
            $txtEstado.Text = "Instalando StopUpdates10..."
            $window.Dispatcher.Invoke([System.Action]{}, [System.Windows.Threading.DispatcherPriority]::Background)
            winget install --id Greatis.StopUpdates10 --silent --force --accept-package-agreements --accept-source-agreements | Out-Null
            $exeStop = "C:\Program Files (x86)\StopUpdates10\StopUpdates10.exe"
            if ($chkLanzarAlFinal.IsChecked -and (Test-Path $exeStop)) { Start-Process -FilePath $exeStop }
        }

        # INSTALACIÓN SAP
        if ($chkSAP.IsChecked) {
            $txtEstado.Text = "Comprobando instalador de SAP..."
            $window.Dispatcher.Invoke([System.Action]{}, [System.Windows.Threading.DispatcherPriority]::Background)

            $localFolder = "C:\SAP"
            $singleExe   = "$localFolder\PopsyPackage_20261103_1431.exe"
            $githubUrl   = "https://github.com/Sebask360/PROYECTOS/releases/download/v1.0.1/PopsyPackage_20261103_1431.exe"

            if (-not (Test-Path $localFolder)) {
                New-Item -ItemType Directory -Path $localFolder -Force | Out-Null
            }

            if (-not (Test-Path $singleExe)) {
                $txtEstado.Text = "Descargando SAP Logon 64 desde GitHub..."
                $window.Dispatcher.Invoke([System.Action]{}, [System.Windows.Threading.DispatcherPriority]::Background)
                try {
                    Invoke-WebRequest -Uri $githubUrl -OutFile $singleExe -UseBasicParsing
                } catch {
                    [System.Windows.MessageBox]::Show("Error al descargar el ejecutable de SAP.", "Error Descarga")
                }
            }

            if (Test-Path $singleExe) {
                $txtEstado.Text = "Instalando SAP Logon 64 en segundo plano..."
                $window.Dispatcher.Invoke([System.Action]{}, [System.Windows.Threading.DispatcherPriority]::Background)
                Start-Process -FilePath $singleExe -ArgumentList "/Silent" -Wait
            }

            $sapExe = "C:\Program Files\SAP\FrontEnd\SAPgui\saplogon.exe"
            if ($chkLanzarAlFinal.IsChecked -and (Test-Path $sapExe)) {
                Start-Process -FilePath $sapExe
            }
        }

        $txtEstado.Text = "¡Instalaciones completadas!"
        [System.Windows.MessageBox]::Show("Proceso finalizado con éxito.", "Notificación")
    }
    catch {
        $txtEstado.Text = "Error durante la instalación."
        [System.Windows.MessageBox]::Show("Ocurrió un error: $_", "Error")
    }
    finally {
        $btnInstalar.IsEnabled = $true
    }
})

# Lógica del botón de Configuración SAP Dinámica
$btnConfigurarSAP.Add_Click({
    try {
        # Validar que al menos uno esté seleccionado
        if (-not ($chkSapPrd.IsChecked -or $chkSapQa.IsChecked -or $chkSapDev.IsChecked)) {
            [System.Windows.MessageBox]::Show("Debes seleccionar al menos un ambiente para configurar.", "Aviso")
            return
        }

        # Ejecutar función pasando los valores de los CheckBox
        Set-SAPLandscapePopsy -IncludePRD $chkSapPrd.IsChecked -IncludeQA $chkSapQa.IsChecked -IncludeDEV $chkSapDev.IsChecked
        
        [System.Windows.MessageBox]::Show("El archivo de configuración SAPUILandscape.xml se ha actualizado exitosamente con los ambientes seleccionados.", "Configuración Aplicada")
    } catch {
        [System.Windows.MessageBox]::Show("Ocurrió un error al aplicar la configuración XML: $_", "Error XML")
    }
})

$window.ShowDialog() | Out-Null