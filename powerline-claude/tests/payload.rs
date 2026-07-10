use powerline_claude::payload::Payload;

fn full() -> Payload {
    Payload::from_json(include_str!("fixtures/full.json")).unwrap()
}

fn minimal() -> Payload {
    Payload::from_json(include_str!("fixtures/minimal.json")).unwrap()
}

#[test]
fn parses_model_from_full_payload() {
    let p = full();
    assert_eq!(p.model_display_name(), Some("Opus 4.8"));
}

#[test]
fn parses_effort_level_when_present() {
    assert_eq!(full().effort_level(), Some("high"));
}

#[test]
fn effort_level_is_none_when_absent() {
    assert_eq!(minimal().effort_level(), None);
}

#[test]
fn workspace_current_dir_wins_over_cwd() {
    assert_eq!(
        full().dir(),
        Some("/home/user/projects/backend/apps/emissions")
    );
}

#[test]
fn current_tokens_sums_current_usage() {
    // 8500 input + 5000 cache creation + 2000 cache read (output excluded)
    assert_eq!(full().current_tokens(), Some(15500));
}

#[test]
fn current_tokens_falls_back_to_total_input_when_usage_null() {
    // minimal.json has current_usage: null, total_input_tokens: 0
    assert_eq!(minimal().current_tokens(), Some(0));
}

#[test]
fn parses_cost_and_stats_fields() {
    let p = full();
    assert_eq!(p.total_cost_usd(), Some(0.71234));
    assert_eq!(p.total_duration_ms(), Some(4335000));
    assert_eq!(p.lines_added(), Some(156));
    assert_eq!(p.lines_removed(), Some(23));
}

#[test]
fn cost_fields_are_none_when_cost_absent() {
    let p = minimal();
    assert_eq!(p.total_cost_usd(), None);
    assert_eq!(p.lines_added(), None);
}

#[test]
fn parses_context_window_size() {
    assert_eq!(full().context_window_size(), Some(200000));
}

#[test]
fn empty_object_parses_with_all_none() {
    let p = Payload::from_json("{}").unwrap();
    assert_eq!(p.model_display_name(), None);
    assert_eq!(p.dir(), None);
    assert_eq!(p.current_tokens(), None);
}

#[test]
fn invalid_json_is_an_error() {
    assert!(Payload::from_json("not json").is_err());
}
