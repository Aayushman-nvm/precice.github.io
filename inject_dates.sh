#!/bin/bash
# inject_dates.sh
# Run this from the website root before jekyll build.
# It goes into each submodule, finds every markdown file,
# gets its true last-commit date from git, and injects/updates
# the last_modified_at field in the frontmatter so that
# jekyll-last-modified-at uses the correct date instead of
# falling back to filesystem mtime.

set -euo pipefail

git submodule foreach --recursive '
  echo "==> Processing submodule: $displaypath"

  git ls-files "*.md" "*.markdown" | while IFS= read -r file; do

    last_date=$(git log -1 --date=format:"%Y-%m-%d %H:%M:%S" --pretty=format:"%cd" -- "$file" 2>/dev/null)

    if [ -z "$last_date" ]; then
      echo "    SKIP (no git date): $file"
      continue
    fi

    filepath="$toplevel/$displaypath/$file"

    if [ ! -f "$filepath" ]; then
      echo "    SKIP (not on disk): $file"
      continue
    fi

    if awk '\''NR==1 { if ($0 == "---") { in_front=1; next } else { exit 1 } } in_front && NR>1 && $0 == "---" { exit 0 } END { exit 1 }'\'' "$filepath"; then

      if grep -q "^last_modified_at:" "$filepath"; then
        sed -i "s|^last_modified_at:.*|last_modified_at: $last_date|" "$filepath"
      else
        sed -i "0,/^---/{s|^---|---\nlast_modified_at: $last_date|}" "$filepath"
      fi

    else
      tmpfile=$(mktemp)
      printf -- "---\nlast_modified_at: %s\n---\n" "$last_date" | cat - "$filepath" > "$tmpfile"
      mv "$tmpfile" "$filepath"
    fi

    echo "    OK: $file -> $last_date"

  done

  echo "    done."
'

echo ""
echo "All submodule dates injected successfully."