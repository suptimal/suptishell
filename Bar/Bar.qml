import Quickshell
import QtQuick
import QtQuick.Layouts
import qs
import qs.services
import qs.settings
import Quickshell.Services.UPower
import Quickshell.Services.Pipewire

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
            PwObjectTracker {
                objects: [ Pipewire.defaultAudioSink ]
            }

            property var audio: Pipewire.defaultAudioSink.audio
            iconSource: Quickshell.iconPath('audio-symbolic')
            label: audio.muted ? "M" : Math.round(audio.volume * 100)+"%"
            labelColor: audio.muted ? Config.error : Config.textPrimary
        }
        Block {
            iconSource: Quickshell.iconPath(NetworkManager.networkSymbol)
            label: NetworkManager.networkConnectivity == "full" ? "up" : "DOWN"
        }
        Block {
            property var bat0: UPower.devices.values.find(e => e.isLaptopBattery)

            function formatTime(seconds) {
                let hours = Math.floor(seconds / 3600);
                let minutes = Math.floor((seconds % 3600) / 60);
                return hours > 0 ? hours + "h " + minutes + "m" : minutes + "m";
            }

            visible: bat0 != null

            label: Math.round(bat0.percentage * 100) + "%" + (bat0.state === UPowerDeviceState.Charging && bat0.percentage < 0.97 ? " (" + formatTime(bat0.timeToFull) + ")" : "")
            iconSource: Quickshell.iconPath(bat0.iconName)

            labelColor: {
                if (bat0.state != UPowerDeviceState.Discharging)
                    return Config.textPrimary;
                if (bat0.percentage < 0.2)
                    return Config.error;
                if (bat0.percentage < 0.4)
                    return Config.warning;
                return Config.textPrimary;
            }
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
