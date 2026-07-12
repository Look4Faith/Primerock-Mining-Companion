#!/usr/bin/env python3
"""
Free FGR gold-price sync (zero monthly cost).

Writes BOTH:
  - assets/data/gold_prices.json  (bundled offline fallback)
  - hosted-data/gold_prices.json  (published for raw.githubusercontent.com refresh)

Usage:
  python tools/sync_fgr_prices.py --latest
  python tools/sync_fgr_prices.py --url URL
  python tools/sync_fgr_prices.py --date YYYY-MM-DD --fire 125.45 --sg90 124.79 ...
"""

from __future__ import annotations

import argparse
import json
import re
import sys
import urllib.request
from datetime import date, datetime
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT_ASSET = ROOT / "assets" / "data" / "gold_prices.json"
OUT_HOSTED = ROOT / "hosted-data" / "gold_prices.json"
OZ = 31.1035
MZ_INDEX = "https://miningzimbabwe.com/gold-today/"
UA = {"User-Agent": "PrimerockFgrSync/1.1 (+https://github.com/)"}

CATEGORY_ORDER = [
    ("sg90", "SG 90% and Above"),
    ("sg85", "SG 85% but Less Than 90%"),
    ("sg80", "SG 80% but Less Than 85%"),
    ("sg75", "SG 75% but Less Than 80%"),
    ("sample", "Sample (5–10 g)"),
    ("fire_assay_cash", "Fire Assay (Cash)"),
]


def cat(cid: str, label: str, usd_g: float) -> dict:
    return {
        "id": cid,
        "label": label,
        "usdPerGram": round(usd_g, 2),
        "usdPerOz": round(usd_g * OZ, 2),
    }


def fetch(url: str) -> str:
    req = urllib.request.Request(url, headers=UA)
    with urllib.request.urlopen(req, timeout=45) as resp:
        return resp.read().decode("utf-8", "ignore")


def load() -> dict:
    path = OUT_ASSET if OUT_ASSET.exists() else OUT_HOSTED
    if path.exists():
        return json.loads(path.read_text(encoding="utf-8"))
    return {
        "source": "Fidelity Gold Refinery (FGR)",
        "sourceUrl": "https://fgr.co.zw/",
        "operationsUrl": "https://fgr.co.zw/gold-operations/gold-buying-and-gold-refining-operations/",
        "lastUpdated": "",
        "note": "Official FGR buying categories. Confirm at FGR before delivery.",
        "troyOunceGrams": OZ,
        "paymentNote": "FGR Cash (USD) and Hybrid (60% Nostro / 40% local).",
        "days": [],
    }


def save(data: dict) -> None:
    text = json.dumps(data, indent=2) + "\n"
    OUT_ASSET.parent.mkdir(parents=True, exist_ok=True)
    OUT_HOSTED.parent.mkdir(parents=True, exist_ok=True)
    OUT_ASSET.write_text(text, encoding="utf-8")
    OUT_HOSTED.write_text(text, encoding="utf-8")


def upsert_day(data: dict, day: dict) -> None:
    days = [d for d in data.setdefault("days", []) if d.get("date") != day["date"]]
    days.append(day)
    days.sort(key=lambda d: d["date"])
    # Keep last 60 days to bound file size
    data["days"] = days[-60:]
    data["lastUpdated"] = day["date"]
    data["source"] = "Fidelity Gold Refinery (FGR)"
    data["sourceUrl"] = "https://fgr.co.zw/"


def from_args(args: argparse.Namespace) -> dict:
    values = {
        "sg90": args.sg90,
        "sg85": args.sg85,
        "sg80": args.sg80,
        "sg75": args.sg75,
        "sample": args.sample,
        "fire_assay_cash": args.fire,
    }
    categories = [
        cat(cid, label, values[cid])
        for cid, label in CATEGORY_ORDER
        if values[cid] is not None
    ]
    return {"date": args.date, "categories": categories}


def parse_article(html: str, fallback_date: str | None = None) -> dict:
    found: dict[str, float] = {}
    label_map = {
        "sg90": re.compile(r"SG\s*90%\s*and\s*Above", re.I),
        "sg85": re.compile(r"SG\s*85%\s*but\s*Less\s*Than\s*90%", re.I),
        "sg80": re.compile(r"SG\s*80%\s*but\s*Less\s*Than\s*85%", re.I),
        "sg75": re.compile(r"SG\s*75%\s*but\s*Less\s*Than\s*80%", re.I),
        "sample": re.compile(r"Sample\s*\(5.\s*10\s*g\)", re.I),
        "fire_assay_cash": re.compile(r"Fire\s*Assay\s*\(\s*Cash\s*\)", re.I),
    }

    for row in re.findall(r"<tr[^>]*>([\s\S]*?)</tr>", html, re.I):
        cells = re.findall(r"<t[dh][^>]*>([\s\S]*?)</t[dh]>", row, re.I)
        if len(cells) < 2:
            continue
        label = re.sub(r"<[^>]+>", "", cells[0]).strip()
        usd_raw = re.sub(r"<[^>]+>", "", cells[1]).strip()
        usd_m = re.search(r"([\d,.]+)", usd_raw)
        if not usd_m:
            continue
        usd = float(usd_m.group(1).replace(",", ""))
        for cid, cre in label_map.items():
            if cre.search(label):
                found[cid] = usd
                break

    text = re.sub(r"<[^>]+>", " | ", html)
    text = re.sub(r"&nbsp;|&amp;", " ", text)
    text = re.sub(r"\s+", " ", text)

    if "fire_assay_cash" not in found:
        m = re.search(
            r"Fire\s*Assay\s*\(\s*Cash\s*\)[^0-9]{0,40}([\d]+\.[\d]+)",
            html,
            re.I | re.S,
        )
        if m:
            found["fire_assay_cash"] = float(m.group(1))

    if "fire_assay_cash" not in found:
        raise RuntimeError("Could not parse Fire Assay (Cash) from HTML")

    mdate = re.search(
        r"(\d{1,2})\s+(January|February|March|April|May|June|July|August|"
        r"September|October|November|December)\s+(20\d{2})",
        text,
        re.I,
    )
    if mdate:
        d = datetime.strptime(
            f"{mdate.group(1)} {mdate.group(2)} {mdate.group(3)}", "%d %B %Y"
        ).date()
        day = d.isoformat()
    else:
        day = fallback_date or date.today().isoformat()

    names = dict(CATEGORY_ORDER)
    categories = [
        cat(cid, names[cid], found[cid])
        for cid, _ in CATEGORY_ORDER
        if cid in found
    ]
    return {"date": day, "categories": categories}


def from_url(url: str) -> dict:
    return parse_article(fetch(url))


def find_latest_url() -> str:
    html = fetch(MZ_INDEX)
    # Prefer newest "gold-buying-prices-in-zimbabwe-per-gram-ounce-*" link
    links = re.findall(
        r'href="(https://miningzimbabwe\.com/gold-buying-prices-in-zimbabwe-per-gram-ounce-[^"]+/)"',
        html,
        re.I,
    )
    if not links:
        links = re.findall(
            r'href="(/gold-buying-prices-in-zimbabwe-per-gram-ounce-[^"]+/)"',
            html,
            re.I,
        )
        links = ["https://miningzimbabwe.com" + p for p in links]
    if not links:
        raise RuntimeError(f"No price article links found on {MZ_INDEX}")
    # First match is usually newest on the index page
    return links[0]


def main() -> None:
    p = argparse.ArgumentParser(description="Sync FGR gold prices into JSON")
    p.add_argument("--latest", action="store_true", help="Fetch newest public FGR sheet mirror")
    p.add_argument("--url", help="Specific article URL to parse")
    p.add_argument("--date", help="YYYY-MM-DD for manual entry")
    p.add_argument("--sg90", type=float)
    p.add_argument("--sg85", type=float)
    p.add_argument("--sg80", type=float)
    p.add_argument("--sg75", type=float)
    p.add_argument("--sample", type=float)
    p.add_argument("--fire", type=float, help="Fire Assay Cash USD/g")
    args = p.parse_args()

    if args.latest:
        url = find_latest_url()
        print(f"Latest URL: {url}")
        day = from_url(url)
    elif args.url:
        day = from_url(args.url)
    elif args.date and args.fire is not None:
        day = from_args(args)
    else:
        p.print_help()
        sys.exit(1)

    data = load()
    upsert_day(data, day)
    save(data)
    print(f"Updated assets + hosted-data with {day['date']} ({len(day['categories'])} categories)")


if __name__ == "__main__":
    main()
