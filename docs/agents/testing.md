# Testing and validation

## Required commands

- **After every Nix file change**: `nix fmt`
- **Before marking work complete**: `nix flake check --print-build-logs`

## Test invariants

- Preserve cheap structural checks for all six palettes.
- Preserve `dark-hard` as the representative variant for adapter contracts, smoke tests, gating checks, and the activation package build unless the real consumer variant changes.
- Keep tests proving that the module does not enable applications, disabled applications receive no adapter output, defaults remain `dark-medium`, and invalid mode or contrast values fail.
- When public behavior changes, update `README.md` and the relevant executable contracts together.
