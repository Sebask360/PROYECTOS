Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="WinUtil - Réplica de Estilo" Height="500" Width="800"
        WindowStartupLocation="CenterScreen" Background="#1F232A">
    
    <Window.Resources>
        <!-- Estilo base para las pestañas superiores principales -->
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

        <!-- Estilo para botones de la barra lateral -->
        <Style TargetType="Button">
            <Setter Property="Background" Value="#191C21"/>
            <Setter Property="Foreground" Value="#C5C8C6"/>
            <Setter Property="BorderBrush" Value="#2D323B"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Padding" Value="8,6"/>
            <Setter Property="Margin" Value="0,2"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border Background="{TemplateBinding Background}" 
                                BorderBrush="{TemplateBinding BorderBrush}" 
                                BorderThickness="{TemplateBinding BorderThickness}" 
                                CornerRadius="3">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
            <Style.Triggers>
                <Trigger Property="IsMouseOver" Value="True">
                    <Setter Property="Background" Value="#29303B"/>
                    <Setter Property="Foreground" Value="#41C4E2"/>
                </Trigger>
            </Style.Triggers>
        </Style>

        <!-- Estilo para los elementos/tarjetas dentro del panel -->
        <Style TargetType="CheckBox">
            <Setter Property="Foreground" Value="#D4D4D4"/>
            <Setter Property="Margin" Value="0,4"/>
        </Style>
    </Window.Resources>

    <Grid Margin="10">
        <!-- Pestañas Principales Superior -->
        <TabControl Background="Transparent" BorderThickness="0">
            
            <!-- PESTAÑA: INSTALL -->
            <TabItem Header="Install">
                <Grid Margin="0,10,0,0">
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="200"/>
                        <ColumnDefinition Width="*"/>
                    </Grid.ColumnDefinitions>

                    <!-- Panel Lateral Izquierdo: Actions & Package Manager -->
                    <Border Grid.Column="0" Background="#16181D" CornerRadius="5" BorderBrush="#2D323B" BorderThickness="1" Padding="10" Margin="0,0,10,0">
                        <StackPanel>
                            <TextBlock Text="Actions" Foreground="#41C4E2" FontWeight="Bold" FontSize="14" Margin="0,0,0,8"/>
                            <Button Content="Install/Upgrade Applications"/>
                            <Button Content="Uninstall Applications"/>
                            <Button Content="Upgrade all Applications"/>

                            <TextBlock Text="Package Manager" Foreground="#41C4E2" FontWeight="Bold" FontSize="14" Margin="0,15,0,8"/>
                            <RadioButton Content="Chocolatey" Foreground="#C5C8C6" Margin="0,2"/>
                            <RadioButton Content="WinGet" Foreground="#C5C8C6" IsChecked="True" Margin="0,2"/>
                        </StackPanel>
                    </Border>

                    <!-- Panel Central Derecha: Contenedores por Categorías -->
                    <Border Grid.Column="1" Background="#16181D" CornerRadius="5" BorderBrush="#2D323B" BorderThickness="1" Padding="15">
                        <ScrollViewer VerticalScrollBarVisibility="Auto">
                            <StackPanel>
                                <!-- Sección Browsers -->
                                <TextBlock Text="- Browsers" Foreground="#41C4E2" FontWeight="Bold" FontSize="15" Margin="0,0,0,10"/>
                                <WrapPanel Margin="0,0,0,15">
                                    <Border Background="#1F232A" BorderBrush="#2D323B" BorderThickness="1" CornerRadius="4" Width="170" Padding="8" Margin="0,0,8,8">
                                        <CheckBox Content="Brave" Foreground="White" FontWeight="SemiBold"/>
                                    </Border>
                                    <Border Background="#1F232A" BorderBrush="#2D323B" BorderThickness="1" CornerRadius="4" Width="170" Padding="8" Margin="0,0,8,8">
                                        <CheckBox Content="Chrome" Foreground="White" FontWeight="SemiBold"/>
                                    </Border>
                                    <Border Background="#1F232A" BorderBrush="#2D323B" BorderThickness="1" CornerRadius="4" Width="170" Padding="8" Margin="0,0,8,8">
                                        <CheckBox Content="Firefox" Foreground="White" FontWeight="SemiBold"/>
                                    </Border>
                                </WrapPanel>

                                <!-- Sección Communications -->
                                <TextBlock Text="- Communications" Foreground="#41C4E2" FontWeight="Bold" FontSize="15" Margin="0,5,0,10"/>
                                <WrapPanel>
                                    <Border Background="#1F232A" BorderBrush="#2D323B" BorderThickness="1" CornerRadius="4" Width="170" Padding="8" Margin="0,0,8,8">
                                        <CheckBox Content="Discord" Foreground="White" FontWeight="SemiBold"/>
                                    </Border>
                                    <Border Background="#1F232A" BorderBrush="#2D323B" BorderThickness="1" CornerRadius="4" Width="170" Padding="8" Margin="0,0,8,8">
                                        <CheckBox Content="Signal" Foreground="White" FontWeight="SemiBold"/>
                                    </Border>
                                    <Border Background="#1F232A" BorderBrush="#2D323B" BorderThickness="1" CornerRadius="4" Width="170" Padding="8" Margin="0,0,8,8">
                                        <CheckBox Content="Teams" Foreground="White" FontWeight="SemiBold"/>
                                    </Border>
                                </WrapPanel>
                            </StackPanel>
                        </ScrollViewer>
                    </Border>
                </Grid>
            </TabItem>

            <!-- PESTAÑAS SECUNDARIAS -->
            <TabItem Header="Tweaks">
                <TextBlock Text="Opciones de optimización" Foreground="White" Margin="20"/>
            </TabItem>
            <TabItem Header="Config">
                <TextBlock Text="Configuraciones adicionales" Foreground="White" Margin="20"/>
            </TabItem>
            <TabItem Header="Updates">
                <TextBlock Text="Ajustes de Windows Update" Foreground="White" Margin="20"/>
            </TabItem>
        </TabControl>
    </Grid>
</Window>
"@

$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [System.Windows.Markup.XamlReader]::Load($reader)
$window.ShowDialog() | Out-Null