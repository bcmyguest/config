# Custom draw hook for kitty's per-split title bars (window_title_template's
# {custom} field). Returns "N:" where N is the split's 1-based CREATION order
# within the tab (window groups sorted by group id, which increments
# monotonically). Positional numbering (what kitty's nth_window uses) shifts
# when new splits are inserted mid-list; creation order keeps existing
# splits' numbers stable. pane_jump.py maps alt+N to the same numbering.
#
# Runs inside the kitty process; loaded from the kitty config dir.


def draw_window_title(data):
    try:
        from kitty.fast_data_types import get_boss
        tab = get_boss().tab_for_id(data.tab_id)
        if tab is None:
            return ''
        target = None
        for g in tab.windows.groups:
            if any(w.id == data.window_id for w in g):
                target = g
                break
        if target is not None:
            groups = sorted(tab.windows.groups, key=lambda g: g.id)
            return f'{groups.index(target) + 1}:'
    except Exception:
        pass
    return ''
