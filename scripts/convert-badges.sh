#!/usr/bin/env bash
# Download and convert badge SVGs to PDF for reliable LaTeX inclusion
# Usage: ./scripts/convert-badges.sh
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
BADGES_DIR="$ROOT/images"
mkdir -p "$BADGES_DIR"

# List of remote badges: each line is "basename URL"
BADGES_LIST="\
zenodo.17343164 https://zenodo.org/badge/DOI/10.5281/zenodo.17343164.svg\
"

echo "$BADGES_LIST" | while read -r name url; do
  svg_path="$BADGES_DIR/${name}.svg"
  pdf_path="$BADGES_DIR/${name}.pdf"

  echo "Downloading $url -> $svg_path"
  curl -sS -L -o "$svg_path" "$url"

  echo "Converting $svg_path -> $pdf_path"
  if command -v inkscape >/dev/null 2>&1; then
    inkscape "$svg_path" --export-type=pdf --export-filename="$pdf_path"
  elif command -v rsvg-convert >/dev/null 2>&1; then
    rsvg-convert -f pdf -o "$pdf_path" "$svg_path"
  else
    # Try cairosvg via python
    python - <<PY
import sys
try:
    import cairosvg
    cairosvg.svg2pdf(url='$svg_path', write_to='$pdf_path')
    print('converted with cairosvg')
except Exception as e:
    print('conversion failed:', e)
    sys.exit(2)
PY
  fi
  echo "Wrote $pdf_path"
done

echo "All badges processed."
