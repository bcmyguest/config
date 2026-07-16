# No-UI kitten: focus split N of the active tab, where N is the split's
# CREATION order (1-based), not its position in kitty's window list. kitty's
# own nth_window numbers by list position, and the splits layout inserts new
# windows right after the active one (window_list.py add_window ->
# groups.insert(pos + 1)), so positional numbers shift when splits are
# opened. Creation order is stable: existing splits keep their number, new
# ones get the next free one. Numbers compact down when a split closes.
# window_title_bar.py displays the same numbering, so what you see is what
# alt+N jumps to.

from kittens.tui.handler import result_handler


def main(args):
    pass


@result_handler(no_ui=True)
def handle_result(args, answer, target_window_id, boss):
    try:
        n = int(args[1])
    except (IndexError, ValueError):
        return
    tab = boss.active_tab
    if tab is None:
        return
    groups = sorted(tab.windows.groups, key=lambda g: g.id)
    if not 1 <= n <= len(groups):
        return
    # Translate creation rank -> current list position, then reuse kitty's
    # own focusing logic (handles layout activation and border relayout).
    tab.nth_window(tab.windows.groups.index(groups[n - 1]))
