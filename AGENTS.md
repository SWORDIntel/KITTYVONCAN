# Repository Guidelines

Contributor notes for KITTYVONCAN: a Bash-driven enhancement pack for the kitty terminal. Keep edits tight, reversible, and aligned with the existing install/test flow.

## Project Structure & Module Organization
- `install.sh`, `uninstall.sh`: entrypoints for applying or rolling back configurations.
- `config/kitty.conf`, `config/scripts/`: core settings plus helpers like `context_menu.sh` and `install_deps.sh`.
- `themes/`: theme presets; keep additions named after the palette (e.g., `solarized.conf`).
- `docs/`: long-form documentation; mirror any new behavior here.
- `tests/`: shell test harnesses (`validate_config.sh`, `test_features.sh`) run from repo root.
- `$HOME/.config/kitty/kittyvoncan/`: install target; avoid hard-coding other paths.

## Build, Test, and Development Commands
- `./install.sh --dry-run`: preview actions without writing to the kitty config.
- `./install.sh --minimal|--full|--with-zsh-autosuggestions`: install variants; prefer `--dry-run` before changing user machines.
- `./tests/validate_config.sh`: quick sanity checks on generated configs.
- `./tests/test_features.sh`: exercises feature set; use before PRs that alter bindings, themes, or scripts.
- `./uninstall.sh --restore-original`: restore backups if testing goes sideways.

## Coding Style & Naming Conventions
- Bash with `set -euo pipefail`; indent with 4 spaces; prefer lowercase `snake_case` for functions/vars.
- Quote variables, check commands with `command -v`, and guard user-facing changes with clear prompts.
- Configuration files use `.conf`; scripts use `.sh` with executable bit and `#!/bin/bash`.
- Keep messages and output concise; favor `print_step/print_success` pattern already in `install.sh`.

## Testing Guidelines
- Add or adjust `tests/*.sh`; name new scripts `test_<area>.sh` and run them directly via `bash`.
- Verify both install and uninstall paths (`--dry-run`, `--restore-original`) when modifying installer logic.
- For linting, run `bash -n <file>` or `shellcheck <file>` (if available) before submitting.

## Commit & Pull Request Guidelines
- Follow the existing Conventional Commit style (`feat:`, `fix:`, `chore:`); merges use standard merge commits.
- PRs should include: summary of changes, flags tested (e.g., `--minimal`, `--with-zsh-autosuggestions`), and test output snippets.
- Reference related issues; include screenshots only when modifying visual assets (themes).
- Keep changes scoped; separate feature work from formatting-only edits.

## Security & Configuration Tips
- Installer writes to `~/.config/kitty/`; always keep backups enabled and avoid editing installed copies directly—edit repo files and reinstall.
- Do not invoke package managers silently; respect `--skip-deps` and document any new dependency.
- Avoid storing secrets in configs or scripts; prefer environment variables when needed.
