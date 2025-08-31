# Firebase Setup Guide

This document explains how to properly configure Firebase for this Flutter project.

## ⚠️ IMPORTANT SECURITY NOTICE

**Firebase configuration files contain sensitive API keys and should NEVER be committed to version control!**

The following files are now properly ignored by git:
- `lib/firebase_options.dart`
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `macos/Runner/GoogleService-Info.plist`

## Setup Steps

### 1. Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or use existing project
3. Enable the following services:
   - Authentication
   - Firestore Database
   - Cloud Functions
   - Storage
   - App Check (recommended)

### 2. Configure Flutter App

#### Install FlutterFire CLI (if not already installed)
```bash
dart pub global activate flutterfire_cli
```

#### Initialize Firebase in your project
```bash
flutterfire configure
```

This will:
- Create `lib/firebase_options.dart` with your project's configuration
- Download platform-specific config files
- Update your apps with the necessary configuration

### 3. Platform-Specific Setup

#### Android
- The `google-services.json` file should be placed in `android/app/`
- This file is automatically downloaded by `flutterfire configure`

#### iOS
- The `GoogleService-Info.plist` file should be placed in `ios/Runner/`
- Add it to your Xcode project (Runner target)

#### macOS (if supporting)
- The `GoogleService-Info.plist` file should be placed in `macos/Runner/`
- Add it to your Xcode project (Runner target)

### 4. Update Firebase Security Rules

Update your Firestore security rules in the Firebase Console:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Questions are read-only for authenticated users
    match /questions/{questionId} {
      allow read: if request.auth != null;
    }
    
    // Add more rules as needed for your app
  }
}
```

### 5. Environment Variables (Optional)

For additional security, you can use environment variables:

1. Create a `.env` file (already ignored by git):
```
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_API_KEY=your-api-key
# Add other sensitive configs
```

2. Use the `flutter_dotenv` package to load these values

### 6. App Check Configuration (Recommended)

App Check helps protect your Firebase resources from abuse. Update the configuration in `main.dart`:

```dart
await FirebaseAppCheck.instance.activate(
  webProvider: ReCaptchaV3Provider('your-recaptcha-site-key'),
  androidProvider: AndroidProvider.playIntegrity, // Use playIntegrity for production
  appleProvider: AppleProvider.appAttest, // Use appAttest for production
);
```

For production, replace `debug` providers with proper production providers.

### 7. Testing

After setup, test your Firebase connection:

```bash
flutter run
```

Check the debug console for Firebase initialization messages.

## Troubleshooting

### Common Issues

1. **Firebase not initialized**: Make sure `Firebase.initializeApp()` is called before any Firebase services
2. **Missing permissions**: Check that all necessary permissions are added to platform files
3. **Configuration mismatch**: Ensure package names match between Flutter app and Firebase project

### Debug Mode

For debugging Firebase issues, you can enable debug logging:

```dart
// Add this before Firebase.initializeApp()
if (kDebugMode) {
  FirebaseFirestore.enableNetwork();
}
```

## Support

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/)
