# Eazotel

The Eazotel hotel CRM app, built with Flutter. It is the mobile / tablet / desktop version of the Eazotel web dashboard: hotels manage leads, WhatsApp chats, calls, marketing, SEO and their subscription from one app.

- Package: `com.eazotel.app`
- Version: see `version` in [pubspec.yaml](pubspec.yaml)
- Platforms: Android, iOS, Windows (web and macOS build but are not the main target)
- Works in light and dark theme, and adapts to phone, tablet and desktop widths

## Features

| Area | What it does |
|---|---|
| Auth | Email / password login, Google sign-in, sign up with Google, forgot / reset password (6-digit email code) |
| Onboarding | New accounts without a hotel fill in "Onboard your property"; this creates the website and starts the 14-day free trial |
| Home | Dashboard summary, recent leads, call analytics, notification bell |
| Leads | Lead list with tabs, search, filters, lead details, notes, follow-ups |
| WhatsApp | Live chat over a socket, media / location / template / flow messages, take over from AI and hand back, new-message notifications with sound |
| Calls | Call list, recordings, make a call, update call fields |
| Marketing | WhatsApp campaigns; Email marketing (recipients, Excel / CSV import, compose, campaigns, templates, AI templates) |
| SEO | Local SEO (map grid, keywords, visibility) and Website SEO tracker |
| Google Analytics, Google Ads, Meta | Insights screens |
| Settings | Profile, locations (add / edit / delete / switch), team management, WhatsApp settings (templates, quick replies, chatbot flow builder, auto messages, AI, credits), Eazbot, integrations, notifications, subscription |
| Subscription | Plans & billing with Razorpay; an expired plan shows the renew screen |
| Roles | Admins see all locations, team members only their assigned ones, owners can switch into client accounts |

## Tech stack

- Flutter (Dart SDK `^3.11`), state management with **GetX**
- HTTP through one shared client: [lib/core/api/api_clint_servic.dart](lib/core/api/api_clint_servic.dart)
- Socket for live WhatsApp messages
- `razorpay_flutter` for payments (Android / iOS only)
- `google_maps_flutter`, `fl_chart`, `shimmer`, `google_sign_in`

## Project structure

```
lib/
  main.dart              app start (opens Login or Dashboard)
  core/
    api/                 ApiClient + ApiException
    config/              app config (keys come from a local file, not git)
    constants/           base URLs and all API endpoints
    local_storage/       token storage, logout cleanup
  features/
    <feature>/
      controller/        GetX controllers (state + logic)
      services/          API calls for that feature
      model(s)/          JSON models
      screen/            screens, with small widgets in screen/widgets/
  utils/                 theme, colors, responsive helpers
```

Each feature folder follows the same idea: **screen → controller → service → API**. Screens only show data; controllers hold the state; services are the only place that talks to the server.

## Getting started

1. Install Flutter (stable channel) and check it with `flutter doctor`.
2. Get the packages:
   ```
   flutter pub get
   ```
3. Get the local keys file `lib/core/config/app_secrets.dart` from the project owner and put it in that folder. It is in `.gitignore`, so it never goes to GitHub.
4. Run the app:
   ```
   flutter run
   ```

To try different phone sizes on the computer, run with Device Preview:
```
flutter run -d windows --dart-define=DEVICE_PREVIEW=true
```

## Configuration

- **Server URLs:** [lib/core/constants/api_base_url.dart](lib/core/constants/api_base_url.dart)
- **Endpoints:** [lib/core/constants/api_endpoints.dart](lib/core/constants/api_endpoints.dart)
- **Keys:** `lib/core/config/app_secrets.dart` (local only, see Getting started). Payment secrets live only on the server, never in this app.

## Release build (Android)

Release builds are signed with the upload keystore. The keystore and its passwords are **not** in git, so ask the project owner for them.

1. Put the keystore file in `android/app/`.
2. Create `android/key.properties`:
   ```
   storePassword=<store password>
   keyPassword=<key password>
   keyAlias=<key alias>
   storeFile=<keystore file name>
   ```
3. Build:
   ```
   flutter build appbundle --release   # for Google Play
   flutter build apk --release         # APK for testing
   ```

## Do not commit

These are listed in `.gitignore` and must stay out of the repo (it is public):

- `lib/core/config/app_secrets.dart` (app keys)
- Keystore files (`*.jks`, `*.keystore`) and `key.properties`
- SHA-1 / SHA-256 notes and signing reports
- `.env` files, certificates and private keys (`*.pem`, `*.p12`, `*.p8`)
- Built apps (`*.apk`, `*.aab`, `*.ipa`)

If a secret is pushed by mistake, change that secret first, then remove the file from git.
