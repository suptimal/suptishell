//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic

// Adjust this to make the shell smaller or larger
//@ pragma Env QT_SCALE_FACTOR=1

// shell.qml
import qs.Bar
import qs.services

import Quickshell // for PanelWindow
import QtQuick // for Text
import Quickshell.Wayland

ShellRoot {
    Bar {}
    }