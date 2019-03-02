import QtQuick 2.9
import Bacon2D 1.0
import Seppuku 1.0
import "../singletons"

EntityBase {
    id: woodenDoor
    entityType: "woodenDoor"

    property bool closed: true

    // Does this door have a lock?
    property DoorLock lock: null

    // what door is this door leading to?
    property variant nextDoor: null

    QtObject {
        id: privateProperties

        // You must control this variable manually. If you don't, every instance of this class would respond
        // to changes and that is DEFINITELY unwanted behavior.
        property bool inRange: false

        onInRangeChanged: {
            if(privateProperties.inRange && nextDoor != null) {
                hero.nextDoorLocation = Qt.point(nextDoor.x + nextDoor.width / 2,
                                                  nextDoor.y + nextDoor.height - hero.height);
            }
            else if(!privateProperties.inRange) {
                hero.nextDoorLocation = Qt.point(-1, -1);
            }
        }
    }

    width: 70
    height: 140
    bodyType: Body.Static
    sleepingAllowed: false
    type: "wooden_door"

    fixtures: Box {
        width: target.width
        height: target.height
        sensor: true
        categories: Utils.kInteractive

        readonly property string type: woodenDoor.type

        onBeginContact: {
            if(other.categories & Utils.kHero && other.type === "main_body") {
                hero.inDoorRange = true;

                if(!closed)
                    privateProperties.inRange = true;
            }
        }

        onEndContact: {
            if(other.categories & Utils.kHero && other.type === "main_body") {
                hero.inDoorRange = false
                privateProperties.inRange = false;
            }
        }
    }

    Column {
        anchors.left: parent.left
        anchors.right: parent.right

        Image {
            id: doorTop
            anchors.left: parent.left
            anchors.right: parent.right
            source: woodenDoor.closed ? (Global.paths.images + "doors/door_closedTop.png") : (Global.paths.images + "doors/door_openTop.png")
            height: 70
        }

        Image {
            id: doorBody
            anchors.left: parent.left
            anchors.right: parent.right
            height: woodenDoor.height - doorTop.height
            source: woodenDoor.closed ? (Global.paths.images + "doors/door_closedMid.png") : (Global.paths.images + "doors/door_openMid.png")
            fillMode: Image.TileVertically
        }
    }

    Rectangle {
       color: "transparent"
       border.color: "skyblue"
       border.width: 3
       width: height
       height: parent.height
       visible: privateProperties.inRange
       radius: width
       transformOrigin: Item.Center

       SequentialAnimation on scale {
           loops: Animation.Infinite
           running: privateProperties.inRange && !Global.gameWindow.paused
           NumberAnimation { from: .1; to: 2; duration: 250 }
           NumberAnimation { from: 2; to: .1; duration: 250 }
       }
    }

    onLockChanged: {
        if(lock == null || lock == undefined)
            return;

        lock.lockOpened.connect(function() {
            woodenDoor.closed = false;
        });
    }
}

