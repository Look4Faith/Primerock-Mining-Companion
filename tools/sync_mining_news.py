#!/usr/bin/env python3
"""
Free Zimbabwe mining news sync (zero monthly cost).

Scrapes Mining Zimbabwe public homepage / article pages and writes:
  - assets/data/news.json
  - hosted-data/news.json

Usage:
  python tools/sync_mining_news.py
  python tools/sync_mining_news.py --limit 12
"""

from __future__ import annotations

import argparse
import html as html_lib
import json
import re
import sys
import urllib.request
from datetime import date, datetime, timezone
from pathlib import Path
from urllib.parse import urlparse

ROOT = Path(__file__).resolve().parents[1]
OUT_ASSET = ROOT / "assets" / "data" / "news.json"
OUT_HOSTED = ROOT / "hosted-data" / "news.json"
MZ_HOME = "https://miningzimbabwe.com/"
UA = {"User-Agent": "PrimerockNewsSync/1.1 (+https://github.com/Look4Faith/Primerock-Mining-Companion)"}

SKIP_SLUGS = {
    "magazine",
    "gold-today",
    "important",
    "privacy-policy",
    "tds-my-account",
    "feed",
    "claimprenuer",
    "where-is-gold-found-in-zimbabwe",
    "mine-entra-2025",
}

EVERGREEN = [
    {
        "id": "primerock-fgr-categories",
        "title": "FGR publishes daily gold buying category prices",
        "summary": "Fidelity Gold Refinery publishes SG-band and Fire Assay Cash rates in USD/g and USD/oz for Zimbabwe producers.",
        "body": "Fidelity Gold Refinery (FGR) remains Zimbabwe’s official buyer, refiner and exporter of gold. Daily buying sheets typically list Specific Gravity (SG) bands from 75% upward, a small-sample rate, and Fire Assay Cash for larger parcels.\n\nPrimerock Mining Companion mirrors these categories for planning. Always confirm the current sheet at an FGR buying centre or via FGR’s official channels before delivery.",
        "category": "Gold Prices",
        "date": "2026-07-10",
        "sourceName": "Primerock brief",
        "sourceUrl": "https://fgr.co.zw/",
        "tags": ["FGR", "gold", "prices"],
    },
    {
        "id": "primerock-sampling-tips",
        "title": "Eastern Highlands producers: sampling tips before Mutare drop-off",
        "summary": "Good sealing, unique IDs and dry-basis moisture notes reduce disputes and speed certificates.",
        "body": "Bring clearly labelled, sealed samples to 3 Milton Road, Fairbridge Park, Mutare. Record wet weight, estimated moisture, and the question you need answered.\n\nBook a consultation via the app’s Booking screen — it opens WhatsApp with your details pre-filled.",
        "category": "Mining Tips",
        "date": "2026-07-05",
        "sourceName": "Primerock Solutions",
        "sourceUrl": "",
        "tags": ["sampling", "Mutare", "tips"],
    },
]


def fetch(url: str) -> str:
    req = urllib.request.Request(url, headers=UA)
    with urllib.request.urlopen(req, timeout=45) as resp:
        return resp.read().decode("utf-8", "ignore")


def clean_text(value: str) -> str:
    value = html_lib.unescape(value or "")
    value = re.sub(r"<[^>]+>", " ", value)
    value = re.sub(r"\s+", " ", value).strip()
    return value


def slug_id(url: str) -> str:
    path = urlparse(url).path.strip("/")
    slug = path.split("/")[-1] if path else "item"
    slug = re.sub(r"[^a-zA-Z0-9\-]+", "-", slug).strip("-").lower()
    return f"mz-{slug[:80]}"


def category_for(title: str, url: str) -> str:
    low = f"{title} {url}".lower()
    if "gold-buying-prices" in url or "gold buying prices" in low:
        return "Gold Prices"
    if any(k in low for k in ("lithium", "chrome", "coal", "diamond", "pgms", "platinum")):
        return "Industry"
    if any(k in low for k in ("safety", "rescue", "trapped", "accident", "emergency")):
        return "Safety"
    if any(k in low for k in ("assay", "laboratory", "lab ")):
        return "Laboratory"
    if any(k in low for k in ("cil", "cip", "metallurg", "recovery", "tailings", "hydrosluic")):
        return "Metallurgy"
    if any(k in low for k in ("interview", "one-on-one", "woman at work", "trailblaz")):
        return "People"
    return "Mining News"


def tags_for(title: str, category: str) -> list[str]:
    tags = {"Zimbabwe", "mining"}
    low = title.lower()
    for word in ("gold", "lithium", "chrome", "coal", "safety", "FGR", "Mutare"):
        if word.lower() in low or word == "FGR" and "fidelity" in low:
            tags.add(word if word != "FGR" else "FGR")
    tags.add(category.split()[0])
    return sorted(tags)[:6]


def parse_homepage(html: str) -> list[tuple[str, str]]:
    entries = re.findall(
        r'<h[23][^>]*class="[^"]*entry-title[^"]*"[^>]*>\s*<a[^>]+href="([^"]+)"[^>]*>([^<]+)</a>',
        html,
        flags=re.I,
    )
    seen: set[str] = set()
    out: list[tuple[str, str]] = []
    for url, title in entries:
        url = url.split("#")[0].rstrip("/") + "/"
        if url in seen:
            continue
        slug = urlparse(url).path.strip("/").split("/")[-1]
        if slug in SKIP_SLUGS:
            continue
        if "/category/" in url or "/tag/" in url or "/author/" in url:
            continue
        seen.add(url)
        out.append((url, clean_text(title)))
    return out


def parse_article(url: str) -> tuple[str, str, str]:
    """Returns (iso_date, summary, body)."""
    art = fetch(url)
    published = None
    m = re.search(r'<time[^>]+datetime="([^"]+)"', art, re.I)
    if m:
        published = m.group(1)
    if not published:
        m = re.search(r'"datePublished"\s*:\s*"([^"]+)"', art)
        if m:
            published = m.group(1)

    iso_date = date.today().isoformat()
    if published:
        try:
            iso_date = datetime.fromisoformat(published.replace("Z", "+00:00")).date().isoformat()
        except ValueError:
            m2 = re.search(r"(\d{4}-\d{2}-\d{2})", published)
            if m2:
                iso_date = m2.group(1)

    body_html = ""
    m = re.search(r"<article[^>]*>(.*?)</article>", art, re.I | re.S)
    if m:
        body_html = m.group(1)
    text = clean_text(body_html)
    for split_on in (
        "Linkedin Facebook X WhatsApp Email ",
        "WhatsApp Email ",
    ):
        if split_on in text:
            text = text.split(split_on, 1)[-1].strip()
            break

    # Drop theme/JS leftovers and “related” sections.
    for cut in (
        " Related articles ",
        " Related articles",
        " var block_",
        " #GoldPrices ",
    ):
        idx = text.find(cut)
        if idx != -1:
            text = text[:idx].strip()

    text = re.sub(r"\s*#\w+", "", text).strip()
    text = re.sub(r"\s+", " ", text).strip()

    if len(text) < 80:
        text = "Open the full article on Mining Zimbabwe for details."

    summary = text[:220].rsplit(" ", 1)[0] + ("…" if len(text) > 220 else "")
    body = text[:1800]
    if len(text) > 1800:
        body += "…"
    body += f"\n\nSource: Mining Zimbabwe — {url}"
    return iso_date, summary, body


def build_items(limit: int) -> list[dict]:
    home = fetch(MZ_HOME)
    links = parse_homepage(home)
    if not links:
        raise RuntimeError("No Mining Zimbabwe article links found")

    # Prefer a mix: up to 2 gold-price posts + general mining news
    gold = [x for x in links if "gold-buying-prices" in x[0]][:2]
    other = [x for x in links if "gold-buying-prices" not in x[0]]
    selected = gold + other
    selected = selected[:limit]

    items: list[dict] = []
    for url, title in selected:
        try:
            iso_date, summary, body = parse_article(url)
        except Exception as exc:  # noqa: BLE001
            print(f"skip {url}: {exc}", file=sys.stderr)
            continue
        category = category_for(title, url)
        items.append(
            {
                "id": slug_id(url),
                "title": title,
                "summary": summary,
                "body": body,
                "category": category,
                "date": iso_date,
                "sourceName": "Mining Zimbabwe",
                "sourceUrl": url,
                "tags": tags_for(title, category),
            }
        )

    # Keep evergreen Primerock tips that are not duplicated by title
    titles = {i["title"].lower() for i in items}
    for tip in EVERGREEN:
        if tip["title"].lower() not in titles:
            items.append(tip)

    items.sort(key=lambda i: i["date"], reverse=True)
    return items


def save(data: dict) -> None:
    text = json.dumps(data, indent=2, ensure_ascii=False) + "\n"
    OUT_ASSET.parent.mkdir(parents=True, exist_ok=True)
    OUT_HOSTED.parent.mkdir(parents=True, exist_ok=True)
    OUT_ASSET.write_text(text, encoding="utf-8")
    OUT_HOSTED.write_text(text, encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(description="Sync Zimbabwe mining news JSON")
    parser.add_argument("--limit", type=int, default=14, help="Max scraped articles")
    args = parser.parse_args()

    items = build_items(args.limit)
    payload = {
        "source": "Mining Zimbabwe + Primerock",
        "lastUpdated": date.today().isoformat(),
        "note": "Auto-refreshed Zimbabwe mining headlines when online. Confirm details on the source site.",
        "syncedAt": datetime.now(timezone.utc).isoformat(),
        "items": items,
    }
    save(payload)
    print(f"Wrote {len(items)} news items -> {OUT_HOSTED.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
