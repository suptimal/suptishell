pragma ComponentBehavior: Bound
// WorkspaceList.qml
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import QtQuick.Layouts
import qs.services
import qs.settings

RowLayout {
    id: root
    spacing: 6
    Layout.fillHeight: true

    Repeater {
        model: HyprlandData.normalWorkspaceIds

        delegate: Item {
            id: wsBlockWrapper
            Layout.preferredWidth: wsBlockList.width + 10
            Layout.fillHeight: true
            required property int modelData
            property string wsID: modelData
            
            RowLayout {
                id: wsBlockList
                anchors.centerIn: parent
                RowLayout {
                    id: wsBlock
                    Text {
                        id: wstext
                        text: wsBlockWrapper.wsID
                        font.pixelSize: Config.fontSizeBody
                        font.family: Config.fontFamily
                        color: wsBlockWrapper.wsID == HyprlandData.activeWorkspace.id ? Config.onAccent : Config.textPrimary

                        Layout.alignment: Qt.AlignVCenter
                    }
                    Repeater {
                        model: Object.keys(HyprlandData.windowClassListByWsId[wsBlockWrapper.wsID] || {})
                        delegate: Item {
                            id: iconroot
                            required property string modelData
                            property string className: modelData
                            property int classCount: HyprlandData.windowClassListByWsId[wsBlockWrapper.wsID][iconroot.className]
                            width: Config.barHeight * 0.85
                            height: Config.barHeight * 0.85

                            IconImage {
                                anchors.fill: parent
                                source: AppSearch.guessIcon(iconroot.className)
                            }

                            Text {
                                visible: iconroot.classCount > 1
                                id: caption
                                text: iconroot.classCount
                                font.pixelSize: Config.fontSizeCaption
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                z: +1
                            }
                            Rectangle {
                                visible: iconroot.classCount > 1
                                color: Qt.alpha(Config.highlight, 0.7)
                                anchors.centerIn: caption
                                width: caption.width + 4
                                height: caption.height
                                radius: width/3
                            }
                        }
                    }
                }
            }
            Rectangle {
                anchors.fill: wsBlockWrapper
                color: wsBlockWrapper.wsID == HyprlandData.activeWorkspace.id ? Config.accentPrimary : Config.surface
                z: -1
            }

            MouseArea {

                anchors.fill: wsBlockWrapper

                acceptedButtons: Qt.LeftButton
                hoverEnabled: true

                onClicked: event => {
                    if (event.button == Qt.LeftButton) {
                        console.log(wsBlockWrapper.wsID)
                        Hyprland.dispatch("workspace " + wsBlockWrapper.wsID)
                    }
                }
            }

        }

    }
}