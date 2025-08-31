# 🔐 Firebase Security Setup

## ⚠️ IMPORTANT: Firebase Configuration Security

This project requires Firebase configuration files that contain sensitive API keys. **These files must never be committed to version control.**

### Setup Instructions:

#### 1. Copy Template Files
```bash
# Copy the template and add your real keys
cp lib/firebase_options_template.dart lib/firebase_options.dart
```

#### 2. Get Your Firebase Configuration
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project: `vibe-code-4c59f`
3. Go to Project Settings → General
4. Find your app configurations and copy the config values

#### 3. Update firebase_options.dart
Replace the placeholder values in `lib/firebase_options.dart` with your actual Firebase configuration:

```dart
// Replace these placeholders with your real values:
apiKey: 'YOUR_ACTUAL_API_KEY',
appId: 'YOUR_ACTUAL_APP_ID',
projectId: 'vibe-code-4c59f',
// ... etc
```

#### 4. Verify .gitignore
Ensure these files are in your `.gitignore`:
```gitignore
# Firebase configuration files (contains sensitive API keys)
/lib/firebase_options.dart
/android/app/google-services.json
/ios/Runner/GoogleService-Info.plist
```

### Security Best Practices:

1. **Never commit API keys** to version control
2. **Rotate exposed keys immediately** if accidentally committed
3. **Use environment variables** in production/CI environments
4. **Restrict API key permissions** in Firebase Console
5. **Monitor API usage** for suspicious activity

### For Team Members:
Each developer needs to:
1. Get Firebase access from project owner
2. Download their own configuration files
3. Follow setup instructions above
4. Never share or commit these files

### Production Deployment:
Use secure environment variable injection for production builds:
- GitHub Actions Secrets
- Vercel Environment Variables  
- Firebase Hosting Environment Config
