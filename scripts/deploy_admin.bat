@echo off
REM Deploy Admin Portal to Firebase Hosting
echo ========================================
echo Building Admin Portal for Web
echo ========================================

REM Build Flutter web app targeting admin entry point
flutter build web --target=lib/main_admin.dart --output=build/web_admin

if %ERRORLEVEL% NEQ 0 (
    echo Build failed!
    exit /b %ERRORLEVEL%
)

echo.
echo ========================================
echo Deploying to Firebase Hosting
echo ========================================

REM Deploy to Firebase Hosting (admin target)
firebase deploy --only hosting:admin

if %ERRORLEVEL% NEQ 0 (
    echo Deployment failed!
    exit /b %ERRORLEVEL%
)

echo.
echo ========================================
echo Deployment Complete!
echo ========================================
echo Your admin portal was deployed to hosting target: admin
echo Map your admin custom domain ^(e.g. admin.pastquestionpapers.com^)
echo to Firebase site: vibe-code-4c59f-admin
echo ========================================
