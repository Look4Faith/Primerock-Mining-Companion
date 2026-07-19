# Hosted data (free remote refresh)

JSON in this folder is downloaded by the app on Wi‑Fi/data from:

`https://raw.githubusercontent.com/Look4Faith/Primerock-Mining-Companion/main/hosted-data`

## Files

| File | Purpose |
|------|---------|
| `gold_prices.json` | FGR buying categories (GitHub Action, weekdays morning + afternoon) |
| `news.json` | Zimbabwe mining headlines from Mining Zimbabwe (daily Action) |
| `lab_content.json` | Lab copy + Mutare contact |

## How often it updates

| Content | Server sync (GitHub Action) | App refresh |
|---------|----------------------------|-------------|
| Gold prices | Weekdays ~08:30 and ~14:30 Zimbabwe | On open / pull-to-refresh when online |
| News | Daily ~18:00 Zimbabwe | On open / pull-to-refresh when online |

Repo must stay **public** for free raw.githubusercontent.com access ($0/month).

Manual sync:

```bash
python tools/sync_fgr_prices.py --latest
python tools/sync_mining_news.py
```

If you rename the repo, rebuild with:

```bash
flutter build apk --release --dart-define=REMOTE_DATA_URL=https://raw.githubusercontent.com/YOUR_USER/YOUR_REPO/main/hosted-data
```
