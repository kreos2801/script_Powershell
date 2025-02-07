# Delete existing tasks, if any (You can delete this part)
if (Get-ScheduledTask -TaskName "LauchWorkOrNot" -ErrorAction SilentlyContinue) {
    Unregister-ScheduledTask -TaskName "LauchWorkOrNot" -Confirm:$false
}

# Define the action to execute a PowerShell script
$scriptContent = @'
Add-Type -AssemblyName Microsoft.VisualBasic

$result = [Microsoft.VisualBasic.Interaction]::MsgBox("Do you want to work ? ?", "YesNo,Question", "Confirmation")

#You can change here what you want to launch when "yes" is pressed.
if ($result -eq [Microsoft.VisualBasic.MsgBoxResult]::Yes) {
    	Start-Process "outlook"
    	$teams = Get-ChildItem -Path C:\Users\ -Filter ms-teams.exe -Recurse -Force -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName -First 1
    	if ($teams) {
        	Start-Process $teams
    	} else {
        	Write-Host "ms-teams.exe not found."
    	}
	Start https://gitlab.com/users/sign_in
} else {
	$discord = Get-ChildItem -Path C:\Users\ -Filter Discord.exe -Recurse -Force -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName -First 1
    	if ($discord) {
        	Start-Process $discord
    	} else {
        	Write-Host "Discord.exe not found."
    	}
	Start https://www.youtube.com/
}
'@

$scriptPath = "C:\your\path\were\the\scriptcontent\will\be\write"
$scriptContent | Set-Content -Path $scriptPath -Encoding UTF8

# Define the action to execute this PowerShell script
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$scriptPath`"" 

# Define triggers
$triggerLogOn = New-ScheduledTaskTrigger -AtLogOn

# Define principal and parameters
$principal = New-ScheduledTaskPrincipal -UserId "$env:USERNAME" -LogonType Interactive -RunLevel Highest
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

# Create scheduled task
Register-ScheduledTask -Action $action -Trigger $triggerLogOn -Principal $principal -Settings $settings -TaskName "LauchWorkOrNot" -Description "Starts work configuration or not "
