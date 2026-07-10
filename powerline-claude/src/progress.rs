//! ConEmu OSC 9;4 terminal progress bar for context usage.
//!
//! Claude Code compacts the context around 80% usage, so the bar treats 80%
//! as "full". Colors follow the same thresholds the old script used: warning
//! in the 40% "dumb zone", error from 60%.

const COMPACT_PERCENT: u64 = 80;
const WARNING_PERCENT: u64 = 40;
const ERROR_PERCENT: u64 = 60;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ProgressState {
    Normal,
    Warning,
    Error,
}

impl ProgressState {
    fn osc_code(self) -> u8 {
        match self {
            ProgressState::Normal => 1,
            ProgressState::Warning => 4,
            ProgressState::Error => 2,
        }
    }
}

/// Map context usage (percent of the window) to a progress-bar state and
/// fill level (percent of the compact threshold, capped at 100).
pub fn progress(used_percent: u64) -> (ProgressState, u64) {
    let state = if used_percent >= ERROR_PERCENT {
        ProgressState::Error
    } else if used_percent >= WARNING_PERCENT {
        ProgressState::Warning
    } else {
        ProgressState::Normal
    };
    let fill = (used_percent * 100 / COMPACT_PERCENT).min(100);
    (state, fill)
}

pub fn osc_sequence(used_percent: u64) -> String {
    let (state, fill) = progress(used_percent);
    format!("\x1b]9;4;{};{}\x07", state.osc_code(), fill)
}
