# Play Store listing assets

Upload these in Play Console → Grow → Store presence → Main store listing.

| Asset | File | Spec |
|--------|------|------|
| **App icon** | `app_icon_512.png` | 512×512 PNG (~44 KB) |
| **Feature graphic** | `feature_graphic_1024x500.png` | 1024×500 PNG (~52 KB) |
| **Phone screenshots** | `screenshots/*.png` | 1080×1920 (9:16), 5 images |

## Screenshot order (recommended)
1. `01_home.png` — Home dashboard  
2. `02_gold_prices.png` — FGR gold prices  
3. `03_calculators.png` — Calculators  
4. `04_booking.png` — Consultation booking  
5. `05_news.png` — Mining news  

Minimum required: **2**. For promotion eligibility: upload **at least 4** (these are all ≥1080 px).

Regenerate anytime:
```bash
python tools/generate_play_assets.py
```
