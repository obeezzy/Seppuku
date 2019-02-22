import QtQuick 2.9
import Bacon2D 1.0
import Seppuku 1.0
import "../singletons"

EntityBase {
    id: leverSwitch
    width: 55
    height: 55
    sleepingAllowed: false
    bodyType: Body.Static
    z: Utils.zInteractive
    entityType: "lever_switch"

    readonly property string type: "lever"

    property string position: "left"
    property bool inRange: false
    property bool hasCenterPosition: false
    property int motionLink: 0

    signal newPosition(string position)

    fixtures: Box {
        width: target.width
        height: target.height
        sensor: true
        categories: Utils.kInteractive

        readonly property string type: leverSwitch.type

        onBeginContact: {
            if(other.categories & Utils.kHero)
                leverSwitch.inRange = true;
        }

        onEndContact: {
            if(other.categories & Utils.kHero)
                leverSwitch.inRange = false;
        }
    }

    Rectangle {
        id: indicator
       color: "transparent"
       border.color: "skyblue"
       border.width: 3
       width: parent.width
       height: width
       visible: leverSwitch.inRange ? true : false
       radius: width

       SequentialAnimation on scale {
           loops: Animation.Infinite
           running: leverSwitch.inRange && !Global.gameWindow.paused ? true : false
           NumberAnimation { from: .1; to: 2; duration: 250 }
           NumberAnimation { from: 2; to: .1; duration: 250 }
       }
    }

    Loader {
        anchors.fill: parent
        sourceComponent: {
            switch (leverSwitch.position) {
            case "left":
                switchLeft
                break;
            case "mid":
                switchMid
                break;
            case "right":
                switchRight
                break;
            }
        }

        Component {
            id: switchLeft
            Sprite {
                spriteSheet: SpriteSheet { source: Global.paths.images + "objectsets/common.png" }
                frameX: 0; frameY: 340; frameWidth: 70; frameHeight: 70
            }
        }

        Component {
            id: switchMid
            Sprite {
                spriteSheet: SpriteSheet { source: Global.paths.images + "objectsets/common.png" }
                frameX: 70; frameY: 340; frameWidth: 70; frameHeight: 70
            }
        }

        Component {
            id: switchRight
            Sprite {
                spriteSheet: SpriteSheet { source: Global.paths.images + "objectsets/common.png" }
                frameX: 140; frameY: 340; frameWidth: 70; frameHeight: 70
            }
        }
    }

    Connections {
        target: hero
        onUtilized: {
            if(type == leverSwitch.type && leverSwitch.inRange) {
                console.log("The leverSwitch got the signal.")
                switch(position) {
                case "left":
                    position = leverSwitch.hasCenterPosition ? "mid" : "right";
                    break;
                case "mid":
                    position = "right";
                    break;
                case "right":
                    position = "left";
                    break;
                }

                leverSwitch.newPosition(position);
            }
        }
    }
}

