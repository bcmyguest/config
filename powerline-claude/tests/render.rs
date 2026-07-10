use powerline_claude::render::{Mode, Segment, render};
use powerline_claude::theme::{Rgb, SegmentColors};

const HARD: char = '\u{e0b0}'; //
const THIN: char = '\u{e0b1}'; //

fn seg(text: &str, fg: u32, bg: u32) -> Segment {
    Segment {
        text: text.to_string(),
        colors: SegmentColors {
            fg: Rgb::hex(fg),
            bg: Rgb::hex(bg),
        },
    }
}

fn fg_code(hex: u32) -> String {
    let c = Rgb::hex(hex);
    format!("\x1b[38;2;{};{};{}m", c.r, c.g, c.b)
}

fn bg_code(hex: u32) -> String {
    let c = Rgb::hex(hex);
    format!("\x1b[48;2;{};{};{}m", c.r, c.g, c.b)
}

#[test]
fn single_segment_flat_paints_padded_text_and_resets() {
    let out = render(&[seg("opus", 0xb4befe, 0x1e1e2e)], Mode::Flat);
    assert_eq!(
        out,
        format!("{}{} opus \x1b[0m", bg_code(0x1e1e2e), fg_code(0xb4befe))
    );
}

#[test]
fn hard_separator_bridges_differing_backgrounds() {
    let out = render(
        &[seg("a", 0x111111, 0xaaaaaa), seg("b", 0x222222, 0xbbbbbb)],
        Mode::Patched,
    );
    // separator: fg = left bg, bg = right bg
    let bridge = format!("{}{}{HARD}", bg_code(0xbbbbbb), fg_code(0xaaaaaa));
    assert!(
        out.contains(&bridge),
        "missing hard separator bridge in {out:?}"
    );
}

#[test]
fn thin_separator_divides_equal_backgrounds() {
    let out = render(
        &[seg("a", 0x111111, 0xaaaaaa), seg("b", 0x222222, 0xaaaaaa)],
        Mode::Patched,
    );
    let divider = format!("{}{}{THIN}", bg_code(0xaaaaaa), fg_code(0x222222));
    assert!(out.contains(&divider), "missing thin divider in {out:?}");
    // the hard separator still closes the bar at the end, so count occurrences
    assert_eq!(
        out.matches(HARD).count(),
        1,
        "only the trailing arrow: {out:?}"
    );
}

#[test]
fn patched_bar_opens_with_fade_and_closes_with_arrow_on_default_bg() {
    let out = render(&[seg("a", 0x111111, 0xaaaaaa)], Mode::Patched);
    let fade = format!("{}░▒▓", fg_code(0xaaaaaa));
    assert!(out.starts_with(&fade), "missing leading fade in {out:?}");
    let close = format!("\x1b[0m{}{HARD}\x1b[0m", fg_code(0xaaaaaa));
    assert!(out.ends_with(&close), "missing trailing arrow in {out:?}");
}

#[test]
fn compatible_mode_avoids_private_use_glyphs() {
    let out = render(
        &[seg("a", 0x111111, 0xaaaaaa), seg("b", 0x222222, 0xbbbbbb)],
        Mode::Compatible,
    );
    assert!(
        out.chars().all(|c| !('\u{e000}'..='\u{f8ff}').contains(&c)),
        "private-use glyph leaked into compatible mode: {out:?}"
    );
    assert!(out.contains('▶'), "expected ▶ separator in {out:?}");
}

#[test]
fn flat_mode_has_no_separators_or_fade() {
    let out = render(
        &[seg("a", 0x111111, 0xaaaaaa), seg("b", 0x222222, 0xaaaaaa)],
        Mode::Flat,
    );
    for c in [HARD, THIN, '▶', '░'] {
        assert!(!out.contains(c), "unexpected {c:?} in flat output {out:?}");
    }
}

#[test]
fn empty_segment_list_renders_nothing() {
    assert_eq!(render(&[], Mode::Patched), "");
}

#[test]
fn mode_parses_from_cli_names() {
    assert_eq!("patched".parse::<Mode>().unwrap(), Mode::Patched);
    assert_eq!("compatible".parse::<Mode>().unwrap(), Mode::Compatible);
    assert_eq!("flat".parse::<Mode>().unwrap(), Mode::Flat);
    assert!("fancy".parse::<Mode>().is_err());
}
