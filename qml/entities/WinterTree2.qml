import QtQuick 2.9
import Bacon2D 1.0
import Seppuku 1.0
import "../singletons"

Entity {
    entityType: "winterTree2"
    width: 60
    height: 60

    Image {
        source: Global.paths.images + "objects/tree_2.png"
    }
}
