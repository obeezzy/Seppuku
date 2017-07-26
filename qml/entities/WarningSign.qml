import QtQuick 2.9
import Seppuku 1.0
import "../singletons"

Image {
    id: warningSign
    source: Global.paths.images + "signs/warning.png"

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

