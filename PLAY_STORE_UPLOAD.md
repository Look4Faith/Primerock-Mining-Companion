# Play Store Closed testing — upload guide

## Upload file
After build, use this file in Play Console → Closed testing → Create release:

`build/app/outputs/bundle/release/app-release.aab`

## App identity
- **Name:** Primerock Mining Companion
- **Package:** `zw.co.primerock.primerock_mining_companion`
- **Version name:** 1.1.0
- **Version code:** 2
- **Release name:** `1.1.0 (2) — Closed test`
- **Category:** Business

## Signing
- Keystore: `android/keystore/upload-keystore.jks` (local only, gitignored)
- Alias: `upload`
- Credentials: `android/keystore/CREDENTIALS.txt` (local only — back this up offline)

Play Console will ask you to enrol in **Play App Signing**. Accept it and upload this AAB; Google keeps the app signing key, you keep the upload keystore.

## Build again later
```bash
flutter build appbundle --release
```
