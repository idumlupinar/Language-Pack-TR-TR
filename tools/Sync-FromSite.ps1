<#
.SYNOPSIS
    Copies the tr-TR resource files from a working DNN Platform site into this repository.

.DESCRIPTION
    Searches the DNN Platform site for *.tr-TR.resx files and copies them into the Resources
    folder, keeping the same relative folder structure DNN Platform uses at install time.

    Skipped on purpose:
      - App_Data, bin, Install\Temp and other non-resource folders
      - Portals\<id>\ folders (those hold per-site overrides, not the language pack);
        only Portals\_default is taken

    Run tools\Build-Manifest.ps1 afterwards to refresh the .dnn manifest.

.PARAMETER SitePath
    Root folder of the DNN Platform site (the folder that contains web.config).

.PARAMETER Mirror
    Also delete tr-TR files from Resources that no longer exist on the site.

.EXAMPLE
    .\tools\Sync-FromSite.ps1 -SitePath C:\Webs\dnndev.com
    .\tools\Build-Manifest.ps1
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [string] $SitePath,

    [string] $Culture = 'tr-TR',

    [switch] $Mirror
)

$ErrorActionPreference = 'Stop'

$site = (Resolve-Path $SitePath).Path.TrimEnd('\', '/')
if (-not (Test-Path (Join-Path $site 'web.config'))) {
    throw "'$site' does not look like a DNN Platform site root (no web.config found)."
}

$repoResources = Join-Path (Split-Path $PSScriptRoot -Parent) 'Resources'
$excluded = '^(App_Data|bin|obj|Install[\\/]Temp|Portals[\\/](?!_default[\\/]))'

$sourceFiles = Get-ChildItem -Path $site -Recurse -File -Filter "*.$Culture.resx" |
    ForEach-Object { [pscustomobject]@{ File = $_; Relative = $_.FullName.Substring($site.Length + 1) } } |
    Where-Object { $_.Relative -notmatch $excluded }

$copied = 0
foreach ($item in $sourceFiles) {
    $target = Join-Path $repoResources $item.Relative
    $targetDir = Split-Path $target -Parent
    if (-not (Test-Path $targetDir)) {
        New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
    }

    $isChanged = -not (Test-Path $target) -or
        (Get-FileHash $target).Hash -ne (Get-FileHash $item.File.FullName).Hash
    if ($isChanged -and $PSCmdlet.ShouldProcess($item.Relative, 'Copy')) {
        Copy-Item -Path $item.File.FullName -Destination $target -Force
        $copied++
    }
}

$removed = 0
if ($Mirror) {
    $wanted = @{}
    $sourceFiles | ForEach-Object { $wanted[$_.Relative.ToLowerInvariant()] = $true }
    Get-ChildItem -Path $repoResources -Recurse -File -Filter "*.$Culture.resx" | ForEach-Object {
        $relative = $_.FullName.Substring($repoResources.Length + 1)
        if (-not $wanted.ContainsKey($relative.ToLowerInvariant()) -and $PSCmdlet.ShouldProcess($relative, 'Remove')) {
            Remove-Item $_.FullName
            $removed++
        }
    }
}

Write-Host "Found $(@($sourceFiles).Count) $Culture files on the site; $copied copied/updated, $removed removed."
Write-Host "Next: run tools\Build-Manifest.ps1 to update the manifest."
