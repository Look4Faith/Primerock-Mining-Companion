# Hosted data (free remote refresh)

JSON in this folder is downloaded by the app on Wi‑Fi/data from:

`https://raw.githubusercontent.com/Look4Faith/Primerock-Mining-Companion/main/hosted-data`

## Files

| File | Purpose |
|------|---------|
| `gold_prices.json` | FGR buying categories (synced by GitHub Action) |
| `news.json` | Mining / gold industry news |
| `lab_content.json` | Lab copy + Mutare contact |

Repo must stay **public** for free raw.githubusercontent.com access ($0/month).

If you rename the repo, rebuild with:

```bash
flutter build apk --release --dart-define=REMOTE_DATA_URL=https://raw.githubusercontent.com/YOUR_USER/YOUR_REPO/main/hosted-data
```
