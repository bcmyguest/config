use powerline_claude::cli::Cli;
use powerline_claude::run;

use clap::Parser;

fn cli(args: &[&str]) -> Cli {
    Cli::try_parse_from(std::iter::once("powerline-claude").chain(args.iter().copied())).unwrap()
}

fn strip_ansi(s: &str) -> String {
    let mut out = String::new();
    let mut chars = s.chars().peekable();
    while let Some(c) = chars.next() {
        if c == '\x1b' {
            match chars.peek() {
                // CSI: consume to final byte (0x40-0x7e)
                Some('[') => {
                    for c in chars.by_ref() {
                        if ('\u{40}'..='\u{7e}').contains(&c) && c != '[' {
                            break;
                        }
                    }
                }
                // OSC: consume to BEL
                Some(']') => {
                    for c in chars.by_ref() {
                        if c == '\x07' {
                            break;
                        }
                    }
                }
                _ => {}
            }
        } else {
            out.push(c);
        }
    }
    out
}

#[test]
fn cli_defaults_match_the_documented_interface() {
    let cli = cli(&[]);
    assert_eq!(cli.modules, "logo,dir,git,model,context,cost,stats,effort");
    assert_eq!(cli.theme, "catppuccin-mocha");
    assert_eq!(cli.mode, "patched");
    assert!(!cli.no_progress);
    assert_eq!(cli.width, None);
}

#[test]
fn full_payload_renders_every_data_backed_segment() {
    // fixture dir is not a git repo on this machine, so `git` is skipped
    let out = run(
        include_str!("fixtures/full.json"),
        &cli(&["--width", "200"]),
    )
    .unwrap();
    let visible = strip_ansi(&out);
    assert_eq!(
        visible,
        "░▒▓ \u{f4f5} \u{e0b0} apps/emissions \u{e0b1} \u{f16a6} opus 4.8 \u{e0b0} \
         15,500 tok \u{e0b0} $0.71 \u{e0b0} 1h 12m \u{e0b0} high \u{e0b0}"
    );
}

#[test]
fn modules_flag_selects_and_orders_segments() {
    let out = run(
        include_str!("fixtures/full.json"),
        &cli(&["--modules", "cost,model", "--mode", "flat"]),
    )
    .unwrap();
    assert_eq!(strip_ansi(&out), " $0.71  \u{f16a6} opus 4.8 ");
}

#[test]
fn unknown_theme_is_a_readable_error() {
    let err = run(
        include_str!("fixtures/full.json"),
        &cli(&["--theme", "nope"]),
    )
    .unwrap_err();
    assert!(err.contains("unknown theme 'nope'"), "{err}");
}

#[test]
fn unknown_module_is_a_readable_error() {
    let err = run(
        include_str!("fixtures/full.json"),
        &cli(&["--modules", "bogus"]),
    )
    .unwrap_err();
    assert!(err.contains("unknown module 'bogus'"), "{err}");
}

#[test]
fn garbage_payload_is_an_error_not_a_panic() {
    assert!(run("not json", &cli(&[])).is_err());
}

#[test]
fn context_percent_is_exposed_for_the_progress_bar() {
    let payload =
        powerline_claude::payload::Payload::from_json(include_str!("fixtures/full.json")).unwrap();
    // 15500 / 200000
    assert_eq!(powerline_claude::context_percent(&payload), Some(7));
}

#[test]
fn width_prefers_flag_then_columns_env_then_default() {
    use powerline_claude::resolve_width;
    assert_eq!(resolve_width(Some(120), Some("80")), 120);
    assert_eq!(resolve_width(None, Some("80")), 80);
    assert_eq!(resolve_width(None, Some("not a number")), 200);
    assert_eq!(resolve_width(None, None), 200);
}
