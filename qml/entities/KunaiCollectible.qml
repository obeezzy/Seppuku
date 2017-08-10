import QtQuick 2.9
import Bacon2D 1.0
import QtMultimedia 5.9
import Seppuku 1.0
import "../singletons"

EntityBase {
    id: kunaiCollectible
    width: 30
    height: 50
    bodyType: Body.Static
    sleepingAllowed: false
    transformOrigin: Item.Center
    z: Utils.zCollectible

    property bool picked: false

    EntityManager { id: entityManager; parentScene: kunaiCollectible.scene }

    fixtures: [
        Box {
            width: target.width
            height: target.height
            sensor: true
            categories: Utils.kCollectible
            collidesWith: Utils.kHero

            readonly property string type: "kunai"

            onBeginContact: {
                if(other.categories & Utils.kHero) {
                    if(other.type === "main_body") {
                        //console.log("Kunai: The hero wants to pick me up.")
                        kunaiCollectible.picked = true
                    }
                }
            }
        }
    ]

    AnimatedSprite {
        id: sprite
        animation: "default"
        source: Global.paths.images + "collectibles/kunai.png"

        animations: [
            SpriteAnimation {
                name: "default"
                frames: 1
                duration: 500
                loops: Animation.Infinite
            }
        ]
    }

    Behavior on opacity { NumberAnimation {duration: 350 } }
    Behavior on scale { NumberAnimation {duration: 250 } }

    SequentialAnimation {
        id: pickAnimation

        ScriptAction { script: pickupSound.play(); }
        ParallelAnimation {
            NumberAnimation { target: kunaiCollectible; property: "scale"; to: 2; duration: 250 }
            NumberAnimation { target: kunaiCollectible; property: "opacity"; to: 0; duration: 350 }
        }

        ScriptAction { script: entityManager.destroyEntity(kunaiCollectible.entityId); }
    }

    onPickedChanged: if (picked) pickAnimation.start();

    SoundEffect {
        id: pickupSound
        source: Global.paths.sounds+ "pickup.wav"
        volume: settings.sfxVolume
    }
}


