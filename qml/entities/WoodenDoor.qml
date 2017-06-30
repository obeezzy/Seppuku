import QtQuick 2.9
import Bacon2D 1.0
import Seppuku 1.0
import "../singletons"

PhysicsEntity {
    id: woodenDoort
    width: 70
    height: 140
    bodyType: Body.Static
    sleepingAllowed: false

    property bool closed: true
    readonly property string type: "wooden_door"

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
                actor.nextDoorLocation = Qt.point(nextDoor.x + nextDoor.width / 2,
                                                  nextDoor.y + nextDoor.height - actor.height);
            }
            else if(!privateProperties.inRange) {
                actor.nextDoorLocation = Qt.point(-1, -1);
            }
        }
    }

    fixtures: Box {
        width: target.width
        height: target.height
        sensor: true
        categories: Global.kInteractive

        readonly property string type: woodenDoort.type

        onBeginContact: {
            if(other.categories & Global.kActor && other.type === "main_body") {
                actor.inDoorRange = true;

                if(!closed)
                    privateProperties.inRange = true;
            }
        }

        onEndContact: {
            if(other.categories & Global.kActor && other.type === "main_body") {
                actor.inDoorRange = false
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
            source: woodenDoort.closed ? (Global.paths.images + "doors/door_closedTop.png") : (Global.paths.images + "doors/door_openTop.png")
            height: 70
        }

        Image {
            id: doorBody
            anchors.left: parent.left
            anchors.right: parent.right
            height: woodenDoort.height - doorTop.height
            source: woodenDoort.closed ? (Global.paths.images + "doors/door_closedMid.png") : (Global.paths.images + "doors/door_openMid.png")
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
            woodenDoort.closed = false;
        });
    }
}

