#!/bin/bash
# Deploy Admin Portal to Firebase Hosting

echo "========================================"
echo "Building Admin Portal for Web"
echo "========================================"

# Build Flutter web app targeting admin entry point
flutter build web --target=lib/main_admin.dart --output=build/web_admin

if [ $? -ne 0 ]; then
    echo "Build failed!"
    exit 1
fi

echo ""
echo "========================================"
echo "Deploying to Firebase Hosting"
echo "========================================"

# Deploy to Firebase Hosting (admin target)
firebase deploy --only hosting:admin

if [ $? -ne 0 ]; then
    echo "Deployment failed!"
    exit 1
fi

echo ""
echo "========================================"
echo "Deployment Complete!"
echo "========================================"
echo "Your admin portal is now live at:"
echo "https://vibe-code-4c59f.web.app"
echo "========================================"
