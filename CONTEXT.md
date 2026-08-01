# Project context

Reference document for the everforest-darwin Home Manager theme module. Read the relevant sections before working in that area.

## Project intent

- Keep this a small, personal-use-first Home Manager theme module.
- Prefer fewer files, shorter code, fewer dependencies, and direct maintenance over abstractions for hypothetical users or future scale.
- Preserve the existing static design unless a concrete personal requirement calls for expansion.

## Public contract and scope

- Keep `homeManagerModules.default` as the only public module entry point.
- Keep `everforest.enable`, `everforest.mode`, and `everforest.contrast` as the public options. The defaults are `dark` and `medium`.
- Never enable `programs.<application>.enable` from this module. Apply an adapter only when both Everforest and that application are enabled.
- The supported adapters are Bat, Btop, Fzf, Starship, and Tmux. Do not add another adapter without an explicit requirement.
- Do not add automatic mode selection, per-application theme switches, or a public palette API without an explicit requirement.
- Do not manage application installation, Terminal.app profiles, fonts, wallpapers, icons, macOS appearance, or `COLORTERM`.
- The module may evaluate elsewhere, but development, CI, and support target `aarch64-darwin` only.

## Palette invariants

- Treat `palette/data.nix` as the canonical, manually maintained palette source.
- Preserve all six `dark|light` × `hard|medium|soft` variants and their existing key sets.
- Store colors as lowercase `#rrggbb` values only. Do not store cterm values, ANSI 256-color values, alpha, or generated variants.
- Every literal Hex color emitted by project code must come from the selected palette. Do not introduce blending, brightness or saturation adjustments, or third-party extra colors.
- Keep semantic aliases centralized in `lib/semantic.nix`.
- Do not add upstream network checks, automatic synchronization, generators, scheduled palette workflows, or a second machine-readable palette source.
- When an upstream refresh is explicitly requested, compare Everforest manually, edit `palette/data.nix` directly, and retain the attribution in `THIRD_PARTY_LICENSES.md`.

## Adapter ownership

- Do not use `lib.mkForce` for theme settings.
- Bat owns only its generated `everforest` syntect theme and theme selection; preserve unrelated Bat behavior settings.
- Btop owns its theme colors and the existing no-gradient choice; keep the main background inherited from the terminal.
- Fzf uses `programs.fzf.colors`; do not construct a `--color` option in `defaultOptions`.
- Starship owns only custom palette injection and activation; do not change prompt layout, module order, symbols, or text styling.
- Tmux owns palette variables and color-only styles. Do not add status layout, formats, lengths, separators, Powerline glyphs, font attributes, key bindings, terminal capability settings, or other behavior.
- Keep exact color mappings in adapter source and executable tests rather than duplicating them in this file.

## Repository discipline

- `README.md` is the user-facing contract, tests are the detailed executable contract, and `THIRD_PARTY_LICENSES.md` is the palette provenance record.
- Do not add palette generators, JSON or YAML mirrors, template systems, compatibility shims, documentation sites, plugin frameworks, project-specific caches, or automated release machinery without an explicit requirement.
- Keep `main` suitable for rolling use through a pinned flake revision, tag, or commit.
