import QtQuick 2.9
import Bacon2D 1.0
import Seppuku 1.0
import "../singletons"

EntityBase {
    id: finishSign
    bodyType: Body.Static
    width: 60
    height: 60
    sleepingAllowed: false

    property bool checked: false
    signal levelComplete

    fixtures: Box {
        width: target.width
        height: target.height
        categories: Utils.kInteractive
        collidesWith: Utils.kHero
        sensor: true

        readonly property string type: "finish_sign"

        onBeginContact: {
            if(other.categories & Utils.kHero) {
                if(other.type === "main_body") {
                    checked = true
                    levelComplete()
                }
            }
        }

        onEndContact: {}
    }

    Sprite {
        anchors.fill: parent
        source: Global.paths.images + "objectsets/winter.png"
        frameX: 0
        frameY: 200
        frameWidth: 86
        frameHeight: 90

        Image {
            id: flagImage
            x: parent.width / 2 - width / 2
            y: 12
            width: 23
            height: width
            source: Global.paths.images + "misc/finish_flag_white.png"
            transformOrigin: Image.Center
            rotation: 180
            opacity: .4

            SequentialAnimation {
                running: finishSign.checked
                loops: 1

                ParallelAnimation {
                    PropertyAnimation { target: flagImage; property: "rotation"; to: 0; duration: 500; easing.type: Easing.OutBounce }

                    SequentialAnimation {
                        NumberAnimation { target: flagImage; property: "scale"; to: 3; duration: 250 }
                        NumberAnimation { target: flagImage; property: "scale"; to: 1; duration: 250 }
                    }

                    PropertyAnimation { target: flagImage; property: "opacity"; to: 1; duration: 500 }
                }
            }
        }
    }

    Rectangle {
       color: "transparent"
       border.color: "lime"
       border.width: 5
       width: parent.width
       height: width
       visible: finishSign.checked
       radius: width

       NumberAnimation on scale { running: finishSign.checked; from: .1; to: 4; duration: 1500 }
       NumberAnimation on opacity { running: finishSign.checked; from: 1; to: 0; duration: 1300 }
    }
}
