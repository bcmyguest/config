//! Binary shim: stdin/stdout wiring around `powerline_claude::run`.

use std::io::{Read, Write};
use std::process::Command;

use clap::Parser;

use powerline_claude::cli::Cli;
use powerline_claude::payload::Payload;
use powerline_claude::{context_percent, progress, run};

fn main() {
    let mut cli = Cli::parse();

    let mut input = String::new();
    let _ = std::io::stdin().read_to_string(&mut input);

    // COLUMNS is set by Claude Code v2.1.153+; older versions need the
    // parent-TTY walk the bash script used.
    if cli.width.is_none() && std::env::var("COLUMNS").is_err() {
        cli.width = parent_tty_width();
    }

    match run(&input, &cli) {
        Ok(bar) => {
            print!("{bar}");
            let _ = std::io::stdout().flush();
        }
        Err(err) => print!("powerline-claude: {err}"),
    }

    if !cli.no_progress {
        emit_progress_bar(&input);
    }
}

/// Send the OSC 9;4 context progress bar straight to the terminal (stdout is
/// captured by Claude Code, /dev/tty is not).
fn emit_progress_bar(input: &str) {
    let Ok(payload) = Payload::from_json(input) else {
        return;
    };
    let Some(percent) = context_percent(&payload) else {
        return;
    };
    if let Ok(mut tty) = std::fs::OpenOptions::new().write(true).open("/dev/tty") {
        let _ = tty.write_all(progress::osc_sequence(percent).as_bytes());
    }
}

/// Width of the terminal the parent process is attached to. The statusline
/// subprocess has no TTY of its own, so ask `ps` for the parent's.
fn parent_tty_width() -> Option<usize> {
    let ppid = command_line(&["-o", "ppid=", "-p", &std::process::id().to_string()])?;
    let tty = command_line(&["-o", "tty=", "-p", &ppid])?;
    if tty.is_empty() || tty.starts_with('?') {
        return None;
    }
    let size = Command::new("stty")
        .args(["size", "-F", &format!("/dev/{tty}")])
        .output()
        .ok()?;
    let size = String::from_utf8(size.stdout).ok()?;
    size.split_whitespace().nth(1)?.parse().ok()
}

fn command_line(ps_args: &[&str]) -> Option<String> {
    let output = Command::new("ps").args(ps_args).output().ok()?;
    let line = String::from_utf8(output.stdout).ok()?;
    let line = line.trim();
    (!line.is_empty()).then(|| line.to_string())
}
