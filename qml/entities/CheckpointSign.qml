import QtQuick 2.9
import Bacon2D 1.0
import Seppuku 1.0
import "../singletons"

EntityBase {
    id: checkpointSign
    bodyType: Body.Static
    width: 60
    height: 60
    sleepingAllowed: false

    readonly property Scene scene: parent
    readonly property Ninja actor: parent.actor

    QtObject {
        id: privateProperties

        property bool checked: false

        onCheckedChanged: {
            if(checked) {
                //Seppuku.saveState()
            }
        }
    }

    fixtures: Box {
        width: target.width
        height: target.height
        categories: Global.kInteractive
        collidesWith: Global.kActor
        sensor: true

        readonly property string type: "checkpoint"

        onBeginContact: {
            switch(other.categories) {
            case Global.kActor:
                if(other.type === "main_body") {
                    privateProperties.checked = true;
                    console.log("Global checkpoint state? ", Global.checkpointState);
                    //Global.checkpointState.level = 3;
                    Global.checkpointState.pos = Qt.point(actor.x, actor.y);s
                }
                break
            }
        }

        onEndContact: {
            switch(other.categories) {
            case Global.kActor:
                if(other.type === "main_body") {
                }
                break;
            }
        }
    }

    Image {
        anchors.fill: parent
        source: Global.paths.images + "objects/winter_sign.png"

        Image {
            id: likeImage
            x: parent.width / 2 - width / 2
            y: 12
            width: 23
            height: width
            source: Global.paths.images + "misc/like_white.png"
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
           from: .1; to: 4; duration: 1500
       }

       NumberAnimation on opacity {
           running: privateProperties.checked && !Global.gameWindow.paused
           from: 1; to: 0; duration: 1300
       }
    }
}
