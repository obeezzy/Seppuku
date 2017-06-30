import QtQuick 2.9
import Bacon2D 1.0
import Seppuku 1.0
import "../singletons"

EntityBase {
    id: crystal
    bodyType: Body.Static
    sleepingAllowed: false
    width: 60
    height: 60

    property int imageRotation: 0
    readonly property string sender: "crystal"

    fixtures: Polygon {
        friction: 1
        density: 1
        categories: Global.kObstacle

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
            switch(imageRotation) {
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

    Image {
        anchors.fill: parent
        source: Global.paths.images + "objects/crystal.png"
        rotation: imageRotation
        transformOrigin: Item.Center
    }
}
