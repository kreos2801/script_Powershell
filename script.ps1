# Supprimer les tâches existantes si elles existent
if (Get-ScheduledTask -TaskName "OuvrirSiteWebAuDemarrage" -ErrorAction SilentlyContinue) {
    Unregister-ScheduledTask -TaskName "OuvrirSiteWebAuDemarrage" -Confirm:$false
}

# Définir l'action pour exécuter un script PowerShell
$scriptContent = @'
Add-Type -AssemblyName Microsoft.VisualBasic

$result = [Microsoft.VisualBasic.Interaction]::MsgBox("Voulez-vous bosser ?", "YesNo,Question", "Confirmation")
$defaultBrowser = (Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice").ProgId

if ($result -eq [Microsoft.VisualBasic.MsgBoxResult]::Yes) {
    	Start-Process "outlook"
    	$teams = Get-ChildItem -Path C:\Users\ -Filter ms-teams.exe -Recurse -Force -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName -First 1
    	if ($teams) {
        	Start-Process $teams
    	} else {
        	Write-Host "ms-teams.exe n'a pas été trouvé."
    	}
	Start https://dumas.esiea.fr/cas/login?service=https:%2F%2Fsand.esiea.fr%2Fetudiant
} else {
	$discord = Get-ChildItem -Path C:\Users\ -Filter Discord.exe -Recurse -Force -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName -First 1
    	if ($discord) {
        	Start-Process $discord
    	} else {
        	Write-Host "Discord.exe n'a pas été trouvé."
    	}
	Start https://dumas.esiea.fr/cas/login?service=https:%2F%2Fsand.esiea.fr%2Fetudiant
}
'@

$scriptPath = "C:\Users\gaouditz\Documents\000 Esiea\OuvrirSiteWeb.ps1"
$scriptContent | Set-Content -Path $scriptPath -Encoding UTF8

# Définir l'action pour exécuter ce script PowerShell
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$scriptPath`"" 

# Définir les déclencheurs
$triggerLogOn = New-ScheduledTaskTrigger -AtLogOn

# Définir le principal et les paramètres
$principal = New-ScheduledTaskPrincipal -UserId "$env:USERNAME" -LogonType Interactive -RunLevel Highest
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

# Créer la tâche planifiée
Register-ScheduledTask -Action $action -Trigger $triggerLogOn -Principal $principal -Settings $settings -TaskName "OuvrirSiteWebAuDemarrage" -Description "Ouvre le site web à la connexion"