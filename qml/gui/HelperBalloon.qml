import QtQuick 2.9
import "../singletons"

Item {
    id: helperBalloon

    property alias text: text.text

    implicitWidth: text.contentWidth + 20
    implicitHeight: text.contentHeight + 10

    Rectangle {
        id: background
        anchors.fill: parent
        color: "#80a9a9a9"
        radius: parent.height / 2
    }

//    Rectangle {
//        id: justTheTip
//        rotation: 45
//        color: background.color
//        width: 6
//        height: 6
//        anchors {
//            horizontalCenter: parent.horizontalCenter
//            bottom: parent.bottom
//            bottomMargin: -height / 2
//        }
//    }

    Text {
        id: text
        anchors.centerIn: parent
        text: qsTr("Helper balloon")
        color: "white"
        font {
            family: Stylesheet.casualFontFamily
            pixelSize: 10
        }
    }
}
