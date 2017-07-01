import QtQuick 2.9
import Bacon2D 1.0
import Seppuku 1.0
import "../singletons"

EntityBase {
    id: ladder
    bodyType: Body.Static
    width: 36
    height: 60

    fixtures: Box {
        //x: -6
        width: target.width //+ 12
        height: target.height
        sensor: true
        categories: Utils.kLadder
    }

    Image {
        id: image
        width: ladder.width
        height: ladder.height
        source: Global.paths.images + "objects/ladder.png"
        fillMode: Image.TileVertically
    }
}
