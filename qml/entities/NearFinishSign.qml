import QtQuick 2.9
import Bacon2D 1.0
import Seppuku 1.0
import "../singletons"

Entity {
    entityType: "nearFinishSign"
    width: 60
    height: 60

    Image {
        anchors.fill: parent
        source: Global.paths.images + "objects/winter_pointer_sign.png"

        Image {
            id: flagImage
            x: parent.width / 2 - width / 2
            y: 12
            width: 23
            height: width
            source: Global.paths.images + "misc/finish_flag_white.png"
            transformOrigin: Image.Center
        }
    }
}
