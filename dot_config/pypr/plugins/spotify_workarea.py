"""Fit dropdown apps before Pyprland's show animation, using logical monitor units."""

from pyprland.plugins.interface import Plugin
from pyprland.plugins.scratchpads.transitions import TransitionsMixin


def geometry(monitor):
    width = int(monitor["width"] / monitor["scale"])
    height = int(monitor["height"] / monitor["scale"])
    if monitor.get("transform", 0) % 2:
        width, height = height, width
    # Hyprland's reserved edges are already in logical coordinates.
    left, top, right, bottom = monitor.get("reserved", [0, 0, 0, 0])
    available_width = width - left - right
    # Retain the existing 98% width; use the whole available height.
    inset = max(2, round(available_width * 0.01))
    border = 2
    return (left + inset, top + border,
            max(1, available_width - 2 * inset),
            max(1, height - top - bottom - 2 * border))


class Extension(Plugin):
    async def init(self):
        self.original = TransitionsMixin._show_transition
        original = self.original

        async def show(owner, scratch, monitor, was_alive):
            if scratch.uid in {"spotify", "ferdium", "teams"}:
                x, y, width, height = geometry(monitor)
                # Explicit px values are logical units and are not scaled twice.
                scratch.conf["size"] = f"{width}px {height}px"
                scratch.conf["position"] = f"{x}px {y}px"
                scratch.conf["preserve_aspect"] = False
            await original(owner, scratch, monitor, was_alive)

        self.wrapper = show
        TransitionsMixin._show_transition = show

    async def exit(self):
        if TransitionsMixin._show_transition is self.wrapper:
            TransitionsMixin._show_transition = self.original
