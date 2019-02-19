import QtQuick 2.9
import Bacon2D 1.0
import Seppuku 1.0
import "../singletons"

Sprite {
    id: warningSign
    width: 38
    height: 30
    spriteSheet: SpriteSheet { source: Global.paths.images + "objectsets/symbols.png" }
    frameX: 150; frameY: 0; frameWidth: 38; frameHeight: 30

    Behavior on rotation { enabled: !anim.running; PropertyAnimation { duration: 100 } }

    SequentialAnimation on rotation {
        id: anim
        running: true
        loops: 8

        PropertyAnimation {
            from: -45
            to: 45
            duration: 50
        }

        PropertyAnimation {
            from: 45
            to: -45
            duration: 50
        }

        PropertyAction { value: 0 }
    }
}

