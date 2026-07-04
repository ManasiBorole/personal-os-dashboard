# Play Store Release Guide

## App identity

| Field | Value |
|-------|-------|
| App name | Personal OS |
| Package name | `com.personalos.personal_os_dashboard` |
| Version | 1.0.0 (versionCode 1) |
| Category | Productivity |
| Min SDK | Flutter default (API 21+) |

## Pre-release checklist

### 1. Configuration

1. Copy `env.prod.example.json` → `env.prod.json`
2. Set `APP_ENV` to `prod`
3. Add production Supabase URL and anon key
4. Add Firebase credentials for push notifications

### 2. Signing

1. Generate an upload keystore (one-time):

```bash
keytool -genkey -v -keystore android/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

2. Copy `android/key.properties.example` → `android/key.properties`
3. Fill in keystore passwords and path
4. **Never commit** `key.properties` or `*.jks` files

For Play App Signing, upload the AAB — Google manages the app signing key.

### 3. Build

```bash
chmod +x scripts/build_android_release.sh
./scripts/build_android_release.sh
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### 4. Store listing (Google Play Console)

**Short description (80 chars max):**
> Your AI-powered personal productivity hub — tasks, CRM, notes, and more.

**Full description:**
> Personal OS is your all-in-one productivity operating system. Manage tasks, projects, goals, meetings, calendar events, CRM contacts, notes, and documents from a single dashboard.
>
> Features:
> • Dashboard with productivity analytics
> • Task, project, and goal tracking
> • Calendar and meeting management
> • CRM with contacts and companies
> • Notes with checklists and attachments
> • Document storage and export
> • Push notification reminders
> • Dark mode and multi-language support
> • Secure cloud sync via Supabase

**Graphics required:**
- App icon: 512×512 PNG (use `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png` as base)
- Feature graphic: 1024×500 PNG
- Phone screenshots: min 2, recommended 4–8 (1080×1920 or higher)
- 7-inch and 10-inch tablet screenshots (optional)

### 5. Privacy & compliance

- **Privacy policy URL** — required. Host a policy covering:
  - Data collected (email, profile, user content)
  - Supabase cloud storage
  - Firebase Cloud Messaging (device tokens)
  - Analytics toggle in app settings
- **Data safety form** — declare account info, user-generated content, app activity
- **Content rating** — complete IARC questionnaire (likely Everyone / 3+)
- **Target audience** — 18+ if no children's features

### 6. Release tracks

1. **Internal testing** — upload AAB, add tester emails
2. **Closed testing** — broader QA group
3. **Open testing** — optional public beta
4. **Production** — staged rollout recommended (start at 10%)

## Security notes

- Release builds disable cleartext HTTP (`usesCleartextTraffic=false`)
- Router debug logging disabled when `APP_ENV=prod`
- Logger level set to `warning` in production
- Code obfuscation enabled via `--obfuscate`
- R8 minification and resource shrinking enabled
- Secrets injected via `--dart-define-from-file`, not hardcoded

## Post-release

- Upload debug symbols from `build/debug-info/` to Play Console for crash deobfuscation
- Monitor Firebase Crashlytics (if configured) and Play Console vitals
- Increment `version` in `pubspec.yaml` for each release (`1.0.1+2`, etc.)
