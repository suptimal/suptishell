// Block.qml
import QtQuick
import QtQuick.Layouts
import qs.settings

Item {
    id: root
    property string label: ""
    property var labelColor: null
    property url iconSource: "" // optional

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
            visible: root.iconSource != ""
            source: root.iconSource
            fillMode: Image.PreserveAspectFit
            Layout.preferredWidth: Config.fontSizeBody
            Layout.preferredHeight: Config.fontSizeBody
        }

        Text {
            id: text
            visible: root.label != ""
            text: root.label
            font.pixelSize: Config.fontSizeBody
            font.family: Config.fontFamily
            color: root.labelColor ?? Config.textPrimary
            Layout.alignment: Qt.AlignVCenter
        }
    }
}
