# Phase 2 — Free sync, icons, booking, news, release

## Done in this phase

1. **Free FGR price sync**
   - `tools/sync_fgr_prices.py --latest`
   - `.github/workflows/sync-fgr-prices.yml` (weekday schedule)
   - Publishes to `hosted-data/gold_prices.json`
   - App `remoteDataBaseUrl` points at GitHub raw `hosted-data/`

2. **App icons & splash** — generated from Primerock logo (black/gold)

3. **Consultation booking** — `/booking` form → Hive + WhatsApp (+263771437248)

4. **News feed** — `/news` offline-first + remote `news.json`

5. **Release builds**
   - Android: `flutter build apk --release` → `build/app/outputs/flutter-apk/app-release.apk`
   - iOS: requires macOS + Xcode: `flutter build ipa` (or `flutter build ios`)

## Publish the free data CDN (required once)

GitHub CLI is not logged in on this machine yet.

```bash
cd "c:\xampp\htdocs\Primerock Mining Companion"
gh auth login
git add .
git commit -m "Phase 2: Primerock Mining Companion"
gh repo create Look4Faith/Primerock-Mining-Companion --public --source=. --remote=origin --push
```

Remote data URL (default in app):

`https://raw.githubusercontent.com/Look4Faith/Primerock-Mining-Companion/main/hosted-data`
