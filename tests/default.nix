{
  home-manager,
  pkgs,
  self,
}:
let
  inherit (pkgs) lib;

  modes = [
    "dark"
    "light"
  ];
  contrasts = [
    "hard"
    "medium"
    "soft"
  ];
  programs = [
    "bat"
    "btop"
    "fzf"
    "starship"
    "tmux"
  ];
  variants = lib.cartesianProduct {
    mode = modes;
    contrast = contrasts;
  };
  representativeVariant = {
    mode = "dark";
    contrast = "hard";
  };

  mkHomeWithSettings =
    {
      enabledPrograms ? programs,
      everforestSettings,
    }:
    home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        self.homeManagerModules.default
        {
          home = {
            username = "everforest-test";
            homeDirectory = "/Users/everforest-test";
            stateVersion = "25.11";
          };

          everforest = everforestSettings;
          programs =
            lib.genAttrs programs (program: {
              enable = builtins.elem program enabledPrograms;
            })
            // {
              tmux = {
                enable = builtins.elem "tmux" enabledPrograms;
                secureSocket = false;
              };
            };
        }
      ];
    };

  mkHome =
    {
      contrast ? representativeVariant.contrast,
      enabledPrograms ? programs,
      everforestEnable ? true,
      mode ? representativeVariant.mode,
    }:
    mkHomeWithSettings {
      inherit enabledPrograms;
      everforestSettings = {
        enable = everforestEnable;
        inherit contrast mode;
      };
    };

  adapterApplied =
    program: cfg:
    if program == "bat" then
      (cfg.programs.bat.config.theme or null) == "everforest" && cfg.programs.bat.themes ? everforest
    else if program == "btop" then
      (cfg.programs.btop.settings.color_theme or null) == "everforest"
      && cfg.programs.btop.themes ? everforest
    else if program == "fzf" then
      cfg.programs.fzf.colors != { }
    else if program == "starship" then
      (cfg.programs.starship.settings.palette or null) == "everforest"
      && (cfg.programs.starship.settings.palettes or { }) ? everforest
    else if program == "tmux" then
      lib.hasInfix "# Everforest Tmux colors" cfg.programs.tmux.extraConfig
    else
      false;

  gatingOk = lib.all (
    enabledProgram:
    let
      cfg = (mkHome { enabledPrograms = [ enabledProgram ]; }).config;
    in
    lib.all (program: adapterApplied program cfg == (program == enabledProgram)) programs
  ) programs;

  disabledThemeConfig =
    (mkHome {
      everforestEnable = false;
      enabledPrograms = programs;
    }).config;
  noProgramsConfig = (mkHome { enabledPrograms = [ ]; }).config;
  disabledThemeOk = lib.all (program: !(adapterApplied program disabledThemeConfig)) programs;
  noProgramsOk = lib.all (program: !(adapterApplied program noProgramsConfig)) programs;

  defaultThemeConfig =
    (mkHomeWithSettings {
      enabledPrograms = [ "fzf" ];
      everforestSettings.enable = true;
    }).config;
  invalidModeDrvPath =
    (mkHomeWithSettings {
      enabledPrograms = [ "fzf" ];
      everforestSettings = {
        enable = true;
        mode = "invalid";
      };
    }).activationPackage.drvPath;
  invalidContrastDrvPath =
    (mkHomeWithSettings {
      enabledPrograms = [ "fzf" ];
      everforestSettings = {
        enable = true;
        mode = "dark";
        contrast = "invalid";
      };
    }).activationPackage.drvPath;
  invalidModeResult = builtins.tryEval invalidModeDrvPath;
  invalidContrastResult = builtins.tryEval invalidContrastDrvPath;

  backgroundKeys = [
    "bg_dim"
    "bg0"
    "bg1"
    "bg2"
    "bg3"
    "bg4"
    "bg5"
    "bg_visual"
    "bg_red"
    "bg_yellow"
    "bg_green"
    "bg_blue"
    "bg_purple"
  ];
  foregroundKeys = [
    "fg"
    "red"
    "orange"
    "yellow"
    "green"
    "aqua"
    "blue"
    "purple"
    "grey0"
    "grey1"
    "grey2"
    "statusline1"
    "statusline2"
    "statusline3"
  ];
  sorted = lib.sort builtins.lessThan;
  expectedKeys = sorted (backgroundKeys ++ foregroundKeys);
  validHex = value: builtins.match "#[0-9a-f]{6}" value != null;
  paletteData = import ../palette/data.nix;
  paletteOk =
    sorted (builtins.attrNames paletteData.backgrounds) == sorted modes
    && sorted (builtins.attrNames paletteData.foregrounds) == sorted modes
    && lib.all (
      mode:
      sorted (builtins.attrNames paletteData.backgrounds.${mode}) == sorted contrasts
      && sorted (builtins.attrNames paletteData.foregrounds.${mode}) == sorted foregroundKeys
      && lib.all validHex (builtins.attrValues paletteData.foregrounds.${mode})
    ) modes
    && lib.all (
      variant:
      let
        background = paletteData.backgrounds.${variant.mode}.${variant.contrast};
        raw = import ../palette { inherit (variant) mode contrast; };
      in
      sorted (builtins.attrNames background) == sorted backgroundKeys
      && lib.all validHex (builtins.attrValues background)
      && sorted (builtins.attrNames raw) == expectedKeys
      && lib.all validHex (builtins.attrValues raw)
    ) variants;

  expectedFzf = raw: semantic: {
    inherit (raw) fg;
    bg = "-1";
    "list-fg" = raw.fg;
    "list-bg" = "-1";
    "selected-fg" = raw.fg;
    "selected-bg" = raw.bg_visual;
    "preview-fg" = raw.fg;
    "preview-bg" = "-1";
    query = raw.fg;
    "input-fg" = raw.fg;
    "input-bg" = "-1";
    "header-fg" = raw.blue;
    "header-bg" = "-1";
    "footer-fg" = raw.blue;
    "footer-bg" = "-1";
    "current-fg" = raw.fg;
    "current-bg" = raw.bg_visual;
    "alt-bg" = "-1";
    gutter = "-1";
    "alt-gutter" = "-1";
    hl = raw.green;
    "selected-hl" = semantic.accent;
    "current-hl" = semantic.accent;
    ghost = raw.grey1;
    disabled = raw.grey1;
    info = raw.grey1;
    border = raw.grey1;
    "list-border" = raw.grey1;
    "preview-border" = raw.grey1;
    "input-border" = raw.grey1;
    "header-border" = raw.grey1;
    "footer-border" = raw.grey1;
    scrollbar = raw.grey1;
    "preview-scrollbar" = raw.grey1;
    separator = raw.grey1;
    "gap-line" = raw.grey1;
    label = raw.blue;
    "list-label" = raw.blue;
    "preview-label" = raw.blue;
    "input-label" = raw.blue;
    "header-label" = raw.blue;
    "footer-label" = raw.blue;
    prompt = semantic.accent;
    pointer = semantic.accent;
    marker = raw.green;
    spinner = raw.aqua;
  };

  defaultRaw = import ../palette {
    mode = "dark";
    contrast = "medium";
  };
  defaultSemantic = import ../lib/semantic.nix defaultRaw;
  defaultThemeUsesPalette =
    defaultThemeConfig.programs.fzf.colors == expectedFzf defaultRaw defaultSemantic;

  expectedStarship = raw: semantic: {
    inherit (raw)
      aqua
      blue
      green
      orange
      purple
      red
      yellow
      ;
    inherit (semantic)
      accent
      error
      info
      success
      warning
      ;
    black = raw.grey0;
    cyan = raw.aqua;
    white = raw.fg;
    "bright-black" = raw.grey1;
    "bright-red" = raw.red;
    "bright-green" = raw.green;
    "bright-yellow" = raw.yellow;
    "bright-blue" = raw.blue;
    "bright-purple" = raw.purple;
    "bright-cyan" = raw.aqua;
    "bright-white" = raw.fg;
    muted = raw.grey1;
  };

  expectedBtop = raw: semantic: {
    main_bg = "";
    main_fg = raw.fg;
    title = raw.fg;
    hi_fg = semantic.accent;
    selected_bg = raw.bg_visual;
    selected_fg = raw.fg;
    inactive_fg = raw.grey1;
    graph_text = raw.grey1;
    meter_bg = raw.bg1;
    proc_misc = raw.green;
    cpu_box = raw.grey1;
    mem_box = raw.grey1;
    net_box = raw.grey1;
    proc_box = raw.grey1;
    div_line = raw.grey1;
    temp_start = raw.red;
    temp_mid = "";
    temp_end = "";
    cpu_start = raw.green;
    cpu_mid = "";
    cpu_end = "";
    free_start = raw.green;
    free_mid = "";
    free_end = "";
    cached_start = raw.aqua;
    cached_mid = "";
    cached_end = "";
    available_start = raw.blue;
    available_mid = "";
    available_end = "";
    used_start = raw.red;
    used_mid = "";
    used_end = "";
    download_start = raw.blue;
    download_mid = "";
    download_end = "";
    upload_start = raw.orange;
    upload_mid = "";
    upload_end = "";
    process_start = raw.purple;
    process_mid = "";
    process_end = "";
    proc_pause_bg = raw.bg_red;
    proc_follow_bg = raw.bg_blue;
    proc_banner_bg = raw.bg_purple;
    proc_banner_fg = raw.fg;
    followed_bg = raw.bg_blue;
    followed_fg = raw.fg;
  };

  home = mkHome { };
  cfg = home.config;
  raw = import ../palette representativeVariant;
  semantic = import ../lib/semantic.nix raw;
  batTheme = import ../lib/render-syntect.nix { inherit raw; };
  btopTheme = cfg.programs.btop.themes.everforest;
  btopExpected = expectedBtop raw semantic;
  tmuxColors = cfg.programs.tmux.extraConfig;
  tmuxPaletteVariablesOk = lib.all (
    name: lib.hasInfix "set -g @everforest_${name} '${raw.${name}}'" tmuxColors
  ) expectedKeys;
  tmuxColorStylesOk = lib.all (line: lib.hasInfix line tmuxColors) [
    ''set -g status-style "fg=#{@everforest_fg},bg=#{@everforest_bg_dim},default"''
    ''set -g mode-style "fg=#{@everforest_purple},bg=#{@everforest_bg_visual}"''
    ''set -g window-status-style "fg=#{@everforest_grey1},bg=#{@everforest_bg0}"''
    ''set -g window-status-current-style "fg=#{@everforest_fg},bg=#{@everforest_bg_green}"''
    ''set -g window-status-activity-style "fg=#{@everforest_yellow},bg=#{@everforest_bg1}"''
    ''set -g window-status-bell-style "fg=#{@everforest_bg0},bg=#{@everforest_statusline3}"''
    ''set -g pane-border-style "fg=#{@everforest_grey1}"''
    ''set -g pane-active-border-style "fg=#{@everforest_blue}"''
    ''set -g display-panes-colour "${raw.orange}"''
    ''set -g display-panes-active-colour "${raw.blue}"''
    ''set -g message-style "fg=#{@everforest_statusline3},bg=#{@everforest_bg_dim}"''
    ''set -g message-command-style "fg=#{@everforest_fg},bg=#{@everforest_bg1}"''
    ''set -g clock-mode-colour "${raw.blue}"''
  ];
  tmuxOwnsColorsOnly = lib.all (setting: !lib.hasInfix setting tmuxColors) [
    "set -g status "
    "set -g status-interval "
    "set -g status-left-length "
    "set -g status-left "
    "set -g status-right-length "
    "set -g status-right "
    "set -g window-status-separator "
    "set -g window-status-format "
    "set -g window-status-current-format "
    "terminal-features"
    "terminal-overrides"
    "default-terminal"
  ];
  adapterContractOk =
    cfg.programs.fzf.colors == expectedFzf raw semantic
    && cfg.programs.starship.settings.palette == "everforest"
    && cfg.programs.starship.settings.palettes.everforest == expectedStarship raw semantic
    && lib.all (name: lib.hasInfix ''theme[${name}]="${btopExpected.${name}}"'' btopTheme) (
      builtins.attrNames btopExpected
    )
    && lib.all (color: lib.hasInfix color batTheme) [
      raw.fg
      raw.bg1
      raw.bg_visual
      raw.red
      raw.orange
      raw.yellow
      raw.green
      raw.aqua
      raw.blue
      raw.purple
      raw.grey1
    ]
    && tmuxPaletteVariablesOk
    && tmuxColorStylesOk
    && tmuxOwnsColorsOnly;

  batArtifact = pkgs.writeText "everforest-dark-hard.tmTheme" batTheme;
  btopArtifact = pkgs.writeText "everforest-dark-hard.theme" btopTheme;
  fzfSpec = lib.concatStringsSep "," (
    lib.mapAttrsToList (colorName: value: "${colorName}:${value}") cfg.programs.fzf.colors
  );
  fzfValues = pkgs.writeText "everforest-dark-hard-fzf-colors" (
    lib.concatStringsSep "\n" (builtins.attrValues cfg.programs.fzf.colors)
  );
  paletteValues = pkgs.writeText "everforest-dark-hard-palette" (
    lib.concatStringsSep "\n" (builtins.attrValues raw)
  );
  starshipArtifact =
    (pkgs.formats.toml { }).generate "everforest-dark-hard-starship.toml"
      cfg.programs.starship.settings;
  tmuxArtifact = pkgs.writeText "everforest-dark-hard-tmux-colors.conf" tmuxColors;

  colorChecker = pkgs.writeText "check-palette-colors.py" ''
    import re
    import sys

    allowed = set(open(sys.argv[1], encoding="utf-8").read().split())
    for path in sys.argv[2:]:
        text = open(path, encoding="utf-8").read()
        unknown = sorted(set(re.findall(r"#[0-9a-fA-F]{6}", text)) - allowed)
        if unknown:
            raise SystemExit(f"{path} contains non-palette colors: {unknown}")
  '';
in
{
  activation-dark-hard = home.activationPackage;

  palette-contract =
    assert paletteOk;
    pkgs.runCommand "everforest-palette-contract" { } ''
      touch "$out"
    '';

  module-contract =
    assert gatingOk;
    assert disabledThemeOk;
    assert noProgramsOk;
    assert defaultThemeConfig.everforest.mode == "dark";
    assert defaultThemeConfig.everforest.contrast == "medium";
    assert defaultThemeUsesPalette;
    assert !invalidModeResult.success;
    assert !invalidContrastResult.success;
    pkgs.runCommand "everforest-module-contract" { } ''
      touch "$out"
    '';

  adapter-contract =
    assert adapterContractOk;
    pkgs.runCommand "everforest-adapter-contract" { } ''
      touch "$out"
    '';

  adapter-smoke =
    pkgs.runCommand "everforest-adapter-smoke"
      {
        nativeBuildInputs = [
          pkgs.bat
          pkgs.fzf
          pkgs.libxml2
          pkgs.python3
          pkgs.starship
          pkgs.tmux
        ];
      }
      ''
        set -eu
        mkdir -p "$TMPDIR/bat/config/bat/themes" "$TMPDIR/bat/cache"
        cp ${batArtifact} "$TMPDIR/bat/config/bat/themes/everforest.tmTheme"
        xmllint --noout ${batArtifact}
        ! grep -q '<key>background</key>' ${batArtifact}
        XDG_CONFIG_HOME="$TMPDIR/bat/config" XDG_CACHE_HOME="$TMPDIR/bat/cache" bat cache --build >/dev/null
        XDG_CONFIG_HOME="$TMPDIR/bat/config" XDG_CACHE_HOME="$TMPDIR/bat/cache" bat --list-themes | grep -Fx everforest

        printf 'item\n' | fzf --filter item --color '${fzfSpec}' >/dev/null

        mkdir -p "$TMPDIR/starship"
        HOME="$TMPDIR/starship" STARSHIP_CONFIG=${starshipArtifact} starship print-config >/dev/null

        mkdir -p "$TMPDIR/tmux"
        TMUX_TMPDIR="$TMPDIR/tmux" \
          tmux -L everforest-dark-hard -f /dev/null new-session -d -s everforest-test
        TMUX_TMPDIR="$TMPDIR/tmux" \
          tmux -L everforest-dark-hard source-file ${tmuxArtifact}
        TMUX_TMPDIR="$TMPDIR/tmux" tmux -L everforest-dark-hard kill-server

        python3 ${colorChecker} ${paletteValues} \
          ${batArtifact} ${btopArtifact} ${fzfValues} ${starshipArtifact} ${tmuxArtifact}
        touch "$out"
      '';
}
