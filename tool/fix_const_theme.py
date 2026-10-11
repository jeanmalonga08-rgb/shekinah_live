import re
from pathlib import Path

root = Path(__file__).resolve().parents[1] / "lib"
adaptive = re.compile(
    r"AppTheme\.(white|softWhite|grey|muted|primaryDark|"
    r"background|surfaceElevated|surface|headerGradient)\b"
)
const_ctor = re.compile(r"\bconst\s+(?=([A-Z_][\w.]*)\s*[\(<])")


def strip_const_for_adaptive(src: str) -> str:
    out: list[str] = []
    i = 0
    while True:
        m = const_ctor.search(src, i)
        if not m:
            out.append(src[i:])
            break
        out.append(src[i : m.start()])
        j = m.end()
        while j < len(src) and src[j] not in "(<":
            j += 1
        if j >= len(src):
            out.append(src[m.start() :])
            break
        open_ch = src[j]
        close_ch = ")" if open_ch == "(" else ">"
        depth = 0
        k = j
        while k < len(src):
            ch = src[k]
            if ch == open_ch:
                depth += 1
            elif ch == close_ch:
                depth -= 1
                if depth == 0:
                    k += 1
                    break
            elif ch in "'\"":
                q = ch
                k += 1
                while k < len(src) and src[k] != q:
                    if src[k] == "\\":
                        k += 2
                        continue
                    k += 1
            k += 1
        body = src[m.end() : k]
        if adaptive.search(body):
            out.append(src[m.end() : k])  # drop 'const '
        else:
            out.append(src[m.start() : k])
        i = k
    return "".join(out)


changed: list[str] = []
for path in root.rglob("*.dart"):
    src = path.read_text(encoding="utf-8")
    updated = strip_const_for_adaptive(src)
    if updated != src:
        path.write_text(updated, encoding="utf-8")
        changed.append(str(path.relative_to(root)))

print(f"Updated {len(changed)} files")
for f in changed:
    print(f)
