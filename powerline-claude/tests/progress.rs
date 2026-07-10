use powerline_claude::progress::{ProgressState, osc_sequence, progress};

#[test]
fn low_usage_is_normal_state() {
    assert_eq!(progress(0), (ProgressState::Normal, 0));
    assert_eq!(progress(39), (ProgressState::Normal, 48)); // 39*100/80
}

#[test]
fn warning_from_forty_percent() {
    assert_eq!(progress(40).0, ProgressState::Warning);
    assert_eq!(progress(59).0, ProgressState::Warning);
}

#[test]
fn error_from_sixty_percent() {
    assert_eq!(progress(60).0, ProgressState::Error);
    assert_eq!(progress(95).0, ProgressState::Error);
}

#[test]
fn bar_scales_to_compact_threshold_and_caps_at_full() {
    // Claude compacts at 80% context, so 80% usage = a full bar
    assert_eq!(progress(40).1, 50);
    assert_eq!(progress(80).1, 100);
    assert_eq!(progress(99).1, 100);
}

#[test]
fn sequence_is_conemu_osc_9_4() {
    assert_eq!(osc_sequence(30), "\x1b]9;4;1;37\x07");
    assert_eq!(osc_sequence(50), "\x1b]9;4;4;62\x07");
    assert_eq!(osc_sequence(70), "\x1b]9;4;2;87\x07");
}
