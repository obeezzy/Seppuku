import QtQuick 2.12
import Bacon2D 1.0
import Seppuku 1.0
import "../singletons"

EntityBase {
    id: checkpointSign
    entityType: "checkpointSign"

    readonly property bool checked: Global.checkpointAvailable && Global.checkpoint.pos === Qt.point(x, y)

    bodyType: Body.Static
    width: 60
    height: 60
    sleepingAllowed: false

    QtObject {
        id: privateProperties

        property bool checked: false
    }

    fixtures: Box {
        width: target.width
        height: target.height
        categories: Utils.kInteractive
        collidesWith: Utils.kHero
        sensor: true

        readonly property string type: "checkpoint"

        onBeginContact: {
            switch(other.categories) {
            case Utils.kHero:
                if(other.type === "main_body") {
                    privateProperties.checked = true;
                    Global.checkpoint = {
                        "level": Global.currentLevel,
                        "pos": Qt.point(checkpointSign.x, checkpointSign.y),
                        "face_forward": hero.faceForward
                    };
                }
                break;
            }
        }

        onEndContact: {
            switch(other.categories) {
            case Utils.kHero:
                if(other.type === "main_body") {
                }
                break;
            }
        }
    }

    Sprite {
        anchors.fill: parent
        spriteSheet: SpriteSheet { source: Global.paths.images + "objectsets/winter.png" }
        frameX: 0
        frameY: 200
        frameWidth: 86
        frameHeight: 90

        Sprite {
            id: likeImage
            x: parent.width / 2 - width / 2
            y: 12
            width: 23
            height: width
            spriteSheet: SpriteSheet { source: Global.paths.images + "objectsets/symbols.png" }
            frameX: 80; frameY: 0; frameWidth: 50; frameHeight: 50

            transformOrigin: Image.Center
            rotation: 180
            opacity: .4

            SequentialAnimation {
                running: privateProperties.checked
                loops: 1

                ParallelAnimation {
                    PropertyAnimation { target: likeImage; property: "rotation"; to: 0; duration: 500; easing.type: Easing.OutBounce }

                    SequentialAnimation {
                        NumberAnimation { target: likeImage; property: "scale"; to: 3; duration: 250 }
                        NumberAnimation { target: likeImage; property: "scale"; to: 1; duration: 250 }
                    }

                    PropertyAnimation { target: likeImage; property: "opacity"; to: 1; duration: 500 }
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
       visible: privateProperties.checked
       radius: width

       NumberAnimation on scale {
           running: privateProperties.checked && !Global.gameWindow.paused
           from: .1; to: 4; duration: 1500; easing.type: Easing.OutCubic
       }

       NumberAnimation on opacity {
           running: privateProperties.checked && !Global.gameWindow.paused
           from: 1; to: 0; duration: 1300; easing.type: Easing.OutCubic
       }
    }
}
