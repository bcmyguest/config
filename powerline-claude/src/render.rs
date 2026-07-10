//! Turns a list of colored segments into one ANSI powerline bar.

use std::fmt::Write;
use std::str::FromStr;

use crate::theme::{Rgb, SegmentColors};

const RESET: &str = "\x1b[0m";

/// Separator glyphs for one rendering mode. `hard` bridges two different
/// backgrounds, `thin` divides two segments sharing a background.
struct Separators {
    hard: &'static str,
    thin: &'static str,
    fade: &'static str,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Mode {
    /// Nerd-font powerline glyphs (private-use area).
    Patched,
    /// Standard Unicode stand-ins for terminals without patched fonts.
    Compatible,
    /// No separators at all.
    Flat,
}

impl Mode {
    fn separators(self) -> Option<Separators> {
        match self {
            Mode::Patched => Some(Separators {
                hard: "\u{e0b0}",
                thin: "\u{e0b1}",
                fade: "░▒▓",
            }),
            Mode::Compatible => Some(Separators {
                hard: "▶",
                thin: "❯",
                fade: "░▒▓",
            }),
            Mode::Flat => None,
        }
    }
}

impl FromStr for Mode {
    type Err = String;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "patched" => Ok(Mode::Patched),
            "compatible" => Ok(Mode::Compatible),
            "flat" => Ok(Mode::Flat),
            other => Err(format!(
                "unknown mode '{other}', available: patched, compatible, flat"
            )),
        }
    }
}

#[derive(Debug, Clone)]
pub struct Segment {
    pub text: String,
    pub colors: SegmentColors,
}

fn fg(color: Rgb) -> String {
    format!("\x1b[38;2;{};{};{}m", color.r, color.g, color.b)
}

fn bg(color: Rgb) -> String {
    format!("\x1b[48;2;{};{};{}m", color.r, color.g, color.b)
}

pub fn render(segments: &[Segment], mode: Mode) -> String {
    let Some(first) = segments.first() else {
        return String::new();
    };
    let separators = mode.separators();
    let mut out = String::new();

    if let Some(sep) = &separators {
        let _ = write!(out, "{}{}", fg(first.colors.bg), sep.fade);
    }

    for (i, segment) in segments.iter().enumerate() {
        if let (Some(sep), Some(previous)) = (&separators, i.checked_sub(1).map(|p| &segments[p])) {
            if previous.colors.bg == segment.colors.bg {
                let _ = write!(
                    out,
                    "{}{}{}",
                    bg(segment.colors.bg),
                    fg(segment.colors.fg),
                    sep.thin
                );
            } else {
                let _ = write!(
                    out,
                    "{}{}{}",
                    bg(segment.colors.bg),
                    fg(previous.colors.bg),
                    sep.hard
                );
            }
        }
        let _ = write!(
            out,
            "{}{} {} ",
            bg(segment.colors.bg),
            fg(segment.colors.fg),
            segment.text
        );
    }

    let last = segments.last().unwrap_or(first);
    match &separators {
        Some(sep) => {
            let _ = write!(out, "{RESET}{}{}{RESET}", fg(last.colors.bg), sep.hard);
        }
        None => out.push_str(RESET),
    }
    out
}
