#!/usr/bin/env python3
"""
Screen Corners - Abgerundete Bildschirmecken für Wayland (Niri, Sway, etc.)
Verwendet GTK3 Layer Shell um schwarze Ecken-Overlays zu rendern.
"""

import gi
import cairo
import signal
import sys

gi.require_version('Gtk', '3.0')
gi.require_version('Gdk', '3.0')
gi.require_version('GtkLayerShell', '0.1')

from gi.repository import Gtk, Gdk, GtkLayerShell

# Konfiguration
CORNER_RADIUS = 26
CORNER_COLOR = (0, 0, 0, 1)  # Schwarz, volle Deckkraft


class CornerWindow(Gtk.Window):
    """Ein einzelnes Ecken-Overlay-Fenster."""

    def __init__(self, corner: str, monitor: Gdk.Monitor):
        super().__init__()

        self.corner = corner
        self.radius = CORNER_RADIUS

        # GTK Layer Shell initialisieren
        GtkLayerShell.init_for_window(self)
        GtkLayerShell.set_monitor(self, monitor)
        GtkLayerShell.set_layer(self, GtkLayerShell.Layer.OVERLAY)
        GtkLayerShell.set_exclusive_zone(self, -1)  # Keine exklusive Zone

        # Ecke positionieren
        if 'top' in corner:
            GtkLayerShell.set_anchor(self, GtkLayerShell.Edge.TOP, True)
        if 'bottom' in corner:
            GtkLayerShell.set_anchor(self, GtkLayerShell.Edge.BOTTOM, True)
        if 'left' in corner:
            GtkLayerShell.set_anchor(self, GtkLayerShell.Edge.LEFT, True)
        if 'right' in corner:
            GtkLayerShell.set_anchor(self, GtkLayerShell.Edge.RIGHT, True)

        # Fenstergröße
        self.set_size_request(self.radius, self.radius)

        # Transparenz aktivieren
        self.set_app_paintable(True)
        screen = self.get_screen()
        visual = screen.get_rgba_visual()
        if visual:
            self.set_visual(visual)

        # Keine Eingabe akzeptieren (Click-through)
        self.input_shape_combine_region(cairo.Region())

        # Drawing Area
        self.drawing_area = Gtk.DrawingArea()
        self.drawing_area.connect('draw', self.on_draw)
        self.add(self.drawing_area)

    def on_draw(self, widget, cr):
        """Zeichnet die abgerundete Ecke."""
        width = widget.get_allocated_width()
        height = widget.get_allocated_height()

        # Hintergrund löschen (transparent)
        cr.set_operator(cairo.OPERATOR_SOURCE)
        cr.set_source_rgba(0, 0, 0, 0)
        cr.paint()

        # Schwarzes Rechteck
        cr.set_source_rgba(*CORNER_COLOR)
        cr.rectangle(0, 0, width, height)
        cr.fill()

        # Transparenten Viertelkreis ausschneiden
        cr.set_operator(cairo.OPERATOR_CLEAR)

        # Kreismittelpunkt je nach Ecke
        if self.corner == 'top-left':
            cx, cy = self.radius, self.radius
        elif self.corner == 'top-right':
            cx, cy = 0, self.radius
        elif self.corner == 'bottom-left':
            cx, cy = self.radius, 0
        elif self.corner == 'bottom-right':
            cx, cy = 0, 0

        cr.arc(cx, cy, self.radius, 0, 2 * 3.14159)
        cr.fill()

        return False


class ScreenCorners:
    """Hauptanwendung für abgerundete Bildschirmecken."""

    def __init__(self):
        self.windows = []
        self.corners = ['top-left', 'top-right', 'bottom-left', 'bottom-right']

    def run(self):
        """Startet die Anwendung."""
        display = Gdk.Display.get_default()

        # Für jeden Monitor Ecken erstellen
        n_monitors = display.get_n_monitors()
        print(f"Gefunden: {n_monitors} Monitor(e)")

        for i in range(n_monitors):
            monitor = display.get_monitor(i)
            geometry = monitor.get_geometry()
            print(f"Monitor {i}: {geometry.width}x{geometry.height} @ {geometry.x},{geometry.y}")

            for corner in self.corners:
                window = CornerWindow(corner, monitor)
                window.show_all()
                self.windows.append(window)

        print(f"Screen Corners aktiv (Radius: {CORNER_RADIUS}px)")
        print("Drücke Ctrl+C zum Beenden")

        # Signal Handler für sauberes Beenden
        signal.signal(signal.SIGINT, lambda s, f: Gtk.main_quit())
        signal.signal(signal.SIGTERM, lambda s, f: Gtk.main_quit())

        Gtk.main()


if __name__ == '__main__':
    app = ScreenCorners()
    app.run()
