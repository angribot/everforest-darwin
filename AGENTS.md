# Repository instructions

See `CONTEXT.md` for project intent, public contract, palette invariants, adapter ownership, and repository discipline.

## Agent skills

### Issue tracker

Issues live in GitHub Issues for `angribot/everforest-darwin`. See `docs/agents/issue-tracker.md`.

### Triage labels

Default five-label vocabulary (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`). See `docs/agents/triage-labels.md`.

### Domain docs

Single-context layout — `CONTEXT.md` at root + `docs/adr/`. See `docs/agents/domain.md`.

### Testing and validation

Run `nix fmt` after Nix changes; run `nix flake check --print-build-logs` before marking work complete. See `docs/agents/testing.md`.

### Consumer and Tmux safety

Never activate the system configuration; use an isolated Tmux socket for tests. See `docs/agents/consumer-safety.md`.
