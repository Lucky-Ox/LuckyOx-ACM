#requires -Version 7.2
[CmdletBinding()]
param(
    [ValidatePattern('^([01][0-9]|2[0-3]):[0-5][0-9]$')]
    [string]$Time = '23:00'
)

$ErrorActionPreference = 'Stop'
$repositoryPath = Split-Path -Parent $PSScriptRoot
$syncScript = Join-Path $PSScriptRoot 'Sync-GitHub.ps1'
$powerShellPath = (Get-Process -Id $PID).Path
$gitPath = (Get-Command git.exe -ErrorAction Stop).Source
if (-not (Test-Path -LiteralPath $syncScript -PathType Leaf)) { throw 'Sync-GitHub.ps1 is missing.' }

$actionArguments = '-NoProfile -NonInteractive -WindowStyle Hidden -ExecutionPolicy RemoteSigned -File "{0}" -RepositoryPath "{1}" -GitPath "{2}"' -f $syncScript, $repositoryPath, $gitPath
$action = New-ScheduledTaskAction -Execute $powerShellPath -Argument $actionArguments -WorkingDirectory $repositoryPath
$trigger = New-ScheduledTaskTrigger -Daily -At $Time
$principal = New-ScheduledTaskPrincipal -UserId ([Security.Principal.WindowsIdentity]::GetCurrent().User.Value) -LogonType Interactive -RunLevel Limited
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -MultipleInstances IgnoreNew -ExecutionTimeLimit (New-TimeSpan -Minutes 10) -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 10)

Register-ScheduledTask -TaskName 'LuckyOx-ACM-DailySync' -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Description "Sync LuckyOx-ACM to GitHub daily at $Time (Windows local time), using the signed-in user's Git credentials." -Force | Out-Null
Write-Output "Installed LuckyOx-ACM-DailySync at $Time ($(Get-TimeZone | Select-Object -ExpandProperty Id))."
