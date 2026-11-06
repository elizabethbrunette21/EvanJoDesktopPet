#requires -Version 5.1
$ErrorActionPreference = 'Stop'

$source = Join-Path $PSScriptRoot 'EvanJoDesktopPet.Windows.exe'
if (-not (Test-Path -LiteralPath $source)) {
    throw 'Keep Install.cmd, Install.ps1, and EvanJoDesktopPet.Windows.exe in the same folder.'
}

$installDir = Join-Path $env:LOCALAPPDATA 'Programs\EvanJoDesktopPet'
$target = Join-Path $installDir 'EvanJoDesktopPet.Windows.exe'
New-Item -ItemType Directory -Force -Path $installDir | Out-Null
$needsCopy = -not (Test-Path -LiteralPath $target) -or
    (Get-FileHash -LiteralPath $source).Hash -ne (Get-FileHash -LiteralPath $target).Hash
$running = Get-Process -Name 'EvanJoDesktopPet.Windows' -ErrorAction SilentlyContinue
if ($needsCopy -and $running) {
    throw 'Quit Evan Jo Desktop Pet from its right-click menu before installing an update.'
}
if ($needsCopy) {
    Copy-Item -LiteralPath $source -Destination $target -Force
}

$desktop = [Environment]::GetFolderPath('DesktopDirectory')
if (-not $desktop) {
    throw 'Windows desktop folder could not be found.'
}

$shortcutPath = Join-Path $desktop 'Evan Jo Desktop Pet.lnk'
$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = $target
$shortcut.WorkingDirectory = $installDir
$shortcut.IconLocation = $target
$shortcut.Description = 'Evan Jo Desktop Pet'
$shortcut.Save()

if (-not $running) {
    Start-Process -FilePath $target -WorkingDirectory $installDir
}
Write-Host "Installed application: $target"
Write-Host "Desktop shortcut: $shortcutPath"
