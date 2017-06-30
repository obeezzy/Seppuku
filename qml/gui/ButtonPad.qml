import QtQuick 2.9
import Seppuku 1.0
import "../singletons"

Item {
    width: 210
    height: 210
    opacity: .5

    signal jumpTriggered
    signal slideTriggered
    signal throwTriggered
    signal attackTriggered
    signal toggleDisguiseTriggered

    Rectangle {
        x: parent.width - width
        y: 24
        color: area1.pressed ? "green" : Qt.darker("green")
        scale: area1.pressed ? 1.2 : 1
        width: 72
        height: width
        radius: width

        Behavior on scale { NumberAnimation { duration: 50 } }

        MouseArea {
            id: area1
            anchors.fill: parent

            onClicked: throwTriggered();
        }
    }

    Rectangle {
        x: 24
        y: 48
        color: area2.pressed ? "blue" : Qt.darker("blue")
        scale: area2.pressed ? 1.2 : 1
        width: 72
        height: width
        radius: width

        Behavior on scale { NumberAnimation { duration: 50 } }


        MouseArea {
            id: area2
            anchors.fill: parent
            onClicked: attackTriggered();
            onDoubleClicked: {
                toggleDisguiseTriggered();
                mouse.accepted = true;
            }
        }
    }

    Rectangle {
        x: 60
        y: parent.height - height
        color: area3.pressed ? "red" : Qt.darker("red")
        scale: area3.pressed ? 1.2 : 1
        width: 72
        height: width
        radius: width

        Behavior on scale { NumberAnimation { duration: 50 } }


        MouseArea {
            id: area3
            anchors.fill: parent

            onClicked: jumpTriggered();
            onPressAndHold: slideTriggered();
        }
    }
}

