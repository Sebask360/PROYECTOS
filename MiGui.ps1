Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="WinUtil - Suite de Instalación" Height="540" Width="800"
        WindowStartupLocation="CenterScreen" Background="#1F232A">
    
    <Window.Resources>
        <!-- Estilo Pestañas Superiores -->
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

        <!-- Estilo Botones -->
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
            
            <TabItem Header="Instalaciones">
                <Grid Margin="0,10,0,0">
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="220"/>
                        <ColumnDefinition Width="*"/>
                    </Grid.ColumnDefinitions>

                    <!-- Panel Izquierdo: Acciones -->
                    <Border Grid.Column="0" Background="#16181D" CornerRadius="5" BorderBrush="#2D323B" BorderThickness="1" Padding="12" Margin="0,0,10,0">
                        <StackPanel>
                            <TextBlock Text="Acciones" Foreground="#41C4E2" FontWeight="Bold" FontSize="14" Margin="0,0,0,10"/>
                            <Button Name="BtnInstalar" Content="Instalar Seleccionados" Height="35" Margin="0,0,0,10"/>
                            
                            <CheckBox Name="chkLanzarAlFinal" Content="Abrir al finalizar" Foreground="#C5C8C6" IsChecked="True" Margin="0,5,0,15"/>

                            <TextBlock Text="Estado:" Foreground="#A0A5B1" FontSize="12" Margin="0,5,0,5"/>
                            <TextBlock Name="TxtEstado" Text="Esperando selección..." Foreground="#41C4E2" FontSize="11" TextWrapping="Wrap"/>
                        </StackPanel>
                    </Border>

                    <!-- Panel Derecho: Lista de Apps -->
                    <Border Grid.Column="1" Background="#16181D" CornerRadius="5" BorderBrush="#2D323B" BorderThickness="1" Padding="15">
                        <ScrollViewer VerticalScrollBarVisibility="Auto">
                            <StackPanel>
                                <TextBlock Text="- Software Seleccionado" Foreground="#41C4E2" FontWeight="Bold" FontSize="15" Margin="0,0,0,10"/>
                                <WrapPanel>
                                    <Border Background="#1F232A" BorderBrush="#2D323B" BorderThickness="1" CornerRadius="4" Width="230" Padding="10" Margin="0,0,8,8">
                                        <CheckBox Name="chkLogMeIn" Content="LogMeIn Client" Foreground="White"/>
                                    </Border>
                                    <Border Background="#1F232A" BorderBrush="#2D323B" BorderThickness="1" CornerRadius="4" Width="230" Padding="10" Margin="0,0,8,8">
                                        <CheckBox Name="chkSAP" Content="SAP Logon 64" Foreground="White"/>
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

            <TabItem Header="Configuraciones">
                <TextBlock Text="Opciones de configuración" Foreground="White" Margin="20"/>
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

# Mapear Controles
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

# Función auxiliar de instalación mediante WinGet con opción de apertura
function Install-App {
    param (
        [string]$id, 
        [string]$nombre, 
        [string]$exeRuta = ""
    )
    $txtEstado.Text = "Instalando $nombre..."
    [System.Windows.Forms.Application]::DoEvents()
    
    # Instalación silenciosa vía WinGet
    winget install --id $id --silent --accept-package-agreements --accept-source-agreements | Out-Null
    
    # Lanzar la aplicación si la casilla está activa y se proporcionó la ruta del ejecutable
    if ($chkLanzarAlFinal.IsChecked -and $exeRuta -ne "") {
        if (Test-Path $exeRuta) {
            Start-Process -FilePath $exeRuta
        }
    }
}

# Lógica del botón de Instalación
$btnInstalar.Add_Click({
    $btnInstalar.IsEnabled = $false

    try {
        if ($chkChrome.IsChecked) { 
            Install-App "Google.Chrome" "Google Chrome" "C:\Program Files\Google\Chrome\Application\chrome.exe" 
        }
        if ($chkDrive.IsChecked) { 
            Install-App "Google.Drive" "Google Drive" "C:\Program Files\Google\Drive File Stream\launch.exe" 
        }
        if ($chkAdobe.IsChecked) { 
            Install-App "Adobe.Acrobat.Reader.64-bit" "Adobe Reader" "C:\Program Files\Adobe\Acrobat DC\Acrobat\Acrobat.exe" 
        }
        if ($chkSonicWall.IsChecked) { 
            # Se usa el ID exacto de SonicWall Global VPN Client
            Install-App "SonicWall.GlobalVPNClient" "SonicWall Global VPN Client" "C:\Program Files\SonicWall\Global VPN Client\SWGVC.exe" 
        }
        if ($chkLogMeIn.IsChecked) { 
            Install-App "LogMeIn.LogMeInClient" "LogMeIn Client" "C:\Program Files (x86)\LogMeIn\x64\LogMeInSystray.exe" 
        }
        if ($chkStopUpdates.IsChecked) { 
            Install-App "GreatisSoftware.StopUpdates10" "StopUpdates10" "C:\Program Files (x86)\StopUpdates10\StopUpdates10.exe" 
        }

        # Instalación de SAP Logon 64
        if ($chkSAP.IsChecked) {
            $txtEstado.Text = "Descargando SAP Logon 64..."
            [System.Windows.Forms.Application]::DoEvents()
            
            $tempPath = "$env:TEMP\SetupGUI.exe"
            $sapUrl = "https://tu-servidor.com/SetupGUI.exe" # Reemplazar con URL de descarga
            
            Invoke-WebRequest -Uri $sapUrl -OutFile $tempPath
            $txtEstado.Text = "Instalando SAP Logon 64..."
            [System.Windows.Forms.Application]::DoEvents()
            
            Start-Process -FilePath $tempPath -ArgumentList "/silent" -Wait
            Remove-Item $tempPath -Force -ErrorAction SilentlyContinue

            # Abrir SAP Logon si la casilla está marcada
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

$window.ShowDialog() | Out-Null