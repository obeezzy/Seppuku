import QtQuick 2.9
import Bacon2D 1.0
import QtMultimedia 5.9
import Seppuku 1.0
import "../singletons"

EntityBase {
    id: key
    entityType: "key"

    property string color: "blue"

    EntityManager { id: entityManager }

    QtObject {
        id: privateProperties

        property bool picked: false
        onPickedChanged: if(picked) pickAnimation.start();
    }

    width: 40
    height: 40
    bodyType: Body.Static
    sleepingAllowed: false
    transformOrigin: Item.Center
    z: Utils.zCollectible

    fixtures: Box {
        width: target.width
        height: target.height
        sensor: true
        categories: Utils.kCollectible
        collidesWith: Utils.kHero

        readonly property bool picked: privateProperties.picked
        readonly property string type: "key"
        readonly property string color: key.color

        onBeginContact: {
            if(other.categories & Utils.kHero) {
                if(other.type === "main_body")
                    privateProperties.picked = true;
            }
        }
    }

    Image {
        id: image
        anchors.fill: parent
        source: {
            switch(key.color) {
            case "red":
                Global.paths.images + "collectibles/key_red.png"
                break;
            case "green":
                Global.paths.images + "collectibles/key_green.png"
                break;
            case "yellow":
                Global.paths.images + "collectibles/key_yellow.png"
                break;
            default:
                return Global.paths.images + "collectibles/key_blue.png"
            }
        }
    }

    SequentialAnimation {
        id: pickAnimation
        ParallelAnimation {
            NumberAnimation { target: key; property: "scale"; to: 2; duration: 250 }
            NumberAnimation { target: key; property: "opacity"; to: 0; duration: 350 }
        }

        ScriptAction {
            script: {
                pickupSound.play();
                console.log("Key: Picked ", hero.totalRedKeysCollected);
                entityManager.destroyEntity(key.entityId);
            }
        }
    }

    SoundEffect {
        id: pickupSound
        source: Global.paths.sounds + "pickup.wav"
        volume: Global.settings.sfxVolume
    }
}

