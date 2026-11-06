#requires -Version 5.1
param(
    [string]$Dotnet = 'dotnet'
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$project = Join-Path $projectRoot 'src\EvanJoDesktopPet.Windows\EvanJoDesktopPet.Windows.csproj'
$dist = Join-Path $projectRoot 'dist'
$publish = Join-Path $dist 'publish'
$package = Join-Path $dist 'EvanJoDesktopPet-Windows-x64'
$archive = "$package.zip"
$nugetConfig = Join-Path $dist 'NuGet.Config'

New-Item -ItemType Directory -Force -Path $publish, $package | Out-Null
$env:NUGET_PACKAGES = Join-Path $dist 'nuget-packages'
@'
<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <packageSources>
    <clear />
    <add key="nuget.org" value="https://api.nuget.org/v3/index.json" />
  </packageSources>
</configuration>
'@ | Set-Content -LiteralPath $nugetConfig -Encoding UTF8

& $Dotnet publish $project --configuration Release --runtime win-x64 --self-contained true `
    -p:RestoreConfigFile=$nugetConfig `
    -p:PublishSingleFile=true `
    -p:IncludeNativeLibrariesForSelfExtract=true `
    -p:EnableCompressionInSingleFile=true `
    -p:DebugType=None `
    -p:DebugSymbols=false `
    --output $publish
if ($LASTEXITCODE -ne 0) {
    throw "dotnet publish failed with exit code $LASTEXITCODE."
}

$exe = Join-Path $publish 'EvanJoDesktopPet.Windows.exe'
if (-not (Test-Path -LiteralPath $exe)) {
    throw "Published application was not found: $exe"
}

Copy-Item -LiteralPath $exe -Destination $package -Force
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'Install.cmd') -Destination $package -Force
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'Install.ps1') -Destination $package -Force
Compress-Archive -Path (Join-Path $package '*') -DestinationPath $archive -Force

Write-Host "Windows download package: $archive"
