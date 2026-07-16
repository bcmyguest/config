# Custom draw hook for kitty's per-split title bars (window_title_template's
# {custom} field). Returns "N:" where N is the split's 1-based position in
# the tab — the same numbering nth_window uses (see kitty/tabs.py nth_window
# -> activate_nth_window, which indexes window groups), so the number shown
# is exactly what alt+N jumps to.
#
# Runs inside the kitty process; loaded from the kitty config dir.


def draw_window_title(data):
    try:
        from kitty.fast_data_types import get_boss
        tab = get_boss().tab_for_id(data.tab_id)
        if tab is not None:
            for num, w in tab.windows.iter_windows_with_number(only_visible=False):
                if w.id == data.window_id:
                    return f'{num + 1}:'
    except Exception:
        pass
    return ''
