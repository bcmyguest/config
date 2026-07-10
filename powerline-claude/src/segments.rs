//! Segment content: what each module renders, given the payload.
//!
//! Everything here is pure string building except `git_branch`, which reads
//! `.git/HEAD` from disk (never a subprocess — the statusline runs on every
//! render and must stay cheap).

use std::fmt::Write;
use std::path::Path;
use std::str::FromStr;

use crate::payload::Payload;
use crate::theme::SegmentKind;

const LOGO: &str = "\u{f4f5}";
const HAIKU_ICON: char = '\u{ee0d}';
const SONNET_ICON: char = '\u{f06a9}';
const OPUS_ICON: char = '\u{f16a6}';
const BRANCH_ICON: char = '\u{e0a0}';

/// Terminals narrower than this get a more aggressive dir truncation.
const NARROW_COLUMNS: usize = 80;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Module {
    Logo,
    Dir,
    Git,
    Model,
    Context,
    Cost,
    Stats,
    Effort,
}

impl Module {
    pub fn default_order() -> Vec<Module> {
        vec![
            Module::Logo,
            Module::Dir,
            Module::Git,
            Module::Model,
            Module::Context,
            Module::Cost,
            Module::Stats,
            Module::Effort,
        ]
    }

    pub fn kind(self) -> SegmentKind {
        match self {
            Module::Logo => SegmentKind::Logo,
            Module::Dir => SegmentKind::Dir,
            Module::Git => SegmentKind::Git,
            Module::Model => SegmentKind::Model,
            Module::Context => SegmentKind::Context,
            Module::Cost => SegmentKind::Cost,
            Module::Stats => SegmentKind::Stats,
            Module::Effort => SegmentKind::Effort,
        }
    }

    const NAMES: &[(&str, Module)] = &[
        ("logo", Module::Logo),
        ("dir", Module::Dir),
        ("git", Module::Git),
        ("model", Module::Model),
        ("context", Module::Context),
        ("cost", Module::Cost),
        ("stats", Module::Stats),
        ("effort", Module::Effort),
    ];
}

impl FromStr for Module {
    type Err = String;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        Module::NAMES
            .iter()
            .find(|(name, _)| *name == s)
            .map(|(_, module)| *module)
            .ok_or_else(|| {
                let available: Vec<&str> = Module::NAMES.iter().map(|(n, _)| *n).collect();
                format!("unknown module '{s}', available: {}", available.join(", "))
            })
    }
}

pub fn parse_modules(list: &str) -> Result<Vec<Module>, String> {
    list.split(',')
        .map(str::trim)
        .filter(|name| !name.is_empty())
        .map(Module::from_str)
        .collect()
}

pub fn format_model(display_name: &str) -> String {
    let name = display_name.to_lowercase();
    let icon = if name.contains("haiku") {
        HAIKU_ICON
    } else if name.contains("opus") {
        OPUS_ICON
    } else {
        SONNET_ICON
    };
    format!("{icon} {name}")
}

pub fn format_tokens(tokens: Option<u64>) -> String {
    match tokens {
        Some(count) if count > 0 => format!("{} tok", group_thousands(count)),
        _ => "~~ tok".to_string(),
    }
}

fn group_thousands(value: u64) -> String {
    let digits = value.to_string();
    let mut out = String::with_capacity(digits.len() + digits.len() / 3);
    for (i, c) in digits.chars().enumerate() {
        if i > 0 && (digits.len() - i).is_multiple_of(3) {
            out.push(',');
        }
        out.push(c);
    }
    out
}

pub fn format_cost(usd: f64) -> String {
    format!("${usd:.2}")
}

pub fn format_duration(ms: u64) -> String {
    let total_seconds = ms / 1000;
    let hours = total_seconds / 3600;
    let minutes = (total_seconds % 3600) / 60;
    if hours > 0 {
        format!("{hours}h {minutes}m")
    } else if minutes > 0 {
        format!("{minutes}m")
    } else {
        format!("{total_seconds}s")
    }
}

/// Shorten a path for display: home becomes `~`, and anything deeper keeps
/// only the last two components (one on narrow terminals), starship-style.
pub fn truncate_dir(path: &str, home: &str, columns: usize) -> String {
    let display = match path.strip_prefix(home) {
        Some("") => return "~".to_string(),
        Some(rest) => format!("~{rest}"),
        None => path.to_string(),
    };
    let keep = if columns < NARROW_COLUMNS { 1 } else { 2 };
    let components: Vec<&str> = display.split('/').filter(|c| !c.is_empty()).collect();
    if components.len() <= keep || (display.starts_with('~') && components.len() <= keep + 1) {
        return display;
    }
    components[components.len() - keep..].join("/")
}

/// Current branch, read straight from `.git/HEAD`, walking up from `dir` and
/// following worktree gitfiles. Detached HEAD yields the short hash.
pub fn git_branch(dir: &Path) -> Option<String> {
    let mut current = Some(dir);
    while let Some(candidate) = current {
        let dotgit = candidate.join(".git");
        if dotgit.is_dir() {
            return branch_from_head(&dotgit.join("HEAD"));
        }
        if dotgit.is_file() {
            let contents = std::fs::read_to_string(&dotgit).ok()?;
            let gitdir = contents.strip_prefix("gitdir:")?.trim();
            return branch_from_head(&candidate.join(gitdir).join("HEAD"));
        }
        current = candidate.parent();
    }
    None
}

fn branch_from_head(head_path: &Path) -> Option<String> {
    let head = std::fs::read_to_string(head_path).ok()?;
    let head = head.trim();
    match head.strip_prefix("ref: refs/heads/") {
        Some(branch) => Some(branch.to_string()),
        None => Some(head.chars().take(8).collect()),
    }
}

/// Build the text for every requested module, skipping modules whose data is
/// absent from the payload. Returns `(kind, text)` pairs ready for theming.
pub fn segment_texts(
    payload: &Payload,
    modules: &[Module],
    columns: usize,
) -> Vec<(SegmentKind, String)> {
    let home = std::env::var("HOME").unwrap_or_default();
    modules
        .iter()
        .filter_map(|module| {
            let text = match module {
                Module::Logo => Some(LOGO.to_string()),
                Module::Dir => payload.dir().map(|dir| truncate_dir(dir, &home, columns)),
                Module::Git => git_segment(payload),
                Module::Model => payload.model_display_name().map(format_model),
                Module::Context => Some(format_tokens(payload.current_tokens())),
                Module::Cost => payload.total_cost_usd().map(format_cost),
                Module::Stats => payload.total_duration_ms().map(format_duration),
                Module::Effort => payload.effort_level().map(str::to_string),
            };
            text.map(|text| (module.kind(), text))
        })
        .collect()
}

/// Branch plus the session's line churn: ` main +156 -23`. Lines come from
/// the payload (what Claude changed), not from a git diff.
fn git_segment(payload: &Payload) -> Option<String> {
    let branch = git_branch(Path::new(payload.dir()?))?;
    let mut text = format!("{BRANCH_ICON} {branch}");
    if let (Some(added), Some(removed)) = (payload.lines_added(), payload.lines_removed()) {
        let _ = write!(text, " +{added} -{removed}");
    }
    Some(text)
}
