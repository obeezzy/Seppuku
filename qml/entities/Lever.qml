import QtQuick 2.9
import Bacon2D 1.0
import Seppuku 1.0
import "../singletons"

EntityBase {
    id: lever
    width: 55
    height: 55
    sleepingAllowed: false
    bodyType: Body.Static
    z: Utils.zInteractive

    readonly property string type: "lever"
    readonly property string fileLocation: Global.paths.images + "switches/"
    readonly property string fileName: "switch_" + position + ".png"

    property string position: "left"
    property bool inRange: false
    property bool centerIgnored: true

    signal newPosition(string position)

    fixtures: Box {
        width: target.width
        height: target.height
        sensor: true
        categories: Utils.kInteractive

        readonly property string type: lever.type

        onBeginContact: {
            if(other.categories & Utils.kHero)
                lever.inRange = true;
        }

        onEndContact: {
            if(other.categories & Utils.kHero)
                lever.inRange = false;
        }
    }

    Rectangle {
        id: indicator
       color: "transparent"
       border.color: "skyblue"
       border.width: 3
       width: parent.width
       height: width
       visible: lever.inRange ? true : false
       radius: width

       SequentialAnimation on scale {
           loops: Animation.Infinite
           running: lever.inRange && !gameWindow.paused ? true : false
           NumberAnimation { from: .1; to: 2; duration: 250 }
           NumberAnimation { from: 2; to: .1; duration: 250 }
       }
    }

    Image {
        anchors.fill: parent
        source: fileName
    }

    Connections {
        target: hero
        onUtilized: {
            if(type == lever.type && lever.inRange) {
                console.log("The lever got the signal.")
                switch(position) {
                case "left":
                    position = centerIgnored ? "mid" : "right";
                    break;
                case "mid":
                    position = "right";
                    break;
                case "right":
                    position = "left";
                    break;
                }

                lever.positionChanged(position);
            }
        }
    }
}

