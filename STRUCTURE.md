# preCICE Website Repository Structure

## How the Site Assembles

```
_config.yml   ← master registry; if it's not here, Jekyll ignores it
Gemfile       ← Ruby/Jekyll plugin dependencies
_data/        ← YAML content injected into templates (nav, sidebars, etc.)
_includes/    ← reusable HTML components (nav, sidebar, footer…)
_layouts/     ← page skeletons that wrap content files
content/      ← the actual pages visitors read
imported/     ← git submodules for cross-repo content
```

---

## Directories

| Path | Purpose |
|---|---|
| `_config.yml` | ★ Start here. Registers collections, plugins, nav, and build settings |
| `Gemfile` | Ruby dependencies. Run `bundle install` after changes |
| `_data/` | YAML files powering nav and sidebars. Edit these, not the HTML |
| `_data/sidebars/` | Per-section sidebar trees consumed by `_includes/sidebar.html` |
| `_includes/` | Reusable HTML partials (topnav, sidebar, footer, head) |
| `_layouts/` | Page skeletons. `default.html` is the base most others extend |
| `_plugins/` | Ruby plugins for build-time tasks (e.g. injecting last-updated dates) |
| `content/` | All website pages. Primary working directory for contributors |
| `content/docs/` | Technical reference docs (adapters, config, installation, API…) |
| `content/tutorials/` | Step-by-step coupled simulation tutorials |
| `content/community/` | Contribute guides, workshops, minisymposia |
| `collections/` | Publications and testimonials (add a `.md` file, no code needed) |
| `imported/` | Git submodules. Run `git submodule update --init --recursive` after clone |
| `assets/` | JSON data files and `.bib` bibliography files |
| `css/` | Custom styles and KaTeX fonts |
| `js/` | Client-side scripts (API fetching, UI behavior, libraries) |
| `images/` | Site images |
| `material/` | Source graphics for people writing on preCICE |
| `tools/` | Python scripts for fetching external data at build time |
| `doxygen/` | Patches Doxygen API docs for `main`/`develop` during CI deploy |
| `.github/` | Issue templates and CI/CD workflows |
| `.gitmodules` | Submodule registry. Update when adding cross-repo dependencies |
| `pdf/` + `pdfconfigs/` | PDF generation artifacts and config |
| `licenses/` | MIT license and NavCo jQuery component license |

---

## Quick Reference

| Task | Where |
|---|---|
| Add a nav or sidebar entry | `_data/` |
| Change a shared UI component | `_includes/` |
| Change page layout/structure | `_layouts/` |
| Add a publication or testimonial | `collections/` |
| Debug a build-time error | `_plugins/` or `Gemfile` |
| Debug a CI/deploy failure | `.github/workflows/` |
| Site-wide config change | `_config.yml` |