# Security

## Overview

NutriCal handles personal health data. This document outlines security practices and considerations.

## Data Storage

### Local Storage (Current)
- All data stored via `SharedPreferences` (platform-native secure storage)
- **Windows**: Registry-based storage
- **Android**: XML preferences in app-private directory
- **iOS**: NSUserDefaults (sandboxed)
- No data leaves the device unless user explicitly exports

### Sensitive Data Handling
- **No passwords stored in plaintext** — Auth service uses hashed comparison
- **No API keys embedded** — Open Food Facts is keyless; future keys use `.env`
- **No PII transmitted** — All nutrition data stays local
- **No analytics/tracking** — Zero third-party analytics SDKs

## Network Security

### API Calls
- Only external call: Open Food Facts API (`https://world.openfoodfacts.org`)
- HTTPS only — no HTTP fallback
- Timeout: 8 seconds (prevents hanging)
- Graceful failure — app works fully offline if API unreachable

### No Data Exfiltration
- No background network calls
- No telemetry
- No crash reporting (add Sentry/Firebase Crashlytics in production)

## Input Validation

| Input | Validation |
|-------|-----------|
| Email | Format check before auth |
| Password | Minimum 6 characters |
| Name | Non-empty check |
| Weight/Height | Numeric bounds (20-300kg, 100-250cm) |
| Age | Numeric bounds (10-120) |
| Quantity | Clamped to 0.5-99 |
| Barcode | Sanitized before API call |

## Dependencies

All dependencies are from pub.dev (Dart's official package registry):
- No known vulnerabilities at time of release
- Run `flutter pub outdated` to check for updates
- Run `dart pub audit` for security advisories (Dart 3.x+)

## Future Security Roadmap

- [ ] **Firebase Auth** — OAuth2/JWT tokens, email verification
- [ ] **Firestore Security Rules** — Per-user data isolation
- [ ] **Certificate Pinning** — For API calls in production
- [ ] **Biometric Lock** — App-level fingerprint/face unlock
- [ ] **Data Encryption** — Encrypt SharedPreferences with flutter_secure_storage
- [ ] **OWASP Mobile Top 10** — Full compliance audit

## Reporting Vulnerabilities

If you discover a security issue, please email: vivekboora11@gmail.com

Do **not** open a public GitHub issue for security vulnerabilities.
