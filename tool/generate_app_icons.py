"""Regenerate launcher icon assets from logo-trans.png."""

from __future__ import annotations

from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
LOGO_DIR = ROOT / "assets" / "logo"
SOURCE = LOGO_DIR / "logo-trans.png"
CANVAS = 1024
# Logo occupies ~78% of the canvas (previously ~54%).
LOGO_SCALE = 0.78
WHITE = (255, 255, 255, 255)


def _make_transparent(image: Image.Image) -> Image.Image:
    rgba = image.convert("RGBA")
    pixels = rgba.load()
    width, height = rgba.size
    for y in range(height):
        for x in range(0, width, 1):
            r, g, b, a = pixels[x, y]
            if a < 16:
                continue
            if r < 28 and g < 28 and b < 28:
                pixels[x, y] = (0, 0, 0, 0)
    return rgba


def _fit_logo(source: Image.Image, scale: float) -> Image.Image:
    # Work on a smaller copy for faster background removal.
    working = source.copy()
    working.thumbnail((1600, 1600), Image.Resampling.LANCZOS)
    rgba = _make_transparent(working)
    bbox = rgba.getbbox()
    if not bbox:
        raise RuntimeError("Logo source has no visible content.")

    cropped = rgba.crop(bbox)
    target = int(CANVAS * scale)
    cropped.thumbnail((target, target), Image.Resampling.LANCZOS)

    canvas = Image.new("RGBA", (CANVAS, CANVAS), (0, 0, 0, 0))
    offset = ((CANVAS - cropped.width) // 2, (CANVAS - cropped.height) // 2)
    canvas.paste(cropped, offset, cropped)
    return canvas


def main() -> None:
    with Image.open(SOURCE) as source:
        foreground = _fit_logo(source, LOGO_SCALE)

    icon = Image.new("RGBA", (CANVAS, CANVAS), WHITE)
    icon.paste(foreground, (0, 0), foreground)

    foreground_path = LOGO_DIR / "app_icon_foreground.png"
    icon_path = LOGO_DIR / "app_icon.png"
    foreground.save(foreground_path, format="PNG", optimize=True)
    icon.save(icon_path, format="PNG", optimize=True)
    print(f"Wrote {foreground_path.name} (transparent)")
    print(f"Wrote {icon_path.name} (white background)")
    print(f"Logo scale: {LOGO_SCALE * 100:.0f}% of {CANVAS}px canvas")


if __name__ == "__main__":
    main()
