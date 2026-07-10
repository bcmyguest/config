//! powerline-claude: a powerline-style status line for Claude Code.
//!
//! `run` is the whole program: statusline JSON in, ANSI bar out. The binary
//! in `main.rs` only wires stdin/stdout, terminal width, and the optional
//! progress-bar escape around it.

pub mod cli;
pub mod payload;
pub mod progress;
pub mod render;
pub mod segments;
pub mod theme;

use cli::Cli;
use payload::Payload;
use render::Segment;

const DEFAULT_WIDTH: usize = 200;

pub fn run(payload_json: &str, cli: &Cli) -> Result<String, String> {
    let payload = Payload::from_json(payload_json).map_err(|e| format!("bad payload: {e}"))?;
    let theme = theme::Theme::by_name(&cli.theme)?;
    let modules = segments::parse_modules(&cli.modules)?;
    let mode: render::Mode = cli.mode.parse()?;
    let width = resolve_width(cli.width, std::env::var("COLUMNS").ok().as_deref());

    let segments: Vec<Segment> = segments::segment_texts(&payload, &modules, width)
        .into_iter()
        .map(|(kind, text)| Segment {
            text,
            colors: theme.colors(kind),
        })
        .collect();
    Ok(render::render(&segments, mode))
}

/// Terminal width: explicit flag, then the COLUMNS variable Claude Code sets
/// (v2.1.153+), then a wide default so nothing truncates needlessly.
pub fn resolve_width(flag: Option<usize>, columns_env: Option<&str>) -> usize {
    flag.or_else(|| columns_env.and_then(|value| value.parse().ok()))
        .unwrap_or(DEFAULT_WIDTH)
}

/// Context usage as a percentage of the window, when the payload has both
/// numbers. Drives the OSC progress bar.
pub fn context_percent(payload: &Payload) -> Option<u64> {
    let tokens = payload.current_tokens()?;
    let size = payload.context_window_size()?;
    if size == 0 || tokens == 0 {
        return None;
    }
    Some(tokens * 100 / size)
}
