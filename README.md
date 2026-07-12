# Primerock Mining Companion

Offline-first Flutter companion for Zimbabwean miners by **Primerock Solutions**.

No payments. No accounts. No paid APIs. Works without internet, and can refresh bundled data for free when Wi‑Fi/data is available.

## Features

- **Gold prices** — Fidelity-style USD/ZiG reference with history chart
- **Mining calculators** — gold value, recovery, ore grade, cyanide, slurry, pH, moisture, unit converter
- **Knowledge hub** — offline articles (assay, CIL/CIP, cyanide safety, etc.)
- **Mining assistant** — local Q&A (not OpenAI); swappable for a future AI API
- **Production records** — Hive journal with charts + PDF export
- **Primerock Laboratory** — services, FAQ, process
- **Contact** — phone, WhatsApp, email, Open in Google Maps

## Stack

Flutter · Dart · Material 3 · Riverpod · GoRouter · Hive · SharedPreferences · fl_chart · intl · url_launcher · connectivity_plus · http · pdf/printing

## Architecture

```
lib/
  core/          constants, theme, utils, errors, router
  features/      home, calculators, knowledge, gold_prices,
                 mining_records, assistant, laboratory, contact,
                 settings, onboarding
  models/
  services/      offline-first loaders + local storage
  widgets/
assets/
  data/          gold_prices, mining_answers, lab_content
  articles/      articles.json
  images/        logo.png
```

## Gold prices (Fidelity Gold Refinery)

Official source: [fgr.co.zw](https://fgr.co.zw/) — the homepage popup is mainly an **email signup** for daily buying prices, not a public API. The app therefore:

1. Ships real FGR **category sheets** (SG bands + Fire Assay Cash) in `assets/data/gold_prices.json`
2. Shows USD/g and USD/oz the way FGR publishes them
3. On Wi‑Fi/data, optionally refreshes from a **free** static JSON host (`AppConstants.remoteDataBaseUrl`)
4. Never depends on paid APIs

Update the bundled file with:

```bash
python tools/sync_fgr_prices.py --date 2026-07-10 --sg90 124.79 --sg85 123.47 --sg80 122.15 --sg75 120.83 --sample 118.85 --fire 125.45
```

Or from a public republished FGR table URL:

```bash
python tools/sync_fgr_prices.py --url "https://miningzimbabwe.com/gold-buying-prices-in-zimbabwe-per-gram-ounce-10-july-2026/"
```

## Phase 2

See [PHASE2.md](PHASE2.md) for free FGR sync, icons/splash, booking, news, and release builds.

Contact: **+263771437248** · **primerocksolutions@gmail.com** · **3 Milton Road, Fairbridge Park, Mutare**


## Run

```bash
flutter pub get
flutter run
```

Tests:

```bash
flutter test
```

## Branding

Black / gold / white Material 3 theme matching the Primerock Solutions logo (`assets/images/logo.png`).

## Future migration

Services are abstracted so you can later plug in Firebase, Supabase, or a custom API without rewriting UI:

- `GoldPriceService` / `OfflineContentService`
- `MiningAssistantService`
- `NotificationService` (local stub only — no Firebase Messaging yet)

## License

Private — Primerock Solutions.
