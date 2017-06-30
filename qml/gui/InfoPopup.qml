import QtQuick 2.9
import Bacon2D 1.0
import Seppuku 1.0
import "../singletons"

Popup {
    id: infoPopup
    objectName: "InfoPopup"

    property string text: ""

    content: InfoSlate {
        id: infoSlate
        anchors.centerIn: parent
        text: infoPopup.text

        Keys.onPressed: if (event.key === Qt.Key_Z) infoPopup.dismissed();

        SequentialAnimation {
            running: true

            PropertyAction { target: infoSlate; property: "scale"; value: .2 }
            PropertyAction { target: infoSlate; property: "opacity"; value: 0 }
            PauseAnimation { duration: 250 }
            ParallelAnimation {
                NumberAnimation { target: infoSlate; property: "scale"; to: 1; duration: 300; easing.type: Easing.InOutBack }
                NumberAnimation { target: infoSlate; property: "opacity"; to: 1; duration: 300; easing.type: Easing.InOutBack }
            }
        }
    }
}

