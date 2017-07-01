import QtQuick 2.9
import Bacon2D 1.0
import "../singletons"

SceneBase {
    id: root

    Image {
        id: background
        source: Global.paths.images + "misc/seppuku.jpg"
        anchors.fill: parent
    }

    Rectangle {
        anchors.fill: parent
        color: "#8057007f"

        Text {
            id: titleText
            anchors.centerIn: parent
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            width: contentWidth
            height: contentHeight

            text: qsTr("loading... ")
            color: "white"

            font.family: Stylesheet.defaultFontFamily
            font.pixelSize: 67

            style: Text.Outline
            styleColor: "#57007f"
        }
    }
}

