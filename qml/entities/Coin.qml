import QtQuick 2.9
import Bacon2D 1.0
import QtMultimedia 5.9
import Seppuku 1.0
import "../singletons"

EntityBase {
    id: coin
    width: 20
    height: 20
    bodyType: Body.Static
    sleepingAllowed: false

    property bool picked: false

    fixtures: [
        Box {
            width: target.width
            height: target.height
            sensor: true
            categories: Utils.kCollectible
            collidesWith: Utils.kActor

            readonly property bool picked: coin.picked
            readonly property string type: "coin"

            onBeginContact: {
                switch(other.categories) {
                case Utils.kActor:
                    if(other.type === "main_body") {
                        //console.log("Coin: The actor wants to pick me up.")
                        coin.picked = true;
                    }
                    break;
                }
            }
        }
    ]

    AnimatedSprite {
        id: sprite
        animation: "default"

        animations: [
            SpriteAnimation {
                name: "default"
                source: Global.paths.images + "collectibles/coin.png"
                frames: 10
                duration: 500
                loops: Animation.Infinite
            }
        ]
    }

    SequentialAnimation {
        id: pickAnimation

        ParallelAnimation {
            NumberAnimation { target: coin; property: "scale"; to: 2; duration: 250 }
            NumberAnimation { target: coin; property: "opacity"; to: 0; duration: 350 }
        }

        ScriptAction { script: coin.destroy(); }
    }

    onPickedChanged: if(picked) pickAnimation.start();

    SoundEffect {
        id: coinSound
        source: Global.paths.sounds + "coin.wav"
        volume: settings.sfxVolume
    }
}

