Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Mi Herramienta Multi-Pestaña" Height="400" Width="550"
        WindowStartupLocation="CenterScreen" Background="#1E1E1E">
    
    <Grid Margin="10">
        <!-- Contenedor Principal de Pestañas -->
        <TabControl Background="#252526" BorderBrush="#3F3F46" Foreground="White">
            
            <!-- Pestaña 1: Configuraciones -->
            <TabItem Header="Configuraciones" Foreground="White" Padding="10,5">
                <StackPanel Margin="15">
                    <TextBlock Text="Opciones del Sistema" FontSize="16" FontWeight="Bold" Foreground="White" Margin="0,0,0,15"/>
                    <CheckBox Content="Activar Modo Oscuro" Foreground="White" Margin="0,5"/>
                    <CheckBox Content="Iniciar con Windows" Foreground="White" Margin="0,5"/>
                    <CheckBox Content="Crear Punto de Restauración" Foreground="White" Margin="0,5"/>
                </StackPanel>
            </TabItem>

            <!-- Pestaña 2: Instalaciones -->
            <TabItem Header="Instalaciones" Foreground="White" Padding="10,5">
                <StackPanel Margin="15">
                    <TextBlock Text="Programas Esenciales" FontSize="16" FontWeight="Bold" Foreground="White" Margin="0,0,0,15"/>
                    <CheckBox Name="Chk7Zip" Content="Instalar 7-Zip" Foreground="White" Margin="0,5"/>
                    <CheckBox Name="ChkVLC" Content="Instalar VLC Media Player" Foreground="White" Margin="0,5"/>
                    <Button Name="BtnInstalar" Content="Instalar Seleccionados" Height="30" Margin="0,15,0,0" Background="#007ACC" Foreground="White"/>
                </StackPanel>
            </TabItem>

            <!-- Pestaña 3: Notas -->
            <TabItem Header="Notas" Foreground="White" Padding="10,5">
                <Grid Margin="15">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="*"/>
                    </Grid.RowDefinitions>
                    <TextBlock Text="Bloc de Notas Rápido" FontSize="16" FontWeight="Bold" Foreground="White" Margin="0,0,0,10" Grid.Row="0"/>
                    <TextBox Name="TxtNotas" Grid.Row="1" AcceptsReturn="True" VerticalScrollBarVisibility="Auto" Background="#1E1E1E" Foreground="White" BorderBrush="#3F3F46"/>
                </Grid>
            </TabItem>

        </TabControl>
    </Grid>
</Window>
"@

$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [System.Windows.Markup.XamlReader]::Load($reader)

# Evento del botón de la pestaña Instalaciones
$btnInstalar = $window.FindName("BtnInstalar")
$chk7Zip = $window.FindName("Chk7Zip")
$chkVLC = $window.FindName("ChkVLC")

$btnInstalar.Add_Click({
    $seleccionados = @()
    if ($chk7Zip.IsChecked) { $seleccionados += "7-Zip" }
    if ($chkVLC.IsChecked) { $seleccionados += "VLC" }

    if ($seleccionados.Count -gt 0) {
        $lista = $seleccionados -join ", "
        [System.Windows.MessageBox]::Show("Iniciando instalación de: $lista", "Instalador")
    } else {
        [System.Windows.MessageBox]::Show("Por favor selecciona al menos una opción.", "Aviso")
    }
})

$window.ShowDialog() | Out-Null