#!/bin/bash
# inject_dates.sh
# Run this from the website root before jekyll build.
# It goes into each submodule, finds every markdown file,
# gets its true last-commit date from git, and injects/updates
# the last_modified_at field in the frontmatter so that
# jekyll-last-modified-at uses the correct date instead of
# falling back to filesystem mtime.

set -euo pipefail

WEBSITE_ROOT="$(pwd)"

git submodule foreach --recursive '
  echo "==> Processing submodule: $displaypath"

  # Loop over every markdown file tracked by this submodule
  git ls-files "*.md" "*.markdown" | while IFS= read -r file; do

    # Get the last commit date for this specific file
    last_date=$(git log -1 --date=format:"%Y-%m-%d %H:%M:%S" --pretty=format:"%cd" -- "$file" 2>/dev/null)

    # Skip if git returned nothing (untracked or no history)
    [ -z "$last_date" ] && continue

    # Full path: parent repo root + submodule path + file
    filepath="$toplevel/$displaypath/$file"

    # Skip if file does not exist on disk
    [ -f "$filepath" ] || continue

    # Check if file starts with a YAML frontmatter block
    if head -1 "$filepath" | grep -q "^---"; then

      # If last_modified_at already exists in frontmatter, replace it
      if grep -q "^last_modified_at:" "$filepath"; then
        sed -i "s|^last_modified_at:.*|last_modified_at: $last_date|" "$filepath"

      # Otherwise insert it after the opening --- line
      else
        sed -i "0,/^---/{s|^---|---\nlast_modified_at: $last_date|}" "$filepath"
      fi

    else
      # No frontmatter at all — prepend one
      tmpfile=$(mktemp)
      printf -- "---\nlast_modified_at: %s\n---\n" "$last_date" | cat - "$filepath" > "$tmpfile"
      mv "$tmpfile" "$filepath"
    fi

  done

  echo "    done."
'

echo ""
echo "All submodule dates injected successfully."