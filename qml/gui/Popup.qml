import QtQuick 2.9
import Bacon2D 1.0
import Seppuku 1.0
import "../singletons"

FocusScope {
    id: popup

    property Component content: null
    signal dismissed

    MouseArea { anchors.fill: parent }

    Rectangle {
        id: background
        anchors.fill: parent
        color: "#80000000"

        SequentialAnimation {
            running: true
            PropertyAction { target: contentLoader; property: "scale"; value: 0 }
            NumberAnimation { target: background; property: "opacity"; from: 0; to: 1; duration: 200 }
            PropertyAction { target: contentLoader; property: "active"; value: true }
            NumberAnimation { target: contentLoader; property: "scale"; to: 1; duration: 200; easing.type: Easing.OutBack }
            PropertyAction { target: contentLoader.item; property: "focus"; value: true }
        }
    }

    Loader {
        id: contentLoader
        anchors.fill: parent
        active: false
        sourceComponent: popup.content
        onLoaded: item.forceActiveFocus();
    }

    Keys.onPressed: event.accepted = true;
}

