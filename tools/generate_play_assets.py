from PIL import Image, ImageDraw, ImageFont
from pathlib import Path

OUT = Path("play-store-assets")
OUT.mkdir(exist_ok=True)
(OUT / "screenshots").mkdir(exist_ok=True)

GOLD = (212, 175, 55)
GOLD_LIGHT = (241, 210, 121)
BLACK = (0, 0, 0)
SURFACE = (20, 20, 20)
CARD = (28, 28, 28)
WHITE = (255, 255, 255)
WHITE70 = (200, 200, 200)
WHITE38 = (140, 140, 140)

font_reg = r"C:\Windows\Fonts\arial.ttf"
font_bold = r"C:\Windows\Fonts\arialbd.ttf"
font_sb = r"C:\Windows\Fonts\seguisb.ttf"


def F(path, size):
    return ImageFont.truetype(path, size)


def rounded_rect(draw, xy, radius, fill, outline=None, width=1):
    draw.rounded_rectangle(xy, radius=radius, fill=fill, outline=outline, width=width)


def load_logo(size):
    logo = Image.open("assets/images/logo.png").convert("RGBA")
    logo.thumbnail((size, size), Image.Resampling.LANCZOS)
    return logo


# ---------- 1) App icon 512x512 ----------
icon = Image.new("RGB", (512, 512), BLACK)
logo = load_logo(420)
ix = (512 - logo.width) // 2
iy = (512 - logo.height) // 2
icon.paste(logo, (ix, iy), logo)
icon_path = OUT / "app_icon_512.png"
icon.save(icon_path, "PNG", optimize=True)
print("icon", icon_path, icon_path.stat().st_size)

# ---------- 2) Feature graphic 1024x500 ----------
feat = Image.new("RGB", (1024, 500), BLACK)
draw = ImageDraw.Draw(feat)
for i in range(500):
    t = i / 500
    c = int(8 + 18 * (1 - abs(t - 0.35)))
    draw.line([(0, i), (1024, i)], fill=(c, c, int(c * 0.7)))
draw.rectangle([0, 0, 8, 500], fill=GOLD)
logo_f = load_logo(320)
feat.paste(logo_f, (48, (500 - logo_f.height) // 2), logo_f)
tx = 420
draw.text((tx, 120), "PRIMEROCK", font=F(font_bold, 54), fill=GOLD_LIGHT)
draw.text((tx, 185), "MINING COMPANION", font=F(font_sb, 36), fill=WHITE)
draw.text((tx, 250), "Gold prices · Calculators · Lab booking", font=F(font_reg, 22), fill=WHITE70)
draw.text((tx, 300), "Offline-first tools for Zimbabwean miners", font=F(font_reg, 20), fill=WHITE38)
draw.rectangle([tx, 235, tx + 280, 238], fill=GOLD)
feat_path = OUT / "feature_graphic_1024x500.png"
feat.save(feat_path, "PNG", optimize=True)
print("feature", feat_path, feat_path.stat().st_size)

# ---------- Phone screenshots 1080x1920 (9:16) ----------
W, H = 1080, 1920


def phone_base(title):
    img = Image.new("RGB", (W, H), BLACK)
    d = ImageDraw.Draw(img)
    d.rectangle([0, 0, W, 72], fill=(10, 10, 10))
    d.text((48, 22), "09:41", font=F(font_reg, 28), fill=WHITE70)
    d.text((880, 22), "5G  100%", font=F(font_reg, 24), fill=WHITE70)
    d.text((48, 110), title, font=F(font_bold, 40), fill=GOLD)
    return img, d


def card(d, y, h, title, subtitle):
    rounded_rect(d, [48, y, W - 48, y + h], 28, CARD, outline=GOLD, width=2)
    d.text((88, y + 28), title, font=F(font_sb, 34), fill=GOLD_LIGHT)
    d.text((88, y + 80), subtitle, font=F(font_reg, 26), fill=WHITE70)


def save_shot(img, name):
    p = OUT / "screenshots" / name
    img.save(p, "PNG", optimize=True)
    print("shot", p, p.stat().st_size, img.size)


# 1 Home
img, d = phone_base("Primerock Companion")
logo_h = load_logo(220)
img.paste(logo_h, ((W - logo_h.width) // 2, 180), logo_h)
d.text((W // 2, 430), "Welcome, Miner", font=F(font_sb, 36), fill=WHITE, anchor="mt")
d.text(
    (W // 2, 485),
    "Daily tools for Zimbabwe gold producers",
    font=F(font_reg, 24),
    fill=WHITE38,
    anchor="mt",
)
tiles = [
    ("Gold Prices", "FGR buying rates USD/g & oz"),
    ("Calculators", "Recovery, grade, cyanide & more"),
    ("Mining News", "Industry updates offline"),
    ("Book Consultation", "WhatsApp Primerock lab"),
]
y = 560
for t, s in tiles:
    card(d, y, 140, t, s)
    y += 168
save_shot(img, "01_home.png")

# 2 Gold prices
img, d = phone_base("FGR Gold Prices")
rounded_rect(d, [48, 200, W - 48, 480], 28, CARD, outline=GOLD, width=2)
d.text((88, 240), "Fire Assay (Cash)", font=F(font_reg, 26), fill=WHITE70)
d.text((88, 290), "$125.45 / g", font=F(font_bold, 56), fill=GOLD_LIGHT)
d.text((88, 370), "$3,901.73 / oz", font=F(font_sb, 32), fill=WHITE)
d.text((88, 420), "As of 10 Jul 2026 · Fidelity Gold Refinery", font=F(font_reg, 22), fill=WHITE38)
cats = [
    ("SG 90% and Above", "$124.79/g"),
    ("SG 85% – 90%", "$123.47/g"),
    ("SG 80% – 85%", "$122.15/g"),
    ("Sample (5–10 g)", "$118.85/g"),
]
y = 520
for name, price in cats:
    rounded_rect(d, [48, y, W - 48, y + 120], 24, CARD, outline=(70, 60, 25), width=1)
    d.text((88, y + 38), name, font=F(font_reg, 28), fill=WHITE70)
    d.text((W - 88, y + 38), price, font=F(font_sb, 28), fill=GOLD_LIGHT, anchor="ra")
    y += 140
d.text(
    (W // 2, 1800),
    "Confirm at FGR buying centres before delivery",
    font=F(font_reg, 22),
    fill=WHITE38,
    anchor="mt",
)
save_shot(img, "02_gold_prices.png")

# 3 Calculators
img, d = phone_base("Mining Calculators")
d.text((48, 180), "Professional plant & assay tools", font=F(font_reg, 26), fill=WHITE70)
calcs = [
    ("Gold Value", "Weight × purity × price/g"),
    ("Recovery %", "Feed vs tail grade"),
    ("Ore Grade", "g/t from gold & tonnes"),
    ("Cyanide Dosage", "Target ppm & moisture"),
    ("Unit Converter", "g · kg · t · oz · ppm · %"),
]
y = 260
for name, sub in calcs:
    card(d, y, 150, name, sub)
    y += 175
save_shot(img, "03_calculators.png")

# 4 Booking
img, d = phone_base("Book Consultation")
rounded_rect(d, [48, 200, W - 48, 980], 28, CARD, outline=GOLD, width=2)
d.text((88, 240), "Primerock Solutions Lab", font=F(font_sb, 32), fill=GOLD_LIGHT)
d.text((88, 300), "3 Milton Road, Fairbridge Park, Mutare", font=F(font_reg, 24), fill=WHITE70)
fields = [
    ("Name", "Your full name"),
    ("Phone", "+263…"),
    ("Service", "Gold Fire Assay"),
    ("Preferred date", "Select date"),
]
y = 380
for label, hint in fields:
    d.text((88, y), label, font=F(font_reg, 22), fill=WHITE38)
    rounded_rect(d, [88, y + 40, W - 88, y + 120], 16, SURFACE, outline=(80, 70, 30), width=1)
    d.text((112, y + 62), hint, font=F(font_reg, 26), fill=WHITE38)
    y += 150
rounded_rect(d, [88, 1080, W - 88, 1200], 20, GOLD)
d.text((W // 2, 1140), "Send via WhatsApp", font=F(font_bold, 32), fill=BLACK, anchor="mm")
d.text((W // 2, 1300), "+263 771 437 248", font=F(font_sb, 30), fill=GOLD_LIGHT, anchor="mt")
d.text((W // 2, 1360), "primerocksolutions@gmail.com", font=F(font_reg, 26), fill=WHITE70, anchor="mt")
save_shot(img, "04_booking.png")

# 5 News
img, d = phone_base("Mining News")
items = [
    ("FGR daily gold buying prices", "Gold Prices · 10 Jul 2026"),
    ("Why fire assay still matters", "Laboratory · 8 Jul 2026"),
    ("Sampling tips before Mutare drop-off", "Mining Tips · 5 Jul 2026"),
    ("CIL/CIP: watch tails & carbon", "Metallurgy · 1 Jul 2026"),
]
y = 200
for title, meta in items:
    rounded_rect(d, [48, y, W - 48, y + 220], 28, CARD, outline=(70, 60, 25), width=1)
    d.text((88, y + 40), title, font=F(font_sb, 30), fill=WHITE)
    d.text((88, y + 120), meta, font=F(font_reg, 24), fill=GOLD)
    d.text((88, y + 160), "Read offline in the Companion app", font=F(font_reg, 22), fill=WHITE38)
    y += 250
save_shot(img, "05_news.png")

print("DONE", OUT.resolve())
