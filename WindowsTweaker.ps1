<#
.SYNOPSIS
    Windows Tweaking Utility - Comprehensive system optimization tool
.DESCRIPTION
    This script provides a GUI interface for optimizing Windows settings across multiple categories.
    Inspired by Chris Titus Tech's debloat script but with expanded functionality.
.NOTES
    File Name      : WindowsTweaker.ps1
    Author         : Your Name
    Prerequisite   : PowerShell 5.1+, Windows 10/11
    Run as Admin   : Required for most tweaks
#>

#Requires -RunAsAdministrator

Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase, System.Windows.Forms

#region XAML GUI Definition
[xml]$XAML = @"
<Window 
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="Windows Tweaking Utility" Height="700" Width="1000" 
    WindowStartupLocation="CenterScreen" Background="#FF1E1E1E" ResizeMode="CanResize">
    
    <Window.Resources>
        <!-- Base Styles -->
        <Style TargetType="TextBlock">
            <Setter Property="Foreground" Value="White"/>
        </Style>
        
        <Style TargetType="CheckBox">
            <Setter Property="Foreground" Value="White"/>
            <Setter Property="Margin" Value="0,5,0,0"/>
        </Style>
        
        <Style TargetType="Button">
            <Setter Property="Padding" Value="10,5"/>
            <Setter Property="Margin" Value="0,5,0,0"/>
            <Setter Property="Background" Value="#FF007ACC"/>
            <Setter Property="Foreground" Value="White"/>
        </Style>
        
        <Style TargetType="ComboBox">
            <Setter Property="Margin" Value="0,5,0,5"/>
        </Style>
        
        <!-- Custom Styles -->
        <Style x:Key="DarkTabItem" TargetType="TabItem">
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="TabItem">
                        <Grid>
                            <Border Name="Border" Background="Transparent" BorderThickness="0">
                                <ContentPresenter x:Name="ContentSite" VerticalAlignment="Center"
                                                HorizontalAlignment="Center" ContentSource="Header"
                                                Margin="10,5"/>
                            </Border>
                        </Grid>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsSelected" Value="True">
                                <Setter TargetName="Border" Property="Background" Value="#FF252526"/>
                                <Setter TargetName="ContentSite" Property="TextElement.Foreground" Value="White"/>
                            </Trigger>
                            <Trigger Property="IsSelected" Value="False">
                                <Setter TargetName="ContentSite" Property="TextElement.Foreground" Value="Gray"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
        
        <Style x:Key="DarkExpander" TargetType="Expander">
            <Setter Property="Background" Value="#FF252526"/>
            <Setter Property="BorderBrush" Value="#FF3F3F46"/>
            <Setter Property="Foreground" Value="White"/>
            <Setter Property="Margin" Value="5"/>
        </Style>
        
        <Style x:Key="SectionHeader" TargetType="TextBlock">
            <Setter Property="Foreground" Value="#FF007ACC"/>
            <Setter Property="FontWeight" Value="Bold"/>
            <Setter Property="FontSize" Value="14"/>
            <Setter Property="Margin" Value="0,0,0,5"/>
        </Style>
        
        <Style x:Key="DescriptionText" TargetType="TextBlock">
            <Setter Property="Foreground" Value="LightGray"/>
            <Setter Property="FontSize" Value="12"/>
            <Setter Property="Margin" Value="0,0,0,10"/>
            <Setter Property="TextWrapping" Value="Wrap"/>
        </Style>
        
        <Style x:Key="StatusTextBox" TargetType="TextBox">
            <Setter Property="Background" Value="#FF333337"/>
            <Setter Property="Foreground" Value="White"/>
            <Setter Property="IsReadOnly" Value="True"/>
            <Setter Property="VerticalScrollBarVisibility" Value="Auto"/>
        </Style>
        
        <Style x:Key="SecondaryButton" TargetType="Button" BasedOn="{StaticResource {x:Type Button}}">
            <Setter Property="Background" Value="#FF3F3F46"/>
        </Style>
        
        <Style x:Key="InnerTabControl" TargetType="TabControl">
            <Setter Property="Background" Value="Transparent"/>
            <Setter Property="BorderThickness" Value="0"/>
        </Style>
    </Window.Resources>
    
    <Grid>
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="200"/>
            <ColumnDefinition Width="*"/>
        </Grid.ColumnDefinitions>
        
        <!-- Left Navigation Panel -->
        <StackPanel Grid.Column="0" Background="#FF121212">
            <TextBlock Text="TWEAK CATEGORIES" Foreground="Gray" Margin="10,10,0,0" FontWeight="Bold"/>
            
            <TabControl x:Name="MainTabs" Background="Transparent" BorderThickness="0">
                <!-- Windows Tab -->
                <TabItem Header="Windows" Style="{StaticResource DarkTabItem}">
                    <ScrollViewer>
                        <StackPanel>
                            <!-- Boot Manager -->
                            <Expander Header="Boot Manager" Style="{StaticResource DarkExpander}">
                                <StackPanel Margin="15,5">
                                    <CheckBox x:Name="chkFastStartup" Content="Enable Fast Startup"/>
                                    <TextBlock Text="Speeds up boot time by saving kernel state to hiberfile" Style="{StaticResource DescriptionText}"/>
                                    <CheckBox x:Name="chkBootDelay" Content="Disable Boot Delay"/>
                                    <TextBlock Text="Removes the 30-second delay when multiple OSes are present" Style="{StaticResource DescriptionText}"/>
                                </StackPanel>
                            </Expander>
                            
                            <!-- Prefetch -->
                            <Expander Header="Prefetch" Style="{StaticResource DarkExpander}">
                                <StackPanel Margin="15,5">
                                    <CheckBox x:Name="chkPrefetch" Content="Enable Prefetch"/>
                                    <TextBlock Text="Improves launch times for frequently used apps" Style="{StaticResource DescriptionText}"/>
                                    <CheckBox x:Name="chkSuperfetch" Content="Enable Superfetch"/>
                                    <TextBlock Text="Prefetches data into RAM (good for HDDs, disable for SSDs)" Style="{StaticResource DescriptionText}"/>
                                </StackPanel>
                            </Expander>
                            
                            <!-- Temp Files -->
                            <Expander Header="Temp Files" Style="{StaticResource DarkExpander}">
                                <StackPanel Margin="15,5">
                                    <Button x:Name="btnCleanTemp" Content="Clean Temporary Files"/>
                                    <TextBlock Text="Removes temporary files from %temp% directory" Style="{StaticResource DescriptionText}"/>
                                    <Button x:Name="btnCleanWinTemp" Content="Clean Windows Temp" Margin="0,5,0,0"/>
                                    <TextBlock Text="Cleans Windows temporary installation files" Style="{StaticResource DescriptionText}"/>
                                </StackPanel>
                            </Expander>
                            
                            <!-- Microsoft Store -->
                            <Expander Header="Microsoft Store" Style="{StaticResource DarkExpander}">
                                <StackPanel Margin="15,5">
                                    <CheckBox x:Name="chkDisableStoreUpdates" Content="Disable Automatic Updates"/>
                                    <TextBlock Text="Prevents Store apps from updating automatically" Style="{StaticResource DescriptionText}"/>
                                </StackPanel>
                            </Expander>
                            
                            <!-- Auto-Defrag -->
                            <Expander Header="Auto-Defrag" Style="{StaticResource DarkExpander}">
                                <StackPanel Margin="15,5">
                                    <CheckBox x:Name="chkDisableAutoDefrag" Content="Disable Auto Defrag"/>
                                    <TextBlock Text="Disables automatic defragmentation (recommended for SSDs)" Style="{StaticResource DescriptionText}"/>
                                </StackPanel>
                            </Expander>
                            
                            <!-- Debloat Windows -->
                            <Expander Header="Debloat Windows" Style="{StaticResource DarkExpander}">
                                <StackPanel Margin="15,5">
                                    <Button x:Name="btnDebloatBasic" Content="Remove Common Bloatware"/>
                                    <TextBlock Text="Removes preinstalled apps like CandyCrush, Xbox, etc." Style="{StaticResource DescriptionText}"/>
                                    <Button x:Name="btnDebloatAggressive" Content="Aggressive Debloat" Margin="0,5,0,0"/>
                                    <TextBlock Text="Removes more apps including Edge and Store (use with caution)" Style="{StaticResource DescriptionText}"/>
                                </StackPanel>
                            </Expander>
                            
                            <!-- Built-in Apps -->
                            <Expander Header="Built-in Apps" Style="{StaticResource DarkExpander}">
                                <StackPanel Margin="15,5">
                                    <CheckBox x:Name="chkRemoveOneDrive" Content="Remove OneDrive"/>
                                    <CheckBox x:Name="chkRemoveCortana" Content="Remove Cortana"/>
                                    <CheckBox x:Name="chkRemoveEdge" Content="Remove Microsoft Edge"/>
                                </StackPanel>
                            </Expander>
                            
                            <!-- Paging -->
                            <Expander Header="Paging" Style="{StaticResource DarkExpander}">
                                <StackPanel Margin="15,5">
                                    <Button x:Name="btnAutoPaging" Content="Let Windows Manage"/>
                                    <Button x:Name="btnCustomPaging" Content="Set Custom Size" Margin="0,5,0,0"/>
                                    <TextBlock Text="1.5x RAM size recommended for gaming" Style="{StaticResource DescriptionText}"/>
                                </StackPanel>
                            </Expander>
                            
                            <!-- Windows Defender -->
                            <Expander Header="Windows Defender" Style="{StaticResource DarkExpander}">
                                <StackPanel Margin="15,5">
                                    <CheckBox x:Name="chkDisableDefender" Content="Disable Real-time Protection"/>
                                    <TextBlock Text="Turns off constant scanning (security risk)" Style="{StaticResource DescriptionText}"/>
                                    <CheckBox x:Name="chkDisableCloudProtection" Content="Disable Cloud Protection"/>
                                </StackPanel>
                            </Expander>
                            
                            <!-- Telemetry -->
                            <Expander Header="Telemetry" Style="{StaticResource DarkExpander}">
                                <StackPanel Margin="15,5">
                                    <CheckBox x:Name="chkDisableTelemetry" Content="Disable Basic Telemetry"/>
                                    <TextBlock Text="Reduces data sent to Microsoft" Style="{StaticResource DescriptionText}"/>
                                    <CheckBox x:Name="chkDisableCEIP" Content="Disable CEIP"/>
                                </StackPanel>
                            </Expander>
                            
                            <!-- Windows Visuals -->
                            <Expander Header="Windows Visuals" Style="{StaticResource DarkExpander}">
                                <StackPanel Margin="15,5">
                                    <CheckBox x:Name="chkDisableAnimations" Content="Disable Animations"/>
                                    <CheckBox x:Name="chkDisableTransparency" Content="Disable Transparency"/>
                                </StackPanel>
                            </Expander>
                        </StackPanel>
                    </ScrollViewer>
                </TabItem>
                
                <!-- Network Tab -->
                <TabItem Header="Network" Style="{StaticResource DarkTabItem}">
                    <ScrollViewer>
                        <StackPanel>
                            <!-- IPv6 -->
                            <Expander Header="IPv6" Style="{StaticResource DarkExpander}">
                                <StackPanel Margin="15,5">
                                    <CheckBox x:Name="chkDisableIPv6" Content="Disable IPv6"/>
                                    <TextBlock Text="Disables IPv6 protocol if not needed" Style="{StaticResource DescriptionText}"/>
                                </StackPanel>
                            </Expander>
                            
                            <!-- TCP/IP Settings -->
                            <Expander Header="TCP/IP Settings" Style="{StaticResource DarkExpander}">
                                <StackPanel Margin="15,5">
                                    <ComboBox x:Name="cmbTcpIpProfile">
                                        <ComboBoxItem Content="Optimal (Default)"/>
                                        <ComboBoxItem Content="High-performance"/>
                                        <ComboBoxItem Content="Low-latency"/>
                                    </ComboBox>
                                    <TextBlock Text="Optimizes TCP/IP stack for different use cases" Style="{StaticResource DescriptionText}"/>
                                </StackPanel>
                            </Expander>
                        </StackPanel>
                    </ScrollViewer>
                </TabItem>
                
                <!-- Devices Tab -->
                <TabItem Header="Devices" Style="{StaticResource DarkTabItem}">
                    <ScrollViewer>
                        <StackPanel>
                            <!-- Keyboard -->
                            <Expander Header="Keyboard" Style="{StaticResource DarkExpander}">
                                <StackPanel Margin="15,5">
                                    <TextBlock Text="Input Queue Size:"/>
                                    <ComboBox x:Name="cmbKeyboardQueue">
                                        <ComboBoxItem Content="Low-End (64)"/>
                                        <ComboBoxItem Content="Medium (128)"/>
                                        <ComboBoxItem Content="High-End (256)"/>
                                    </ComboBox>
                                    <TextBlock Text="Adjusts how many keyboard inputs can be buffered" Style="{StaticResource DescriptionText}"/>
                                </StackPanel>
                            </Expander>
                        </StackPanel>
                    </ScrollViewer>
                </TabItem>
                
                <!-- CPU Tab -->
                <TabItem Header="CPU" Style="{StaticResource DarkTabItem}">
                    <ScrollViewer>
                        <StackPanel>
                            <TabControl Style="{StaticResource InnerTabControl}">
                                <TabItem Header="Intel">
                                    <ScrollViewer>
                                        <StackPanel>
                                            <!-- Core Parking -->
                                            <Expander Header="Core Parking" Style="{StaticResource DarkExpander}">
                                                <StackPanel Margin="15,5">
                                                    <CheckBox x:Name="chkDisableCoreParkingIntel" Content="Disable Core Parking"/>
                                                    <TextBlock Text="Prevents Windows from parking CPU cores" Style="{StaticResource DescriptionText}"/>
                                                </StackPanel>
                                            </Expander>
                                        </StackPanel>
                                    </ScrollViewer>
                                </TabItem>
                                <TabItem Header="AMD">
                                    <ScrollViewer>
                                        <StackPanel>
                                            <!-- SMT Control -->
                                            <Expander Header="SMT Control" Style="{StaticResource DarkExpander}">
                                                <StackPanel Margin="15,5">
                                                    <CheckBox x:Name="chkDisableSMT" Content="Disable SMT"/>
                                                    <TextBlock Text="Disables simultaneous multithreading" Style="{StaticResource DescriptionText}"/>
                                                </StackPanel>
                                            </Expander>
                                        </StackPanel>
                                    </ScrollViewer>
                                </TabItem>
                            </TabControl>
                        </StackPanel>
                    </ScrollViewer>
                </TabItem>
                
                <!-- GPU Tab -->
                <TabItem Header="GPU" Style="{StaticResource DarkTabItem}">
                    <ScrollViewer>
                        <StackPanel>
                            <!-- NVIDIA Settings -->
                            <Expander Header="NVIDIA Settings" Style="{StaticResource DarkExpander}">
                                <StackPanel Margin="15,5">
                                    <CheckBox x:Name="chkNvidiaLowLatency" Content="Reduce Input Delay"/>
                                    <TextBlock Text="Optimizes NVIDIA control panel settings" Style="{StaticResource DescriptionText}"/>
                                    <CheckBox x:Name="chkEnableMSI" Content="Enable MSI Mode"/>
                                </StackPanel>
                            </Expander>
                        </StackPanel>
                    </ScrollViewer>
                </TabItem>
                
                <!-- Games Tab -->
                <TabItem Header="Games" Style="{StaticResource DarkTabItem}">
                    <ScrollViewer>
                        <StackPanel>
                            <TabControl Style="{StaticResource InnerTabControl}">
                                <TabItem Header="Fortnite">
                                    <ScrollViewer>
                                        <StackPanel>
                                            <CheckBox x:Name="chkFortniteReplay" Content="Disable Replay System"/>
                                            <TextBlock Text="Improves FPS by disabling built-in replay recording" Style="{StaticResource DescriptionText}"/>
                                        </StackPanel>
                                    </ScrollViewer>
                                </TabItem>
                                <TabItem Header="Rust">
                                    <ScrollViewer>
                                        <StackPanel>
                                            <CheckBox x:Name="chkRustLargePages" Content="Large Pages"/>
                                            <TextBlock Text="Enables large pages for potentially better performance" Style="{StaticResource DescriptionText}"/>
                                        </StackPanel>
                                    </ScrollViewer>
                                </TabItem>
                                <TabItem Header="Valorant">
                                    <ScrollViewer>
                                        <StackPanel>
                                            <CheckBox x:Name="chkValorantFullscreenOpt" Content="Disable Fullscreen Optimizations"/>
                                            <TextBlock Text="Bypasses DWM for potentially lower input lag" Style="{StaticResource DescriptionText}"/>
                                        </StackPanel>
                                    </ScrollViewer>
                                </TabItem>
                            </TabControl>
                        </StackPanel>
                    </ScrollViewer>
                </TabItem>
            </TabControl>
        </StackPanel>
        
        <!-- Right Panel - Status/Preview -->
        <Grid Grid.Column="1" Background="#FF252526">
            <StackPanel Margin="10">
                <TextBlock Text="SYSTEM INFORMATION" Style="{StaticResource SectionHeader}"/>
                <Grid>
                    <StackPanel>
                        <TextBlock x:Name="txtSystemInfo" Text="Loading system information..." Style="{StaticResource DescriptionText}"/>
                        <ProgressBar x:Name="pbSystemInfo" IsIndeterminate="True" Height="10" Margin="0,5,0,0"/>
                    </StackPanel>
                </Grid>
                
                <TextBlock Text="APPLY TWEAKS" Style="{StaticResource SectionHeader}" Margin="0,20,0,0"/>
                <Button x:Name="btnApplyTweaks" Content="Apply Selected Tweaks"/>
                <Button x:Name="btnCreateRestorePoint" Content="Create Restore Point" Style="{StaticResource SecondaryButton}" Margin="0,5,0,0"/>
                <Button x:Name="btnRestoreDefaults" Content="Restore Defaults" Style="{StaticResource SecondaryButton}" Margin="0,5,0,0"/>
                
                <TextBlock Text="STATUS" Style="{StaticResource SectionHeader}" Margin="0,20,0,0"/>
                <TextBox x:Name="txtStatus" Style="{StaticResource StatusTextBox}" TextWrapping="Wrap" AcceptsReturn="True" Height="150"/>
            </StackPanel>
        </Grid>
    </Grid>
</Window>
"@
#endregion

#region Load XAML and Create Window
try {
    $reader = (New-Object System.Xml.XmlNodeReader $XAML)
    $Window = [Windows.Markup.XamlReader]::Load($reader)
    
    # Create variables for each named UI element
    $XAML.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]") | ForEach-Object {
        Set-Variable -Name ($_.Name) -Value $Window.FindName($_.Name) -Scope Script
    }
}
catch {
    Write-Host "Error loading XAML: $_" -ForegroundColor Red
    exit
}
#endregion

#region System Information
function Get-SystemInformation {
    $cpu = Get-WmiObject Win32_Processor | Select-Object -ExpandProperty Name
    $gpu = Get-WmiObject Win32_VideoController | Select-Object -ExpandProperty Name
    $ram = [math]::Round((Get-WmiObject Win32_ComputerSystem).TotalPhysicalMemory / 1GB)
    $os = (Get-WmiObject Win32_OperatingSystem).Caption
    
    $txtSystemInfo.Text = "CPU: $cpu`nGPU: $gpu`nRAM: $ram GB`nOS: $os"
    $pbSystemInfo.Visibility = "Collapsed"
}

# Load system info in background
$job = Start-Job -ScriptBlock {
    Add-Type -AssemblyName System.Windows.Forms
    $cpu = Get-WmiObject Win32_Processor | Select-Object -ExpandProperty Name
    $gpu = Get-WmiObject Win32_VideoController | Select-Object -ExpandProperty Name
    $ram = [math]::Round((Get-WmiObject Win32_ComputerSystem).TotalPhysicalMemory / 1GB)
    $os = (Get-WmiObject Win32_OperatingSystem).Caption
    
    return "CPU: $cpu`nGPU: $gpu`nRAM: $ram GB`nOS: $os"
}

$timer = New-Object System.Windows.Threading.DispatcherTimer
$timer.Interval = [TimeSpan]::FromMilliseconds(500)
$timer.Add_Tick({
    if ($job.State -eq "Completed") {
        $txtSystemInfo.Text = $job | Receive-Job
        $pbSystemInfo.Visibility = "Collapsed"
        $timer.Stop()
    }
})
$timer.Start()
#endregion

#region Tweaking Functions
function Invoke-TempClean {
    $txtStatus.Text += "Cleaning temporary files...`n"
    try {
        Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "$env:WINDIR\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
        $txtStatus.Text += "Temporary files cleaned.`n"
    }
    catch {
        $txtStatus.Text += "Error cleaning temp files: $_`n"
    }
}

function Set-FastStartup {
    param([bool]$Enable)
    
    try {
        if ($Enable) {
            $txtStatus.Text += "Enabling Fast Startup...`n"
            powercfg /hibernate on
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name "HiberbootEnabled" -Value 1 -ErrorAction Stop
        }
        else {
            $txtStatus.Text += "Disabling Fast Startup...`n"
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name "HiberbootEnabled" -Value 0 -ErrorAction Stop
        }
        $txtStatus.Text += "Fast Startup setting updated.`n"
    }
    catch {
        $txtStatus.Text += "Error setting Fast Startup: $_`n"
    }
}

function Remove-Bloatware {
    $txtStatus.Text += "Removing bloatware apps...`n"
    
    # Common bloatware packages
    $apps = @(
        "Microsoft.BingNews"
        "Microsoft.GetHelp"
        "Microsoft.Getstarted"
        "Microsoft.MicrosoftOfficeHub"
        "Microsoft.MicrosoftSolitaireCollection"
        "Microsoft.People"
        "Microsoft.SkypeApp"
        "Microsoft.WindowsFeedbackHub"
        "Microsoft.XboxApp"
        "Microsoft.XboxGameOverlay"
        "Microsoft.XboxIdentityProvider"
        "Microsoft.ZuneMusic"
        "Microsoft.ZuneVideo"
    )
    
    foreach ($app in $apps) {
        try {
            Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage -ErrorAction SilentlyContinue
            Get-AppxProvisionedPackage -Online | Where-Object DisplayName -Like $app | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
            $txtStatus.Text += "Removed: $app`n"
        }
        catch {
            $txtStatus.Text += "Failed to remove $app`: $_`n"
        }
    }
    
    $txtStatus.Text += "Bloatware removal completed.`n"
}

function Disable-Telemetry {
    $txtStatus.Text += "Disabling telemetry...`n"
    
    try {
        # Basic telemetry
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0 -ErrorAction Stop
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0 -ErrorAction Stop
        
        # CEIP
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\SQMClient\Windows" -Name "CEIPEnable" -Type DWord -Value 0 -ErrorAction Stop
        
        $txtStatus.Text += "Telemetry settings updated.`n"
    }
    catch {
        $txtStatus.Text += "Error disabling telemetry: $_`n"
    }
}

function Optimize-Network {
    $txtStatus.Text += "Optimizing network settings...`n"
    
    try {
        # Disable IPv6 if selected
        if ($chkDisableIPv6.IsChecked) {
            $txtStatus.Text += "Disabling IPv6...`n"
            Disable-NetAdapterBinding -Name "*" -ComponentID ms_tcpip6 -ErrorAction Stop
        }
        
        # Set TCP/IP profile based on selection
        $profile = $cmbTcpIpProfile.SelectedIndex
        switch ($profile) {
            1 { # High-performance
                $txtStatus.Text += "Setting TCP/IP to high-performance profile...`n"
                Set-NetTCPSetting -SettingName InternetCustom -CongestionProvider DCTCP -ErrorAction Stop
            }
            2 { # Low-latency
                $txtStatus.Text += "Setting TCP/IP to low-latency profile...`n"
                Set-NetTCPSetting -SettingName InternetCustom -CongestionProvider Cubic -ErrorAction Stop
            }
            default {
                $txtStatus.Text += "Using default TCP/IP settings...`n"
            }
        }
        
        $txtStatus.Text += "Network optimization completed.`n"
    }
    catch {
        $txtStatus.Text += "Error optimizing network: $_`n"
    }
}

function Create-RestorePoint {
    try {
        $txtStatus.Text += "Creating system restore point...`n"
        Checkpoint-Computer -Description "Windows Tweaker Restore Point" -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
        $txtStatus.Text += "Restore point created successfully.`n"
    }
    catch {
        $txtStatus.Text += "Failed to create restore point: $_`n"
    }
}
#endregion

#region Event Handlers
$btnCleanTemp.Add_Click({
    Invoke-TempClean
})

$btnDebloatBasic.Add_Click({
    Remove-Bloatware
})

$btnApplyTweaks.Add_Click({
    $txtStatus.Text = "Applying selected tweaks...`n"
    
    # Windows tweaks
    if ($null -ne $chkFastStartup.IsChecked) {
        Set-FastStartup -Enable $chkFastStartup.IsChecked
    }
    
    if ($chkDisableTelemetry.IsChecked) {
        Disable-Telemetry
    }
    
    # Network tweaks
    Optimize-Network
    
    $txtStatus.Text += "All selected tweaks applied!`n"
})

$btnCreateRestorePoint.Add_Click({
    Create-RestorePoint
})

$Window.Add_Closing({
    # Clean up jobs
    if ($job -and $job.State -eq "Running") {
        $job | Stop-Job
    }
})
#endregion

# Initialize and show the window
try {
    # Set initial state
    $txtStatus.Text = "Ready. Select tweaks and click 'Apply Selected Tweaks'."
    
    # Show the window
    $Window.ShowDialog() | Out-Null
}
catch {
    Write-Host "Error showing window: $_" -ForegroundColor Red
}