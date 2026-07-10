use powerline_claude::theme::{Rgb, SegmentKind, Theme};

#[test]
fn default_theme_is_catppuccin_mocha() {
    let theme = Theme::default();
    assert_eq!(theme.name(), "catppuccin-mocha");
}

#[test]
fn resolves_all_six_palettes_by_name() {
    for name in [
        "catppuccin-mocha",
        "catppuccin-frappe",
        "dracula",
        "gruvbox-dark",
        "nord",
        "tokyonight",
    ] {
        let theme = Theme::by_name(name).unwrap_or_else(|e| panic!("{name}: {e}"));
        assert_eq!(theme.name(), name);
    }
}

#[test]
fn unknown_theme_error_lists_available_names() {
    let err = Theme::by_name("solarized").unwrap_err();
    assert!(err.contains("solarized"), "names the bad input: {err}");
    assert!(
        err.contains("catppuccin-mocha"),
        "lists valid themes: {err}"
    );
}

#[test]
fn mocha_cost_colors_match_vendored_palette() {
    let colors = Theme::default().colors(SegmentKind::Cost);
    assert_eq!(colors.fg, Rgb::hex(0xa6e3a1));
    assert_eq!(colors.bg, Rgb::hex(0x45475a));
}

#[test]
fn mocha_git_uses_branch_fg_on_git_bg() {
    let colors = Theme::default().colors(SegmentKind::Git);
    assert_eq!(colors.fg, Rgb::hex(0xeba0ac));
    assert_eq!(colors.bg, Rgb::hex(0x313244));
}

#[test]
fn stats_and_effort_reuse_palette_families() {
    let theme = Theme::default();
    // stats: cost fg on the context bg (keeps the alternating-bg rhythm)
    let stats = theme.colors(SegmentKind::Stats);
    assert_eq!(stats.fg, Rgb::hex(0xa6e3a1));
    assert_eq!(stats.bg, Rgb::hex(0x313244));
    // effort: model colors
    let effort = theme.colors(SegmentKind::Effort);
    assert_eq!(effort.fg, Rgb::hex(0xb4befe));
    assert_eq!(effort.bg, Rgb::hex(0x1e1e2e));
}

#[test]
fn rgb_decomposes_into_channels() {
    let rgb = Rgb::hex(0xd97757);
    assert_eq!((rgb.r, rgb.g, rgb.b), (0xd9, 0x77, 0x57));
}
