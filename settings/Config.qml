pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root

    property int barHeight: 30

    // Backgrounds
    property color backgroundPrimary: "#0C0D11"
    property color backgroundSecondary: "#151720"
    property color backgroundTertiary: "#1D202B"

    // Surfaces & Elevation
    property color surface: "#1A1C26"
    property color surfaceVariant: "#2A2D3A"

    // Text Colors
    property color textPrimary: "#CACEE2"
    property color textSecondary: "#B7BBD0"
    property color textDisabled: "#6B718A"

    // Accent Colors
    property color accentPrimary: "#A8AEFF"
    property color accentSecondary: "#9EA0FF"
    property color accentTertiary: "#8EABFF"

    // Error/Warning
    property color error: "#FF6B81"
    property color warning: "#FFBB66"

    // Highlights & Focus
    property color highlight: "#E3C2FF"
    property color rippleEffect: "#F3DEFF"

    // Additional Theme Properties
    property color onAccent: "#1A1A1A"
    property color outline: "#44485A"

    // Shadows & Overlays
    property color shadow: Qt.alpha("#000000", 0.7)
    property color overlay: Qt.alpha("#11121A", 0.4)

    // Font Properties
    property string fontFamily: "Roboto"         // Family for all text
    
    // Font size multiplier
    property real fontSizeMultiplier: 1
    
    // Base font sizes (multiplied by fontSizeMultiplier)
    property int fontSizeHeader: Math.round(32 * fontSizeMultiplier)     // Headers and titles
    property int fontSizeBody: Math.round(20 * fontSizeMultiplier)       // Body text and general content
    property int fontSizeSmall: Math.round(16 * fontSizeMultiplier)      // Small text like clock, labels
    property int fontSizeCaption: Math.round(12 * fontSizeMultiplier)    // Captions and fine print
}