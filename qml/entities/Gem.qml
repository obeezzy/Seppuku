import QtQuick 2.9
import Bacon2D 1.0
import QtMultimedia 5.9
import Seppuku 1.0
import "../singletons"

EntityBase {
    id: gem
    width: 40
    height: 40
    bodyType: Body.Static
    sleepingAllowed: false
    transformOrigin: Item.Center
    z: Utils.zCollectible

    property string color: "blue"
    property bool picked: false

    signal selfDestruct

    EntityManager { id: entityManager; parentScene: gem.scene }

    fixtures: Box {
        width: target.width
        height: target.height
        sensor: true
        categories: Utils.kCollectible
        collidesWith: Utils.kHero

        readonly property bool picked: gem.picked
        readonly property string type: "gem"
        readonly property string color: gem.color

        onBeginContact: {
            if(other.categories & Utils.kHero) {
                if(other.type === "main_body")
                    gem.picked = true
            }
        }
    }

    Image {
        id: image
        anchors.fill: parent
        source: Global.paths.images + "items/gem_yellow.png"
    }

    function changeKey() {
        switch(gem.color) {
        case "red":
            return Global.paths.images + "items/gem_red.png"
        case "green":
            return Global.paths.images + "items/gem_green.png"
        case "yellow":
            return Global.paths.images + "items/gem_yellow.png"
        default:
            return Global.paths.images + "items/gem_blue.png"
        }
    }

    SequentialAnimation {
        id: pickAnimation

        ParallelAnimation {
            NumberAnimation { target: gem; property: "scale"; to: 2; duration: 250 }
            NumberAnimation { target: gem; property: "opacity"; to: 0; duration: 350 }
        }

        ScriptAction { script: entityManager.removeEntity(gem.entityId); }
    }

    onPickedChanged: if (picked) pickAnimation.start();

    SoundEffect {
        id: pickupSound
        source: Global.paths.sounds + "pickup.wav"
        volume: settings.sfxVolume
    }

    onColorChanged: image.source = changeKey();
}

