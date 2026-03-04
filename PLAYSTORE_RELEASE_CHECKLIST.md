# Play Store Release Checklist (Android)

This project is currently set to:
- `applicationId`: `com.kinetix.past_question_paper`
- `version`: `0.1.6+8`

## 0) Branch Promotion Flow (Required)

Use this release path every time:
1. Feature/fix branches → `develop`
2. `develop` → `staging` (QA/UAT signoff)
3. `staging` → `master` (release branch)
4. Build and upload from `master`

Open PR from `develop` to `staging`:

```bash
git checkout develop
git pull origin develop
git push origin develop
# Open PR: base=staging, compare=develop
```

Open PR from `staging` to `master`:

```bash
git checkout staging
git pull origin staging
git push origin staging
# Open PR: base=master, compare=staging
```

## 1) Verify release signing files

`android/app/build.gradle.kts` expects:
- `android/app/key.properties`
- keystore path from `storeFile` inside `key.properties`

Example `android/app/key.properties`:

```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=upload-keystore.jks
```

If you still need to create the upload keystore:

```bash
keytool -genkey -v -keystore android/app/upload-keystore.jks -alias upload -keyalg RSA -keysize 2048 -validity 10000
```

## 2) Run pre-release checks

```bash
flutter pub get
flutter test
flutter analyze
```

## 3) Build Android App Bundle (AAB)

```bash
git checkout master
git pull origin master
flutter clean
flutter pub get
flutter build appbundle --release
```

Expected output:
- `build/app/outputs/bundle/release/app-release.aab`

## 4) Upload to Google Play Console

1. Open Play Console → your app.
2. Go to **Testing** (Internal/Closed) or **Production**.
3. Create new release.
4. Upload `app-release.aab`.
5. Add release notes.
6. Review warnings/errors and submit rollout.

## 5) Post-upload checks

- Confirm artifact version shows `0.1.6 (8)`.
- Verify app signing status is healthy.
- Monitor pre-launch report and Android vitals.
- Promote from Internal → Closed → Production when stable.

## Notes

- Keep keystore and passwords out of source control.
- If `key.properties` was ever committed, rotate credentials and use a new keystore/password set for safety.
