import QtQuick 2.9
import QtMultimedia 5.9
import Bacon2D 1.0
import Seppuku 1.0
import "../singletons"

EntityBase {
    id: entity
    entityType: "sea"

    width: 40
    height: 40
    bodyType: Body.Static
    sleepingAllowed: false
    fixedRotation: false
    z: Utils.zLava
    sender: "sea"

    fixtures: [
        Box {
            friction: 0
            restitution: 0
            density: 0

            y: 24
            width: target.width
            height: target.height - y
            categories: Utils.kLava

            readonly property string sender: entity.sender

            onBeginContact: {
                if(other.categories & Utils.kHero) {
                    if(other.type === "main_body")
                        drownSound.play();
                }
            }
        },
        // Fish deepest level
        Box {
            sensor: true
            y: 36
            width: target.width
            height: 2
            categories: Utils.kLava

            readonly property string type: "fish_depth"
        }
    ]

    Rectangle {
        anchors {
            fill: parent
            topMargin: 24
        }
        color: "#3b9cfb"
    }

    Sprite {
        width: parent.width
        spriteSheet: SpriteSheet { source: Global.paths.images + "objectsets/winter.png" }
        frameX: 0
        frameY: 128
        frameWidth: 32
        frameHeight: 32
        fillMode: Image.TileHorizontally
    }

    SoundEffect {
        id: drownSound
        source: Global.paths.sounds + "drown.wav"
        muted: Global.settings.noSound
        volume: Global.settings.sfxVolume
    }
}
