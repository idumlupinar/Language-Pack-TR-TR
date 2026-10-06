<#
.SYNOPSIS
    Generates (or verifies) Resources\DNNCE_tr-TR.dnn from the resource files in Resources.

.DESCRIPTION
    The manifest is built from the *.tr-TR.resx files that exist in the repository, so it
    can never list a file that is missing or forget one that was added.

    Files are grouped into one CoreLanguagePack plus one ExtensionLanguagePack per DNN Platform
    extension, using the folder -> package map below. Package names must match the
    names in the DNN Platform "Packages" table; anything not matched goes into the core pack.

    Note: DNN Platform's built-in "Create Language Pack > Full" export puts every file into every
    library package (Newtonsoft.Json, MailKit, ...). Use this script instead.

.PARAMETER Version
    Manifest version (DNN Platform format, e.g. 10.04.00). Defaults to the version already in
    the manifest. Release branches update it automatically (see .github/workflows).

.PARAMETER Check
    Do not write anything. Fail if any resx file is not valid XML or if the committed
    manifest differs from what this script would generate. Used by CI.
#>
[CmdletBinding()]
param(
    [ValidatePattern('^\d{2}\.\d{2}\.\d{2}$')]
    [string] $Version,

    [switch] $Check
)

$ErrorActionPreference = 'Stop'

$Culture = 'tr-TR'
$DisplayName = 'Türkçe (Türkiye)'
$EnglishName = 'Turkish (Türkiye)'
$Owner = [ordered]@{
    name         = 'DNN Platform'
    organization = '.NET Foundation'
    url          = 'https://www.dnncommunity.org'
    email        = 'info@dnncommunity.org'
}

# Folder prefix (relative to Resources, '/' separated) -> DNN Platform package name. First match wins.
$PackageMap = [ordered]@{
    'DesktopModules/Admin/Dnn.EditBar/'                                  = 'Dnn.EditBar.UI'
    'DesktopModules/Admin/Dnn.PersonaBar/'                               = 'Dnn.PersonaBar.UI'
    'DesktopModules/Admin/Console/'                                      = 'DotNetNuke.Console'
    'DesktopModules/Admin/HtmlEditorManager/'                            = 'DotNetNuke.HtmlEditorManager'
    'DesktopModules/AuthenticationServices/DNN/'                         = 'DefaultAuthentication'
    'DesktopModules/Connectors/Azure/'                                   = 'Dnn.AzureConnector'
    'DesktopModules/Connectors/GoogleAnalytics4/'                        = 'DNN.Connectors.GoogleAnalytics4'
    'DesktopModules/Connectors/GoogleAnalytics/'                         = 'DNN.Connectors.GoogleAnalytics'
    'DesktopModules/Connectors/GoogleTagManager/'                        = 'DNN.Connectors.GoogleTagManager'
    'DesktopModules/CoreMessaging/'                                      = 'DotNetNuke.Modules.CoreMessaging'
    'DesktopModules/DDRMenu/'                                            = 'DDRMenu'
    'DesktopModules/HTML/'                                               = 'DNN_HTML'
    'DesktopModules/Journal/'                                            = 'Journal'
    'DesktopModules/MemberDirectory/'                                    = 'DotNetNuke.Modules.MemberDirectory'
    'DesktopModules/RazorModules/RazorHost/'                             = 'DNNCorp.RazorHost'
    'DesktopModules/ResourceManager/'                                    = 'ResourceManager'
    'DesktopModules/SiteExportImport/'                                   = 'SiteExportImport'
    'DesktopModules/SocialGroups/'                                       = 'Social Groups'
    'Providers/ClientCapabilityProviders/AspNetClientCapabilityProvider/' = 'AspNetClientCapabilityProvider'
    'Providers/FolderProviders/'                                         = 'DotNetNuke.Providers.FolderProviders'
    'Providers/HtmlEditorProviders/DNNConnect.CKE/'                      = 'DNNConnect.CKEditorProvider'
    'Providers/SmtpOAuthProviders/ExchangeOnline/'                       = 'Dnn.ExchangeOnlineAuthProvider'
    'Providers/SmtpOAuthProviders/GoogleMail/'                           = 'Dnn.GoogleMailAuthProvider'
}

$resources = Join-Path (Split-Path $PSScriptRoot -Parent) 'Resources'
$manifestPath = Join-Path $resources "DNNCE_$Culture.dnn"

function Escape([string] $text) { [System.Security.SecurityElement]::Escape($text) }

# --- Validate resource files ------------------------------------------------------------
$files = Get-ChildItem -Path $resources -Recurse -File -Filter "*.$Culture.resx" |
    ForEach-Object { $_.FullName.Substring($resources.Length + 1).Replace('\', '/') } |
    Sort-Object { $_.ToLowerInvariant() }

$errors = @()
foreach ($file in $files) {
    try { [xml](Get-Content -LiteralPath (Join-Path $resources $file) -Raw -Encoding UTF8) | Out-Null }
    catch { $errors += "Invalid XML in ${file}: $($_.Exception.Message)" }
}

# --- Resolve version --------------------------------------------------------------------
if (-not $Version) {
    $Version = '10.04.00'
    if (Test-Path $manifestPath) {
        $existing = [regex]::Match((Get-Content $manifestPath -Raw), '<package [^>]*version="([^"]+)"')
        if ($existing.Success) { $Version = $existing.Groups[1].Value }
    }
}

# --- Group files by package -------------------------------------------------------------
$groups = [ordered]@{ 'Core' = [System.Collections.Generic.List[string]]::new() }
foreach ($package in $PackageMap.Values) {
    if (-not $groups.Contains($package)) { $groups[$package] = [System.Collections.Generic.List[string]]::new() }
}
foreach ($file in $files) {
    $package = 'Core'
    foreach ($prefix in $PackageMap.Keys) {
        if ($file.StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase)) { $package = $PackageMap[$prefix]; break }
    }
    $groups[$package].Add($file)
}

# --- Write XML --------------------------------------------------------------------------
$sb = [System.Text.StringBuilder]::new()
function Line([string] $text) { [void]$sb.Append($text).Append("`r`n") }

Line '<dotnetnuke type="Package" version="5.0">'
Line '  <packages>'
foreach ($package in $groups.Keys) {
    $packageFiles = $groups[$package]
    if ($packageFiles.Count -eq 0) { continue }
    $isCore = $package -eq 'Core'

    if ($isCore) {
        Line "    <package name=`"Core_$Culture`" type=`"CoreLanguagePack`" version=`"$Version`">"
        Line "      <friendlyName>DNN Platform Core $(Escape $DisplayName)</friendlyName>"
        Line "      <description>$(Escape $EnglishName) core language pack for DNN Platform.</description>"
    }
    else {
        Line "    <package name=`"$(Escape $package)_$Culture`" type=`"ExtensionLanguagePack`" version=`"$Version`">"
        Line "      <friendlyName>$(Escape $package) $(Escape $DisplayName)</friendlyName>"
        Line "      <description>$(Escape $EnglishName) language pack for $(Escape $package).</description>"
    }
    Line '      <iconFile />'
    Line '      <owner>'
    foreach ($key in $Owner.Keys) { Line "        <$key>$(Escape $Owner[$key])</$key>" }
    Line '      </owner>'
    Line '      <license src="license.txt" />'
    Line '      <releaseNotes src="ReleaseNotes.txt" />'
    Line '      <components>'
    Line "        <component type=`"$(if ($isCore) { 'CoreLanguage' } else { 'ExtensionLanguage' })`">"
    Line '          <languageFiles>'
    Line "            <code>$Culture</code>"
    if ($isCore) {
        Line "            <displayName>$(Escape $DisplayName)</displayName>"
        Line '            <fallback>en-US</fallback>'
    }
    else {
        Line "            <package>$(Escape $package)</package>"
        Line '            <basePath />'
    }
    foreach ($file in $packageFiles) {
        $slash = $file.LastIndexOf('/')
        Line '            <languageFile>'
        Line "              <path>$(Escape $file.Substring(0, [Math]::Max($slash, 0)).Replace('/', '\'))</path>"
        Line "              <name>$(Escape $file.Substring($slash + 1))</name>"
        Line '            </languageFile>'
    }
    Line '          </languageFiles>'
    Line '        </component>'
    Line '      </components>'
    Line '    </package>'
}
Line '  </packages>'
Line '</dotnetnuke>'
$content = $sb.ToString()

# --- Output -----------------------------------------------------------------------------
$summary = ($groups.Keys | Where-Object { $groups[$_].Count } | ForEach-Object { "  {0,4}  {1}" -f $groups[$_].Count, $_ }) -join "`n"

if ($Check) {
    if (-not (Test-Path $manifestPath)) {
        $errors += "Manifest $manifestPath is missing. Run tools/Build-Manifest.ps1."
    }
    else {
        # Compare package/file pairs rather than raw text: the release workflow rewrites
        # versions with a tool that may format the XML differently.
        function Entries([xml] $xml) {
            $xml.SelectNodes('//package[@name]') | ForEach-Object {
                $name = $_.name
                $_.SelectNodes('.//languageFile') | ForEach-Object { "$name | $($_.path)\$($_.name)".ToLowerInvariant() }
            } | Sort-Object
        }
        $diff = Compare-Object @(Entries ([xml](Get-Content $manifestPath -Raw -Encoding UTF8))) @(Entries ([xml]$content))
        foreach ($d in $diff) {
            $errors += "Manifest out of date ($(if ($d.SideIndicator -eq '<=') { 'extra' } else { 'missing' })): $($d.InputObject)"
        }
        if ($diff) { $errors += 'Run tools/Build-Manifest.ps1 and commit the result.' }
    }
    if ($errors) { $errors | ForEach-Object { Write-Error $_ -ErrorAction Continue }; exit 1 }
    Write-Host "OK: $($files.Count) files, manifest up to date (version $Version).`n$summary"
    exit 0
}

if ($errors) { $errors | ForEach-Object { Write-Error $_ -ErrorAction Continue }; exit 1 }
[System.IO.File]::WriteAllText($manifestPath, $content, [System.Text.UTF8Encoding]::new($false))
Write-Host "Wrote $manifestPath (version $Version, $($files.Count) files):`n$summary"
