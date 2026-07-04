# Personal OS Dashboard

AI-powered personal productivity operating system built with Flutter.

## Features

- Dashboard with analytics and productivity insights
- Tasks, projects, goals, calendar, and meetings
- CRM (contacts and companies)
- Notes with checklists and attachments
- Document management with PDF/Excel export
- Push notification reminders (FCM)
- Settings: theme, language, security, backup

## Tech stack

- **Flutter** + **Riverpod** + **GoRouter** + **GetIt**
- **Supabase** (auth, database, storage)
- **Firebase Cloud Messaging** (push notifications)
- **Hive** (local cache)

## Getting started

```bash
flutter pub get
cp .env.example .env
# Edit .env with your Supabase credentials
flutter run
```

## Production Android build

See [docs/PLAY_STORE_RELEASE.md](docs/PLAY_STORE_RELEASE.md).

```bash
cp env.prod.example.json env.prod.json
# Fill in production credentials
./scripts/build_android_release.sh
```

## Project structure

```
lib/
├── core/           # DI, routing, theme, network, storage
├── features/       # Feature modules (domain/data/presentation)
├── app.dart        # Root widget
└── main.dart       # Entry point
```

## License

Private — all rights reserved.
