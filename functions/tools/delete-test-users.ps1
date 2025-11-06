# Quick script to delete test users
# Usage: .\delete-test-users.ps1

Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "🗑️  Delete Test Users - Quick Run Script" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Navigate to functions directory
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$functionsDir = Split-Path -Parent $scriptDir

Write-Host "📁 Navigating to functions directory..." -ForegroundColor Yellow
Set-Location $functionsDir

# Check if node_modules exists
if (-not (Test-Path "node_modules")) {
    Write-Host "⚠️  node_modules not found. Installing dependencies..." -ForegroundColor Yellow
    npm install
}

# Run the deletion script
Write-Host ""
Write-Host "🚀 Running deletion script..." -ForegroundColor Green
Write-Host ""

node tools/deleteTestUsers.js

Write-Host ""
Write-Host "✨ Script completed!" -ForegroundColor Green
Write-Host ""
Write-Host "💡 Remember to:" -ForegroundColor Cyan
Write-Host "   1. Edit TEST_USER_EMAILS in tools/deleteTestUsers.js" -ForegroundColor White
Write-Host "   2. Run a dry run first (DRY_RUN = true)" -ForegroundColor White
Write-Host "   3. Check the summary before confirming" -ForegroundColor White
Write-Host ""
