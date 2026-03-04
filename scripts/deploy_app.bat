@echo off
REM Deploy Main App to Firebase Hosting
echo ========================================
echo Building Main App for Web
echo ========================================

REM Build Flutter web app targeting main entry point
flutter build web --target=lib/main.dart --output=build/web

if %ERRORLEVEL% NEQ 0 (
    echo Build failed!
    exit /b %ERRORLEVEL%
)

echo.
echo ========================================
echo Deploying to Firebase Hosting
echo ========================================

REM Deploy to Firebase Hosting (app target)
firebase deploy --only hosting:app

if %ERRORLEVEL% NEQ 0 (
    echo Deployment failed!
    exit /b %ERRORLEVEL%
)

echo.
echo ========================================
echo Deployment Complete!
echo ========================================
echo Your main app is now live at the domain mapped to site:
echo vibe-code-4c59f
echo ========================================
