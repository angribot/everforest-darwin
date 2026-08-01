# Consumer and Tmux safety

- Consumer validation may build an activation package with this repository supplied through an input override, but must not activate it.
- **Never** run `home-manager switch`, `darwin-rebuild switch`, or another activation command as repository validation.
- **Never** attach tests to the user's existing Tmux server. Use an isolated socket and temporary `TMUX_TMPDIR` for parser checks.
- Keep consumer-owned Tmux layout free of literal Everforest Hex values; it should reference `#{@everforest_*}` variables.
