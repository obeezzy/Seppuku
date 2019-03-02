import QtQuick 2.9
import Bacon2D 1.0
import Seppuku 1.0
import "../singletons"

EntityBase {
    id: crystal
    entityType: "crystal"

    property int spriteRotation: 0
    readonly property string sender: "crystal"

    bodyType: Body.Static
    sleepingAllowed: false
    width: 60
    height: 60

    fixtures: Polygon {
        friction: 1
        density: 1
        categories: Utils.kObstacle

        readonly property string type: "crystal"
        readonly property real damage: .2
        readonly property string sender: "crystal"

        vertices: [
            Qt.point(0, target.height / 2),
            Qt.point(0, target.height),
            Qt.point(target.width, target.height),
            Qt.point(target.width, target.height / 2),
            Qt.point(target.width / 2, 0)
        ]

        Component.onCompleted: {
            switch(spriteRotation) {
            case 90:
                break;
            case 180:
                vertices = [
                            Qt.point(0, 0),
                            Qt.point(0, target.height / 2),
                            Qt.point(target.width / 2, target.height),
                            Qt.point(target.width, target.height / 2),
                            Qt.point(target.width, 0)
                        ];
                break;
            case 270:
                break;
            }
        }
    }

    Sprite {
        anchors.fill: parent
        spriteSheet: SpriteSheet { source: Global.paths.images + "objectsets/winter.png" }
        rotation: spriteRotation
        transformOrigin: Item.Center
        frameX: 104
        frameY: 0
        frameWidth: 90
        frameHeight: 90
    }
}
