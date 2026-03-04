#!/bin/bash
# Deploy Main App to Firebase Hosting

echo "========================================"
echo "Building Main App for Web"
echo "========================================"

# Build Flutter web app targeting main entry point
flutter build web --target=lib/main.dart --output=build/web

if [ $? -ne 0 ]; then
    echo "Build failed!"
    exit 1
fi

echo ""
echo "========================================"
echo "Deploying to Firebase Hosting"
echo "========================================"

# Deploy to Firebase Hosting (app target)
firebase deploy --only hosting:app

if [ $? -ne 0 ]; then
    echo "Deployment failed!"
    exit 1
fi

echo ""
echo "========================================"
echo "Deployment Complete!"
echo "========================================"
echo "Your main app is now live at the domain mapped to site:"
echo "vibe-code-4c59f"
echo "========================================"
