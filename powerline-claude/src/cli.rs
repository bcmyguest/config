//! Command-line interface, modeled on powerline-go: the statusLine command in
//! Claude Code's settings.json carries these flags.

use clap::Parser;

#[derive(Debug, Parser)]
#[command(
    name = "powerline-claude",
    about = "Powerline-style status line for Claude Code (reads statusline JSON on stdin)"
)]
pub struct Cli {
    /// Comma-separated segments to render, in order
    #[arg(long, default_value = "logo,dir,git,model,context,cost,stats,effort")]
    pub modules: String,

    /// Color theme
    #[arg(long, default_value = "catppuccin-mocha")]
    pub theme: String,

    /// Separator style: patched (nerd font), compatible (plain Unicode), flat
    #[arg(long, default_value = "patched")]
    pub mode: String,

    /// Disable the OSC 9;4 terminal progress bar
    #[arg(long)]
    pub no_progress: bool,

    /// Terminal width override (default: $COLUMNS, then the parent TTY)
    #[arg(long)]
    pub width: Option<usize>,
}
