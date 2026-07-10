use std::fs;

use powerline_claude::payload::Payload;
use powerline_claude::segments::{
    Module, format_cost, format_duration, format_model, format_tokens, git_branch, parse_modules,
    truncate_dir,
};

// --- model ---

#[test]
fn model_gets_family_icon_and_lowercase_name() {
    assert_eq!(format_model("Opus 4.8"), "\u{f16a6} opus 4.8");
    assert_eq!(format_model("Sonnet 5"), "\u{f06a9} sonnet 5");
    assert_eq!(format_model("Haiku 4.5"), "\u{ee0d} haiku 4.5");
}

#[test]
fn unknown_model_family_falls_back_to_sonnet_icon() {
    assert_eq!(format_model("Fable 5"), "\u{f06a9} fable 5");
}

// --- context tokens ---

#[test]
fn tokens_render_with_thousands_separators() {
    assert_eq!(format_tokens(Some(15500)), "15,500 tok");
    assert_eq!(format_tokens(Some(1_234_567)), "1,234,567 tok");
    assert_eq!(format_tokens(Some(999)), "999 tok");
}

#[test]
fn missing_or_zero_tokens_render_placeholder() {
    assert_eq!(format_tokens(None), "~~ tok");
    assert_eq!(format_tokens(Some(0)), "~~ tok");
}

// --- cost ---

#[test]
fn cost_renders_as_dollars_with_two_decimals() {
    assert_eq!(format_cost(0.71234), "$0.71");
    assert_eq!(format_cost(0.0), "$0.00");
    assert_eq!(format_cost(12.999), "$13.00");
}

// --- duration ---

#[test]
fn duration_scales_units() {
    assert_eq!(format_duration(45_000), "45s");
    assert_eq!(format_duration(720_000), "12m");
    assert_eq!(format_duration(4_335_000), "1h 12m");
    assert_eq!(format_duration(90_061_000), "25h 1m");
}

// --- dir ---

#[test]
fn dir_shows_home_as_tilde() {
    assert_eq!(truncate_dir("/home/user", "/home/user", 200), "~");
}

#[test]
fn dir_keeps_last_two_components_with_ellipsis() {
    assert_eq!(
        truncate_dir(
            "/home/user/projects/backend/apps/emissions",
            "/home/user",
            200
        ),
        "apps/emissions"
    );
}

#[test]
fn short_paths_are_not_truncated() {
    assert_eq!(
        truncate_dir("/home/user/projects", "/home/user", 200),
        "~/projects"
    );
}

#[test]
fn narrow_terminals_keep_only_the_last_component() {
    assert_eq!(
        truncate_dir(
            "/home/user/projects/backend/apps/emissions",
            "/home/user",
            79
        ),
        "emissions"
    );
}

// --- git branch (no subprocess: reads .git/HEAD) ---

#[test]
fn branch_read_from_git_head_ref() {
    let repo = tempfile::tempdir().unwrap();
    fs::create_dir(repo.path().join(".git")).unwrap();
    fs::write(repo.path().join(".git/HEAD"), "ref: refs/heads/main\n").unwrap();
    assert_eq!(git_branch(repo.path()), Some("main".to_string()));
}

#[test]
fn branch_found_from_nested_subdirectory() {
    let repo = tempfile::tempdir().unwrap();
    fs::create_dir(repo.path().join(".git")).unwrap();
    fs::write(repo.path().join(".git/HEAD"), "ref: refs/heads/feat/x\n").unwrap();
    let nested = repo.path().join("a/b/c");
    fs::create_dir_all(&nested).unwrap();
    assert_eq!(git_branch(&nested), Some("feat/x".to_string()));
}

#[test]
fn detached_head_shows_short_hash() {
    let repo = tempfile::tempdir().unwrap();
    fs::create_dir(repo.path().join(".git")).unwrap();
    fs::write(
        repo.path().join(".git/HEAD"),
        "20ece3f7aabbccddeeff00112233445566778899\n",
    )
    .unwrap();
    assert_eq!(git_branch(repo.path()), Some("20ece3f7".to_string()));
}

#[test]
fn linked_worktree_gitfile_is_followed() {
    let main = tempfile::tempdir().unwrap();
    let gitdir = main.path().join("repo/.git/worktrees/wt");
    fs::create_dir_all(&gitdir).unwrap();
    fs::write(gitdir.join("HEAD"), "ref: refs/heads/wt-branch\n").unwrap();

    let worktree = tempfile::tempdir().unwrap();
    fs::write(
        worktree.path().join(".git"),
        format!("gitdir: {}\n", gitdir.display()),
    )
    .unwrap();
    assert_eq!(git_branch(worktree.path()), Some("wt-branch".to_string()));
}

#[test]
fn no_repository_means_no_branch() {
    let dir = tempfile::tempdir().unwrap();
    assert_eq!(git_branch(dir.path()), None);
}

// --- module list parsing ---

#[test]
fn parses_module_list_in_given_order() {
    let modules = parse_modules("cost,model").unwrap();
    assert_eq!(modules, vec![Module::Cost, Module::Model]);
}

#[test]
fn default_module_order_matches_todays_bar() {
    assert_eq!(
        Module::default_order(),
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
    );
}

#[test]
fn unknown_module_error_names_it_and_lists_valid_ones() {
    let err = parse_modules("logo,bogus").unwrap_err();
    assert!(err.contains("bogus"), "{err}");
    assert!(err.contains("context"), "{err}");
}

// --- composition: payload -> segment texts ---

#[test]
fn segments_skip_absent_data() {
    // minimal payload: no cost, no effort, dir exists but is no git repo
    let payload = Payload::from_json(include_str!("fixtures/minimal.json")).unwrap();
    let texts = powerline_claude::segments::segment_texts(&payload, &Module::default_order(), 200);
    let joined: Vec<&str> = texts.iter().map(|(_, t)| t.as_str()).collect();
    assert!(joined.iter().any(|t| t.contains("sonnet 5")), "{joined:?}");
    assert!(joined.iter().any(|t| t == &"~~ tok"), "{joined:?}");
    assert!(
        !joined.iter().any(|t| t.starts_with('$')),
        "cost must be skipped: {joined:?}"
    );
}
