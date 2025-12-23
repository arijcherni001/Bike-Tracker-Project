# Script to patch flutter_bluetooth_serial namespace issue
Write-Host "Patching flutter_bluetooth_serial..." -ForegroundColor Cyan

# Find the plugin directory
$pluginPath = Get-ChildItem -Path "$env:LOCALAPPDATA\Pub\Cache\git" -Directory -Filter "flutter_bluetooth_serial*" | Select-Object -First 1

if ($null -eq $pluginPath) {
    Write-Host "Error: flutter_bluetooth_serial not found in cache!" -ForegroundColor Red
    exit 1
}

$buildGradlePath = Join-Path $pluginPath.FullName "android\build.gradle"
$manifestPath = Join-Path $pluginPath.FullName "android\src\main\AndroidManifest.xml"

if (-not (Test-Path $buildGradlePath)) {
    Write-Host "Error: build.gradle not found at $buildGradlePath" -ForegroundColor Red
    exit 1
}

Write-Host "Found: $buildGradlePath" -ForegroundColor Green

# Patch build.gradle
$content = Get-Content $buildGradlePath -Raw

# Check if namespace already exists
if ($content -notmatch "namespace\s+") {
    # Find the android block and add namespace
    $pattern = '(?s)(android\s*\{)'
    $replacement = '$1' + "`n    namespace 'io.github.edufolly.flutterbluetoothserial'"

    if ($content -match $pattern) {
        $newContent = $content -replace $pattern, $replacement
        
        # Backup original
        $backupPath = $buildGradlePath + ".backup"
        if (-not (Test-Path $backupPath)) {
            Copy-Item $buildGradlePath $backupPath
        }
        
        # Write patched content
        Set-Content -Path $buildGradlePath -Value $newContent -NoNewline
        Write-Host "Added namespace to build.gradle" -ForegroundColor Green
    }
} else {
    Write-Host "Namespace already exists in build.gradle" -ForegroundColor Yellow
}

# Patch AndroidManifest.xml
if (Test-Path $manifestPath) {
    Write-Host "Found: $manifestPath" -ForegroundColor Green
    
    $manifestContent = Get-Content $manifestPath -Raw
    
    # Check if package attribute exists
    if ($manifestContent -match 'package="[^"]*"') {
        # Backup original
        $manifestBackupPath = $manifestPath + ".backup"
        if (-not (Test-Path $manifestBackupPath)) {
            Copy-Item $manifestPath $manifestBackupPath
        }
        
        # Remove package attribute from manifest tag
        $newManifestContent = $manifestContent -replace '\s+package="[^"]*"', ''
        
        # Write patched content
        Set-Content -Path $manifestPath -Value $newManifestContent -NoNewline
        Write-Host "Removed package attribute from AndroidManifest.xml" -ForegroundColor Green
    } else {
        Write-Host "AndroidManifest.xml already patched (no package attribute)" -ForegroundColor Yellow
    }
} else {
    Write-Host "Warning: AndroidManifest.xml not found at $manifestPath" -ForegroundColor Yellow
}

Write-Host "`nPatch completed successfully!" -ForegroundColor Cyan
