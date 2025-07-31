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
    
ScriptModel {
    id: workspaceModel
    objectProp: "id"
    values: {
        const defaultIds = [1, 2, 3, 4, 5];
        const focusedId = Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 1;
        let ids = [...defaultIds];

        if (!ids.includes(focusedId)) {
            ids.push(focusedId);
        }

        return ids.map(id => {
            const ws = Hyprland.workspaces.values.find(w => w.id === id);
            const appCount = ws?.toplevels?.values?.reduce((acc, tl) => {
                const appId = tl?.wayland?.appId ?? "unknown";
                acc[appId] = (acc[appId] || 0) + 1;
                return acc;
            }, {}) || {};

            if (ws) {
                return {
                    id: ws.id,
                    name: ws.name,
                    toplevels: ws.toplevels,
                    appCount: appCount
                };
            }
            return {
                id: id,
                toplevels: [],
                appCount: {}
            };
        });
    }
}


    Repeater {
        model: workspaceModel

        delegate: Item {
            id: wsBlockWrapper
            Layout.preferredWidth: wsBlockList.width + 10
            Layout.fillHeight: true
            required property var modelData
            property var workspace: modelData
            
            RowLayout {
                id: wsBlockList
                anchors.centerIn: parent
                RowLayout {
                    id: wsBlock
                    Text {
                        id: wstext
                        Layout.alignment: Qt.AlignVCenter
                        text: wsBlockWrapper.workspace.id
                        font.pixelSize: Config.fontSizeBody
                        font.family: Config.fontFamily
                        color: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === wsBlockWrapper.workspace.id ? Config.onAccent : Config.textPrimary
                    }
                    Repeater {
                        model: Object.keys(wsBlockWrapper.workspace.appCount || {})
                        delegate: Item {
                            id: iconroot
                            required property string modelData
                            property string className: modelData
                            property int classCount: wsBlockWrapper.workspace.appCount[className]
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
                color: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === wsBlockWrapper.workspace.id ? Config.accentPrimary : Config.surface
                z: -1
            }

            MouseArea {

                anchors.fill: wsBlockWrapper

                acceptedButtons: Qt.LeftButton
                hoverEnabled: true

                onClicked: event => {
                    if (event.button == Qt.LeftButton) {
                        console.log(wsBlockWrapper.workspace.id)
                        Hyprland.dispatch("workspace " + wsBlockWrapper.workspace.id)
                    }
                }
            }

        }

    }
}