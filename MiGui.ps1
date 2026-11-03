# Cargar las ensamblajes visuales de .NET necesarias
Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase

# 1. Definir la UI en formato XAML
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Mi Herramienta Personalizada" Height="250" Width="400"
        WindowStartupLocation="CenterScreen" Background="#1E1E1E">
    <Grid Margin="20">
        <StackPanel VerticalAlignment="Center">
            <TextBlock Text="¡Hola desde PowerShell GUI!" 
                       Foreground="White" FontSize="18" 
                       HorizontalAlignment="Center" Margin="0,0,0,20"/>
            
            <Button Name="BtnEjecutar" Content="Ejecutar Acción" 
                    Height="40" Width="150" 
                    Background="#007ACC" Foreground="White" 
                    FontSize="14" BorderThickness="0"/>
        </StackPanel>
    </Grid>
</Window>
"@

# 2. Convertir el XAML en objetos visuales .NET
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [System.Windows.Markup.XamlReader]::Load($reader)

# 3. Vincular eventos a controles específicos
$btnEjecutar = $window.FindName("BtnEjecutar")
$btnEjecutar.Add_Click({
    [System.Windows.MessageBox]::Show("¡El botón fue presionado correctamente!", "Notificación")
})

# 4. Renderizar la ventana
$window.ShowDialog() | Out-Null