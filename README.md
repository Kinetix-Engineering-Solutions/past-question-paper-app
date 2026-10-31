# Past Papers

Past Papers is a study app for South African high-school learners. It currently focuses on Grade 12 Mathematics and Physical Sciences.

Instead of presenting an entire examination paper at once, the app organises past-paper questions by subject and topic for focused, one-question-at-a-time practice. Learners are encouraged to work through each question on paper before revealing the official memo.

The app complements classroom learning and full timed-paper practice; it is not intended to replace either. Past Papers is an independent product and is not an official application of the South African Department of Basic Education (DBE).

## How it works

1. Choose a subject and topic.
2. Attempt a past-paper question on paper.
3. Reveal the official memo and review the solution.
4. Save difficult questions or track progress for later revision.

## Access and features

Guests can:

- Browse subjects, topics, and published questions.
- Filter questions by examination year, season, and question number.
- Reveal official question memos.

Learners with an account can also:

- Save and bookmark questions.
- Track question and topic progress.
- Keep a collection of questions that need review.
- Participate in moderated question discussions.

## Architecture

The app uses a feature-first Flutter architecture with Riverpod for state management:

```text
Flutter UI
  -> Riverpod providers and controllers
  -> Repositories
  -> ASP.NET Core Content API and Supabase
```

The Content API serves public curriculum content. Supabase provides authentication, learner data, discussions, and image storage.

## Getting started

Install the Flutter dependencies:

```powershell
flutter pub get
```

Copy `config/example.json` to `config/dev.json`, then set these public client values:

- `CONTENT_API_BASE_URL`
- `SUPABASE_URL`
- `SUPABASE_PUBLISHABLE_KEY`

Run the app:

```powershell
flutter run --dart-define-from-file=config/dev.json
```

The development and production configuration files are excluded from version control.

## Validation

```powershell
flutter analyze
flutter test
```

## Android release

Create `config/production.json` with the production public client configuration, then build the Android App Bundle:

```powershell
flutter build appbundle --release --dart-define-from-file=config/production.json
```

The bundle is generated at `build/app/outputs/bundle/release/app-release.aab`.

Release signing is configured in `android/key.properties`. Never commit that file or the signing keystore.

## Security

Only public client configuration belongs in Flutter builds. Never include service-role keys, content-ingestion keys, database connection strings, passwords, or other server credentials.

## Support

For support, privacy enquiries, or account-deletion assistance, email [kinetixse@gmail.com](mailto:kinetixse@gmail.com).
