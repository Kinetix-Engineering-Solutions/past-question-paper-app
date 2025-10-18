#!/bin/bash
# 🔄 Quick Package Name Update Script
# This script helps you update package names across your Flutter project

echo "═══════════════════════════════════════════════"
echo "  Flutter App Package Name Update Helper"
echo "═══════════════════════════════════════════════"
echo ""

# Current configuration
echo "📋 CURRENT CONFIGURATION:"
echo "  Package name in pubspec.yaml:"
grep "^name:" pubspec.yaml
echo ""
echo "  Android package ID in build.gradle:"
grep "applicationId" android/app/build.gradle | head -1
echo ""
echo "  Android package in AndroidManifest.xml:"
grep "package=" android/app/src/main/AndroidManifest.xml | head -1
echo ""

# Get new names
echo "═══════════════════════════════════════════════"
echo "📝 ENTER NEW CONFIGURATION:"
echo ""
read -p "New app name (e.g., 'past_papers_pro'): " NEW_APP_NAME
read -p "New package ID (e.g., 'com.kinetix.pastpapers'): " NEW_PACKAGE_ID
read -p "New app display name (e.g., 'Past Papers Pro'): " NEW_DISPLAY_NAME
echo ""

# Confirm
echo "═══════════════════════════════════════════════"
echo "🔍 REVIEW YOUR CHANGES:"
echo ""
echo "  App Name (pubspec.yaml):     $NEW_APP_NAME"
echo "  Package ID (Android):        $NEW_PACKAGE_ID"
echo "  Display Name (User-facing):  $NEW_DISPLAY_NAME"
echo ""
read -p "Continue with these changes? (y/n): " CONFIRM

if [ "$CONFIRM" != "y" ]; then
    echo "❌ Cancelled. No changes made."
    exit 0
fi

echo ""
echo "═══════════════════════════════════════════════"
echo "🚀 STARTING UPDATE PROCESS..."
echo ""

# Get old package name from pubspec.yaml
OLD_APP_NAME=$(grep "^name:" pubspec.yaml | cut -d' ' -f2)
echo "✅ Detected old app name: $OLD_APP_NAME"

# Step 1: Update pubspec.yaml
echo ""
echo "📝 Step 1/7: Updating pubspec.yaml..."
sed -i "s/^name: .*/name: $NEW_APP_NAME/" pubspec.yaml
echo "   ✅ Done"

# Step 2: Update import statements
echo ""
echo "📝 Step 2/7: Updating import statements in all Dart files..."
find lib -name "*.dart" -type f -exec sed -i "s/package:$OLD_APP_NAME\//package:$NEW_APP_NAME\//g" {} +
echo "   ✅ Done"

# Step 3: Update android/app/build.gradle
echo ""
echo "📝 Step 3/7: Updating android/app/build.gradle..."
sed -i "s/namespace = \".*\"/namespace = \"$NEW_PACKAGE_ID\"/" android/app/build.gradle.kts
sed -i "s/applicationId = \".*\"/applicationId = \"$NEW_PACKAGE_ID\"/" android/app/build.gradle.kts
# Also try .gradle (without .kts)
if [ -f "android/app/build.gradle" ]; then
    sed -i "s/namespace \".*\"/namespace \"$NEW_PACKAGE_ID\"/" android/app/build.gradle
    sed -i "s/applicationId \".*\"/applicationId \"$NEW_PACKAGE_ID\"/" android/app/build.gradle
fi
echo "   ✅ Done"

# Step 4: Update AndroidManifest.xml
echo ""
echo "📝 Step 4/7: Updating AndroidManifest.xml..."
sed -i "s/package=\".*\"/package=\"$NEW_PACKAGE_ID\"/" android/app/src/main/AndroidManifest.xml
sed -i "s/android:label=\".*\"/android:label=\"$NEW_DISPLAY_NAME\"/" android/app/src/main/AndroidManifest.xml
echo "   ✅ Done"

# Step 5: Update web files
echo ""
echo "📝 Step 5/7: Updating web configuration..."
if [ -f "web/index.html" ]; then
    sed -i "s/<title>.*<\/title>/<title>$NEW_DISPLAY_NAME<\/title>/" web/index.html
    echo "   ✅ Updated web/index.html"
fi
if [ -f "web/manifest.json" ]; then
    # This is more complex for JSON, skip for now
    echo "   ⚠️  Please manually update web/manifest.json"
fi

# Step 6: Note about MainActivity.kt
echo ""
echo "📝 Step 6/7: MainActivity.kt and folder structure..."
echo "   ⚠️  MANUAL STEP REQUIRED:"
echo "      1. Rename folder structure in: android/app/src/main/kotlin/"
echo "      2. Update package declaration in MainActivity.kt"
echo "      3. Example: package $NEW_PACKAGE_ID"

# Step 7: Firebase configuration
echo ""
echo "📝 Step 7/7: Firebase configuration..."
echo "   ⚠️  MANUAL STEPS REQUIRED:"
echo "      1. Update/replace google-services.json"
echo "      2. Run: flutterfire configure --project=your-project-id"

echo ""
echo "═══════════════════════════════════════════════"
echo "✅ AUTOMATED UPDATES COMPLETE!"
echo "═══════════════════════════════════════════════"
echo ""
echo "⚠️  MANUAL STEPS REMAINING:"
echo ""
echo "1. 📁 Rename Kotlin folder structure:"
echo "   android/app/src/main/kotlin/[package/path]/"
echo ""
echo "2. 📝 Update MainActivity.kt package declaration:"
echo "   package $NEW_PACKAGE_ID"
echo ""
echo "3. 🔥 Update Firebase configuration:"
echo "   - Replace android/app/google-services.json"
echo "   - Run: flutterfire configure"
echo ""
echo "4. 🧹 Clean and rebuild:"
echo "   flutter clean"
echo "   flutter pub get"
echo "   flutter analyze"
echo "   flutter run"
echo ""
echo "📚 See APP_ID_TRANSFER_GUIDE.md for detailed instructions"
echo ""
