"""Generate the og:image PNG used by social previews.

Run once locally (Pillow is in the dev dependency group):

    cd site && uv sync --group dev
    uv run python ../scripts/generate_og_image.py

Reads name/title/url from ``site/pelicanconf.py`` and ``site/publishconf.py``
so there's a single source of truth. Writes ``site/content/extra/og.png`` so
Pelican copies it to the site root.
"""

from __future__ import annotations

import sys
from pathlib import Path

SITE_DIR = Path(__file__).resolve().parent.parent / "site"
sys.path.insert(0, str(SITE_DIR))

from pelicanconf import AUTHOR, SITESUBTITLE  # noqa: E402
from publishconf import SITEURL  # noqa: E402

from PIL import Image, ImageDraw, ImageFont  # noqa: E402

OUT = SITE_DIR / "content" / "extra" / "og.png"

W, H = 1200, 630
BG = (17, 19, 26)         # matches dark theme --bg
FG = (232, 234, 239)      # --fg
ACCENT = (122, 167, 255)  # --accent (dark)
MUTED = (160, 164, 173)   # --fg-muted

NAME = AUTHOR
TITLE = SITESUBTITLE
URL = SITEURL.removeprefix("https://").removeprefix("http://").rstrip("/")


def _font(size: int) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    candidates = [
        "/System/Library/Fonts/SFNS.ttf",
        "/System/Library/Fonts/Supplemental/Arial.ttf",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
    ]
    for path in candidates:
        if Path(path).exists():
            return ImageFont.truetype(path, size)
    return ImageFont.load_default()


def main() -> None:
    img = Image.new("RGB", (W, H), BG)
    draw = ImageDraw.Draw(img)

    draw.rectangle((80, 80, 96, H - 80), fill=ACCENT)

    draw.text((140, 200), NAME, font=_font(72), fill=FG)
    draw.text((140, 300), TITLE, font=_font(40), fill=MUTED)
    draw.text((140, H - 130), URL, font=_font(28), fill=ACCENT)

    OUT.parent.mkdir(parents=True, exist_ok=True)
    img.save(OUT, format="PNG", optimize=True)
    print(f"wrote {OUT}")


if __name__ == "__main__":
    main()
