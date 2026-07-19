# Play Store — Closed testing & release guide

## New release (1.2.0)

| Field | Value |
|-------|--------|
| **App name** | Primerock Mining Companion |
| **Package** | `zw.co.primerock.primerock_mining_companion` |
| **Version name** | 1.2.0 |
| **Version code** | 3 |
| **Release name** | `1.2.0 (3) — Live prices & news refresh` |
| **AAB path** | `build/app/outputs/bundle/release/app-release.aab` |
| **Also copied to** | `dist/Primerock-Mining-Companion-1.2.0-3.aab` |

### Release notes (paste into Play Console)

**English (en-US) — What’s new**

```
• Gold prices and mining news now refresh automatically on Wi‑Fi or mobile data
• Latest Fidelity (FGR) buying sheets when available
• Fresh Zimbabwe mining headlines from Mining Zimbabwe
• Pull down or tap refresh on Gold Prices and News to sync
• Sync status shows when data is live vs offline cache
```

### Upload steps
1. Open [Google Play Console](https://play.google.com/console) → **Primerock Mining Companion**
2. **Testing** → **Closed testing** (or Internal testing for a smaller group)
3. **Create new release** → upload `app-release.aab`
4. Paste release notes above → **Save** → **Review release** → **Start rollout to Closed testing**

---

## How to invite testers (shareable link)

Play does **not** give a public Play Store link until the app is in production. For testers you use a **closed testing opt-in URL**.

### A) Email list (simplest for a small group)
1. Play Console → **Testing** → **Closed testing** → your track (e.g. `alpha`)
2. **Testers** tab → create a list (e.g. `Primerock pilot`)
3. Add Gmail addresses of testers (they must use those Google accounts on the phone)
4. **Save** → copy the **opt-in URL** (looks like):
   `https://play.google.com/apps/testing/zw.co.primerock.primerock_mining_companion`
5. Send them this message:

```
Hi,

You’re invited to test Primerock Mining Companion (offline mining tools, FGR gold prices, Zim mining news, lab booking).

1. Open this link on your Android phone (signed into the Google account we invited):
   https://play.google.com/apps/testing/zw.co.primerock.primerock_mining_companion

2. Tap “Become a tester”
3. Wait a few minutes, then open Play Store → search “Primerock Mining Companion” → Install
   (or use the “Download it on Google Play” button on the opt-in page)

Please try: Home, Gold Prices (pull to refresh on Wi‑Fi), News, Calculators, Booking.
Reply with what works, what’s confusing, and any bugs.

Thanks — Primerock Solutions
WhatsApp: +263 771 437 248
```

### B) Google Group (better for many testers)
1. Create a Google Group → add testers as members  
2. In Play Console testers, choose that group instead of an email list  
3. Share the same opt-in URL

### Important
- Testers must use the **same Google account** you invited  
- First install can take **minutes to a few hours** after they become a tester  
- They need Android devices (not iPhone)

---

## How to collect their suggestions

| Method | How |
|--------|-----|
| **WhatsApp** | Ask them to message `+263 771 437 248` with feedback |
| **Email** | `primerocksolutions@gmail.com` with subject `App feedback` |
| **Play Console** | **Quality** → **Ratings and reviews** (once they leave a review on the testing track) |
| **Simple form** | Optional: Google Form link in your invite SMS/email |

Suggested short feedback ask:

```
After 1–2 days of use, please reply:
1. Did gold prices update on Wi‑Fi? (yes/no + sheet date shown)
2. Was news useful for your work?
3. Which screen did you use most?
4. Anything broken or confusing?
5. One feature you wish we added
```

---

## Signing (local only — do not upload keystore to GitHub)
- Keystore: `android/keystore/upload-keystore.jks`
- Alias: `upload`
- Credentials: `android/keystore/CREDENTIALS.txt` — back up offline

## Rebuild later
```bash
flutter build appbundle --release
```
