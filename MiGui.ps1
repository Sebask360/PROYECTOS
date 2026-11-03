Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Mi Herramienta - Estilo de Pestañas" Height="400" Width="550"
        WindowStartupLocation="CenterScreen" Background="#1E1E1E">
    
    <Window.Resources>
        <!-- Estilo personalizado para todas las pestañas -->
        <Style TargetType="TabItem">
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="TabItem">
                        <Border Name="Border" CornerRadius="4,4,0,0" Background="#2D2D30" 
                                Margin="2,0" Padding="12,6" BorderBrush="#3F3F46" BorderThickness="1,1,1,0">
                            <ContentPresenter x:Name="ContentSite"
                                              VerticalAlignment="Center"
                                              HorizontalAlignment="Center"
                                              ContentSource="Header"
                                              RecognizesAccessKey="True"/>
                        </Border>
                        
                        <ControlTemplate.Triggers>
                            <!-- 1. Estado: Al pasar el ratón por encima (Hover) -->
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="Border" Property="Background" Value="#3E3E42" />
                                <Setter Property="Foreground" Value="#007ACC" />
                            </Trigger>
                            
                            <!-- 2. Estado: Pestaña Seleccionada -->
                            <Trigger Property="IsSelected" Value="True">
                                <Setter TargetName="Border" Property="Background" Value="#007ACC" />
                                <Setter Property="Foreground" Value="White" />
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
            <Setter Property="Foreground" Value="#CCCCCC"/>
        </Style>
    </Window.Resources>

    <Grid Margin="10">
        <TabControl Background="#252526" BorderBrush="#3F3F46">
            
            <TabItem Header="Configuraciones">
                <StackPanel Margin="15">
                    <TextBlock Text="Opciones del Sistema" FontSize="16" FontWeight="Bold" Foreground="White" Margin="0,0,0,15"/>
                    <CheckBox Content="Activar Modo Oscuro" Foreground="White" Margin="0,5"/>
                </StackPanel>
            </TabItem>

            <TabItem Header="Instalaciones">
                <StackPanel Margin="15">
                    <TextBlock Text="Programas Esenciales" FontSize="16" FontWeight="Bold" Foreground="White" Margin="0,0,0,15"/>
                    <CheckBox Content="Instalar 7-Zip" Foreground="White" Margin="0,5"/>
                </StackPanel>
            </TabItem>

            <TabItem Header="Notas">
                <Grid Margin="15">
                    <TextBlock Text="Bloc de Notas Rápido" FontSize="16" FontWeight="Bold" Foreground="White"/>
                </Grid>
            </TabItem>

        </TabControl>
    </Grid>
</Window>
"@

$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [System.Windows.Markup.XamlReader]::Load($reader)
$window.ShowDialog() | Out-Null