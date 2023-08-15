# Kill processes for Chrome, Microsoft Edge, and Firefox
Get-Process -Name chrome, msedge, firefox -ErrorAction SilentlyContinue | Stop-Process -Force

# Path to Chrome's Preferences file
$pathToPreferences = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Preferences"

# Create and modify Chrome Preferences
if (Test-Path $pathToPreferences) {
    # Backup Chrome's Preferences file
    $backupPath = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Preferences_backup_" + (Get-Date -Format "yyyyMMddHHmmss") + ".json"
    Copy-Item -Path $pathToPreferences -Destination $backupPath
    
    # Modify Chrome's Preferences
    $preferencesJson = Get-Content -Path $pathToPreferences -Encoding UTF8 | ConvertFrom-Json
    $newStructure = @{
        webprefs = @{
            fonts = @{
                standard = @{ Zyyy = "Trebuchet MS" }
                serif = @{ Zyyy = "Trebuchet MS" }
                sansserif = @{ Zyyy = "Trebuchet MS" }
                fixed = @{ Zyyy = "Trebuchet MS" }
                math = @{ Zyyy = "Trebuchet MS" }
            }
        }
    }
    if ($null -eq $preferencesJson.webkit) {
        $preferencesJson | Add-Member -MemberType NoteProperty -Name "webkit" -Value $newStructure
    } else {
        $preferencesJson.webkit | Add-Member -MemberType NoteProperty -Name "webprefs" -Value $newStructure.webprefs -Force
    }
    $preferencesJson | ConvertTo-Json -Depth 100 | Out-File $pathToPreferences -Encoding UTF8
}

# Modify Edge Preferences
$baseDirs = @(
    "$env:LOCALAPPDATA\Microsoft\Edge\User Data",
    "$env:LOCALAPPDATA\Microsoft\Edge SxS\User Data"
)
foreach ($baseDir in $baseDirs) {
    $profileDirs = Get-ChildItem -Path $baseDir -Directory -ErrorAction SilentlyContinue
    foreach ($profileDir in $profileDirs) {
        $pathToPreferences = Join-Path $profileDir.FullName "Preferences"
        if (Test-Path $pathToPreferences) {
            $backupPath = $pathToPreferences + "_backup_" + (Get-Date -Format "yyyyMMddHHmmss") + ".json"
            Copy-Item -Path $pathToPreferences -Destination $backupPath
            $preferencesJson = Get-Content -Path $pathToPreferences -Encoding UTF8 | ConvertFrom-Json
            $newStructure = @{
                webprefs = @{
                    fonts = @{
                        standard = @{ Zyyy = "Trebuchet MS" }
                        serif = @{ Zyyy = "Trebuchet MS" }
                        sansserif = @{ Zyyy = "Trebuchet MS" }
                        fixed = @{ Zyyy = "Trebuchet MS" }
                    }
                }
            }
            if ($null -eq $preferencesJson.webkit) {
                $preferencesJson | Add-Member -MemberType NoteProperty -Name "webkit" -Value $newStructure
            } else {
                $preferencesJson.webkit | Add-Member -MemberType NoteProperty -Name "webprefs" -Value $newStructure.webprefs -Force
            }
            $preferencesJson | ConvertTo-Json -Depth 100 | Out-File $pathToPreferences -Encoding UTF8
        }
    }
}

# Modify Firefox Preferences
$baseDir = "$env:APPDATA\Mozilla\Firefox\Profiles"
$profileDirs = Get-ChildItem -Path $baseDir -Directory
foreach ($profileDir in $profileDirs) {
    $pathToPrefs = Join-Path $profileDir.FullName "prefs.js"
    if (Test-Path $pathToPrefs) {
        $backupPath = $pathToPrefs + "_backup_" + (Get-Date -Format "yyyyMMddHHmmss")
        Copy-Item -Path $pathToPrefs -Destination $backupPath
        $prefsContent = Get-Content -Path $pathToPrefs
        $fontPreferences = @(
            'user_pref("font.name.variable.x-western", "Trebuchet MS");',
            'user_pref("font.name.serif.x-western", "Trebuchet MS");',
            'user_pref("font.name.sans-serif.x-western", "Trebuchet MS");',
            'user_pref("font.name.monospace.x-western", "Trebuchet MS");'
        )
        foreach ($fontPref in $fontPreferences) {
            if ($prefsContent -notcontains $fontPref) {
                Add-Content -Path $pathToPrefs -Value $fontPref
            }
        }
    }
}
