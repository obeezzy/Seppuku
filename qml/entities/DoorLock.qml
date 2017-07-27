import QtQuick 2.9
import Bacon2D 1.0
import Seppuku 1.0
import "../singletons"

EntityBase {
    id: doorLock
    width: 40
    height: 40
    bodyType: Body.Static
    sleepingAllowed: false
    transformOrigin: Item.Center
    entityType: "doorLock"

    property string color: "blue"
    property bool locked: true
    readonly property string type: "door_lock"
    readonly property string fileName: Global.paths.images + "doors/lock_" + color + ".png"

    signal lockOpened

    EntityManager { id: entityManager; parentScene: doorLock.scene }

    fixtures: Box {
        width: target.width
        height: target.height
        sensor: true
        categories: Utils.kInteractive

        readonly property string color: doorLock.color
        readonly property string type: doorLock.type

        onBeginContact: {
            if(other.categories & Utils.kActor && other.type === "main_body") {
                if(color == "blue" && actor.totalBlueKeysCollected > 0) {
                    locked = false;
                    actor.dropKey(color);
                    lockOpened();
                }
                else if(color == "green" && actor.totalGreenKeysCollected > 0) {
                    locked = false;
                    actor.dropKey(color);
                    lockOpened();
                }
                else if(color == "red" && actor.totalRedKeysCollected > 0) {
                    locked = false;
                    actor.dropKey(color);
                    lockOpened();
                }
                else if(color == "yellow" && actor.totalYellowKeysCollected > 0) {
                    locked = false;
                    actor.dropKey(color);
                    lockOpened();
                }
            }
        }
    }

    SequentialAnimation {
        running: !doorLock.locked

        ParallelAnimation {
            NumberAnimation { target: doorLock; property: "opacity"; to: 0; duration: 500 }
            NumberAnimation { target: doorLock; property: "scale"; to: 5; duration: 500 }
        }

        ScriptAction { script: { entityManager.removeEntity(doorLock.entityId); } }
    }

    Image {
        anchors.fill: parent
        source: doorLock.fileName
    }
}

