#!/usr/bin/env python3
"""Extract every embedded base64 image from the saved VRLBI HTML pages.

Decodes all `data:image/<type>;base64,<payload>` occurrences, dedupes by
content hash, and writes them into ./extracted_images/. Also records any
remote http(s) image URLs into remote_image_urls.txt for optional download.
"""
import base64
import binascii
import glob
import hashlib
import os
import re

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, "extracted_images")
os.makedirs(OUT, exist_ok=True)

EXT = {
    "jpeg": "jpg", "jpg": "jpg", "png": "png", "gif": "gif",
    "webp": "webp", "svg+xml": "svg", "bmp": "bmp", "x-icon": "ico",
    "vnd.microsoft.icon": "ico",
}

data_re = re.compile(r"data:image/([a-zA-Z0-9.+-]+);base64,([A-Za-z0-9+/=\s]+?)(?=[\"')\\}>\]])")
remote_re = re.compile(r"https?://[^\"'\s)]+\.(?:jpg|jpeg|png|gif|webp|svg)", re.I)

seen = {}            # sha1 -> filename
remote = set()
total_found = 0

for path in sorted(glob.glob(os.path.join(HERE, "*.html"))):
    with open(path, "r", encoding="utf-8", errors="ignore") as fh:
        html = fh.read()
    base = re.sub(r"[^A-Za-z0-9]+", "_", os.path.splitext(os.path.basename(path))[0])[:40]

    for subtype, payload in data_re.findall(html):
        total_found += 1
        b64 = re.sub(r"\s+", "", payload)
        # base64 length must be a multiple of 4; pad if a trailing char was cut
        b64 += "=" * (-len(b64) % 4)
        try:
            raw = base64.b64decode(b64, validate=False)
        except (binascii.Error, ValueError):
            continue
        if len(raw) < 64:          # skip 1x1 spacers / corrupt fragments
            continue
        digest = hashlib.sha1(raw).hexdigest()
        if digest in seen:
            continue
        ext = EXT.get(subtype.lower(), subtype.lower())
        name = f"{base}_{len(seen):03d}.{ext}"
        with open(os.path.join(OUT, name), "wb") as out:
            out.write(raw)
        seen[digest] = name

    remote.update(m.group(0) for m in remote_re.finditer(html))

with open(os.path.join(OUT, "remote_image_urls.txt"), "w") as fh:
    fh.write("\n".join(sorted(remote)) + ("\n" if remote else ""))

print(f"data-URIs scanned : {total_found}")
print(f"unique images     : {len(seen)}")
print(f"remote URLs listed: {len(remote)}")
print(f"output dir        : {OUT}")
