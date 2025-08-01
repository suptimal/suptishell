import Quickshell
import QtQuick
import QtQuick.Layouts 
import qs
import qs.services
import qs.settings

PanelWindow {
    screen: Quickshell.screens.length > 0 ? Quickshell.screens[0] : null

    anchors {
        left: true
        right: true
        bottom: true
    }
    implicitHeight: Config.barHeight
    color: Qt.alpha(Config.backgroundPrimary, 0.98) //fix for 1pixel on top error

    RowLayout {
        spacing: 5
        anchors.fill: parent
        Layout.fillHeight: true
        HyprlandWorkspaceList {}

        // spacer to create left and right side
        Item {
            Layout.fillWidth: true
        }

        Block {
            iconSource: Quickshell.iconPath(NetworkManager.networkSymbol)
            label: NetworkManager.networkConnectivity == "full" ? "up" : "DOWN"
        }
        Block {
            label: Qt.formatDateTime(clock.date, "hh:mm")
            SystemClock {
                id: clock
                precision: SystemClock.Minutes
            }
        }
    }

}
