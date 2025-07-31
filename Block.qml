// Block.qml
import QtQuick
import QtQuick.Layouts
import qs.settings

Item {
    id: root
    required property string label
    property url iconSource: "" // optional

    // Let the layout determine height, set width based on content
    Layout.fillHeight: true
    implicitWidth: row.implicitWidth + 10

    Rectangle {
        anchors.fill: parent
        color: Config.surface
        z: -1
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 5

        // Only show icon if iconSource is set
        Image {
            visible: root.iconSource != ""
            source: root.iconSource
            fillMode: Image.PreserveAspectFit
            Layout.preferredWidth: text.font.pixelSize
            Layout.preferredHeight: text.font.pixelSize
        }

        Text {
            id: text
            text: root.label
            font.pixelSize: Config.fontSizeBody
            font.family: Config.fontFamily
            color: Config.textPrimary
            Layout.alignment: Qt.AlignVCenter
        }
    }
}
