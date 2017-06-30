import QtQuick 2.9
import Bacon2D 1.0
import Seppuku 1.0
import "../singletons"

SceneBase {
    id: root

    signal timeout

    Rectangle {
        anchors.fill: parent
        color: "white"

        Image {
            id: splashImage
            anchors.centerIn: parent
            source: Global.paths.images + "misc/splash.png"
        }

        Text {
            anchors.horizontalCenter: splashImage.horizontalCenter
            anchors.top: splashImage.bottom
            anchors.topMargin: 6
            text: qsTr("...making life easier!")
            font.pixelSize: 12
            font.family: "Bookman Old Style"
            horizontalAlignment: Qt.AlignHCenter
            font.italic: true
        }
    }

    // startup timer
    Timer {
        id: startupTimer
        running: true
        repeat: false
        interval: 3000

        onTriggered: root.timeout();
    }
}
