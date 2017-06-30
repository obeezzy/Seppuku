import QtQuick 2.9
import Seppuku 1.0
import "../singletons"

FocusScope {
    id: plainNarrowSlate
    implicitWidth: 200
    implicitHeight: 200

    property Component content: null

    Image {
        source: Global.paths.images + "menus/plain_small_slate.png"
        width: 288
        anchors.centerIn: parent
        fillMode: Image.PreserveAspectFit
        smooth: true

        Loader {
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                topMargin: 60
                leftMargin: 40
                rightMargin: 50
            }
            sourceComponent: plainNarrowSlate.content
            onLoaded: item.forceActiveFocus();
        }
    }
}
