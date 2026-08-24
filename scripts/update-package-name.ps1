# 🔄 Quick Package Name Update Script (PowerShell)
# This script helps you update package names across your Flutter project

Write-Host "═══════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Flutter App Package Name Update Helper" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Current configuration
Write-Host "📋 CURRENT CONFIGURATION:" -ForegroundColor Yellow
Write-Host "  Package name in pubspec.yaml:"
Select-String -Path "pubspec.yaml" -Pattern "^name:" | Select-Object -First 1
Write-Host ""
Write-Host "  Android package ID in build.gradle:"
Select-String -Path "android\app\build.gradle*" -Pattern "applicationId" | Select-Object -First 1
Write-Host ""
Write-Host "  Android package in AndroidManifest.xml:"
Select-String -Path "android\app\src\main\AndroidManifest.xml" -Pattern "package=" | Select-Object -First 1
Write-Host ""

# Get new names
Write-Host "═══════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "📝 ENTER NEW CONFIGURATION:" -ForegroundColor Yellow
Write-Host ""
$NEW_APP_NAME = Read-Host "New app name (e.g., 'past_papers_pro')"
$NEW_PACKAGE_ID = Read-Host "New package ID (e.g., 'com.kinetix.pastpapers')"
$NEW_DISPLAY_NAME = Read-Host "New app display name (e.g., 'Past Papers Pro')"
Write-Host ""

# Confirm
Write-Host "═══════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "🔍 REVIEW YOUR CHANGES:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  App Name (pubspec.yaml):     $NEW_APP_NAME"
Write-Host "  Package ID (Android):        $NEW_PACKAGE_ID"
Write-Host "  Display Name (User-facing):  $NEW_DISPLAY_NAME"
Write-Host ""
$CONFIRM = Read-Host "Continue with these changes? (y/n)"

if ($CONFIRM -ne "y") {
    Write-Host "❌ Cancelled. No changes made." -ForegroundColor Red
    exit
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "🚀 STARTING UPDATE PROCESS..." -ForegroundColor Green
Write-Host ""

# Get old package name from pubspec.yaml
$OLD_APP_NAME = (Select-String -Path "pubspec.yaml" -Pattern "^name:" | Select-Object -First 1).Line -replace "^name:\s*", ""
Write-Host "✅ Detected old app name: $OLD_APP_NAME" -ForegroundColor Green

# Step 1: Update pubspec.yaml
Write-Host ""
Write-Host "📝 Step 1/7: Updating pubspec.yaml..." -ForegroundColor Yellow
$content = Get-Content "pubspec.yaml" -Raw
$content = $content -replace "^name:.*", "name: $NEW_APP_NAME"
Set-Content "pubspec.yaml" -Value $content
Write-Host "   ✅ Done" -ForegroundColor Green

# Step 2: Update import statements
Write-Host ""
Write-Host "📝 Step 2/7: Updating import statements in all Dart files..." -ForegroundColor Yellow
$dartFiles = Get-ChildItem -Path "lib" -Filter "*.dart" -Recurse
foreach ($file in $dartFiles) {
    $content = Get-Content $file.FullName -Raw
    $content = $content -replace "package:$OLD_APP_NAME/", "package:$NEW_APP_NAME/"
    Set-Content $file.FullName -Value $content -NoNewline
}
Write-Host "   ✅ Done" -ForegroundColor Green

# Step 3: Update android/app/build.gradle
Write-Host ""
Write-Host "📝 Step 3/7: Updating android/app/build.gradle..." -ForegroundColor Yellow
# Try build.gradle.kts first
if (Test-Path "android\app\build.gradle.kts") {
    $content = Get-Content "android\app\build.gradle.kts" -Raw
    $content = $content -replace 'namespace = ".*"', "namespace = `"$NEW_PACKAGE_ID`""
    $content = $content -replace 'applicationId = ".*"', "applicationId = `"$NEW_PACKAGE_ID`""
    Set-Content "android\app\build.gradle.kts" -Value $content -NoNewline
    Write-Host "   ✅ Updated build.gradle.kts" -ForegroundColor Green
}
# Also try regular build.gradle
if (Test-Path "android\app\build.gradle") {
    $content = Get-Content "android\app\build.gradle" -Raw
    $content = $content -replace 'namespace ".*"', "namespace `"$NEW_PACKAGE_ID`""
    $content = $content -replace 'applicationId ".*"', "applicationId `"$NEW_PACKAGE_ID`""
    Set-Content "android\app\build.gradle" -Value $content -NoNewline
    Write-Host "   ✅ Updated build.gradle" -ForegroundColor Green
}

# Step 4: Update AndroidManifest.xml
Write-Host ""
Write-Host "📝 Step 4/7: Updating AndroidManifest.xml..." -ForegroundColor Yellow
$content = Get-Content "android\app\src\main\AndroidManifest.xml" -Raw
$content = $content -replace 'package=".*"', "package=`"$NEW_PACKAGE_ID`""
$content = $content -replace 'android:label=".*"', "android:label=`"$NEW_DISPLAY_NAME`""
Set-Content "android\app\src\main\AndroidManifest.xml" -Value $content -NoNewline
Write-Host "   ✅ Done" -ForegroundColor Green

# Step 5: Update web files
Write-Host ""
Write-Host "📝 Step 5/7: Updating web configuration..." -ForegroundColor Yellow
if (Test-Path "web\index.html") {
    $content = Get-Content "web\index.html" -Raw
    $content = $content -replace '<title>.*</title>', "<title>$NEW_DISPLAY_NAME</title>"
    Set-Content "web\index.html" -Value $content -NoNewline
    Write-Host "   ✅ Updated web/index.html" -ForegroundColor Green
}
if (Test-Path "web\manifest.json") {
    Write-Host "   ⚠️  Please manually update web/manifest.json" -ForegroundColor Yellow
}

# Step 6: Note about MainActivity.kt
Write-Host ""
Write-Host "📝 Step 6/7: MainActivity.kt and folder structure..." -ForegroundColor Yellow
Write-Host "   ⚠️  MANUAL STEP REQUIRED:" -ForegroundColor Yellow
Write-Host "      1. Rename folder structure in: android\app\src\main\kotlin\"
Write-Host "      2. Update package declaration in MainActivity.kt"
Write-Host "      3. Example: package $NEW_PACKAGE_ID"

Write-Host ""
Write-Host "═══════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "✅ AUTOMATED UPDATES COMPLETE!" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "⚠️  MANUAL STEPS REMAINING:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. 📁 Rename Kotlin folder structure:" -ForegroundColor Cyan
Write-Host "   android\app\src\main\kotlin\[package\path]\"
Write-Host ""
Write-Host "2. 📝 Update MainActivity.kt package declaration:" -ForegroundColor Cyan
Write-Host "   package $NEW_PACKAGE_ID"
Write-Host ""
Write-Host "3. 🧹 Clean and rebuild:" -ForegroundColor Cyan
Write-Host "   flutter clean"
Write-Host "   flutter pub get"
Write-Host "   flutter analyze"
Write-Host "   flutter run"
Write-Host ""
Write-Host "📚 See APP_ID_TRANSFER_GUIDE.md for detailed instructions" -ForegroundColor Green
Write-Host ""
