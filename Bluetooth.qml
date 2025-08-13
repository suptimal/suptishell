pragma ComponentBehavior: Bound
// Bluetooth.qml
import QtQuick
import QtQuick.Layouts
import qs.settings
import Quickshell.Bluetooth
import Quickshell
import QtQuick.Controls

Item {
    id: root
    // Let the layout determine height, set width based on content
    Layout.fillHeight: true
    implicitWidth: row.implicitWidth + 6

    Rectangle {
        anchors.fill: parent
        color: Config.surface
        z: -1
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 2

        // Only show icon if iconSource is set
        Image {
            source: Quickshell.iconPath("bluetooth-active-symbolic")
            fillMode: Image.PreserveAspectFit
            Layout.preferredWidth: Config.fontSizeBody
            Layout.preferredHeight: Config.fontSizeBody
        }

        Text {
            id: text
            text: Bluetooth.devices.values.filter(function(d) { return d.connected; }).length
            font.pixelSize: Config.fontSizeBody
            font.family: Config.fontFamily
            color: root.labelColor ?? Config.textPrimary
            Layout.alignment: Qt.AlignVCenter
        }
        
    }
    MouseArea {
        anchors.fill: row
        onClicked: deviceMenu.visible = !deviceMenu.visible
    }

    PopupWindow {
        id: deviceMenu
        anchor.item: root    
        anchor.gravity: Edges.Top
        implicitHeight: layout.height + layout.spacing * 2
        implicitWidth: layout.width + layout.spacing * 2
        visible: false
        color: Config.backgroundPrimary
        ColumnLayout {
            id: layout
            spacing: 8
            anchors.centerIn: parent
            Repeater {
                model: Bluetooth.devices.values

                    Rectangle {
                        id: devitem
                        required property BluetoothDevice modelData
                        implicitHeight: devrow.height
                        implicitWidth: devrow.width

                        RowLayout {
                            id: devrow
                            spacing: 2
                            Layout.fillWidth: true
                            
                            // Only show icon if iconSource is set
                            Image {
                                source: Quickshell.iconPath(devitem.modelData.connected ? "bluetooth-active-symbolic" : "bluetooth-symbolic")
                                fillMode: Image.PreserveAspectFit
                                Layout.preferredWidth: Config.fontSizeBody
                                Layout.preferredHeight: Config.fontSizeBody
                            }

                            Text {
                                text: devitem.modelData.name
                                font.pixelSize: Config.fontSizeBody
                                font.family: Config.fontFamily
                                color: Config.textPrimary
                                Layout.alignment: Qt.AlignVCenter
                            }
                        }
                        MouseArea {
                            anchors.fill: devrow
                            onClicked: {
                                if (devitem.modelData.connected) {
                                    devitem.modelData.disconnect()
                                } else {
                                    devitem.modelData.connect()
                                }
                                deviceMenu.visible = false
                            }
                        }
                    }

            }
        }
    }

}
