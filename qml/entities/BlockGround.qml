import QtQuick 2.0
import Bacon2D 1.0
import "../singletons"

EntityBase {
    entityType: "blockGround"

    fixtures: Box {
        density: 1
        restitution: 0
        friction: 1
        categories: Utils.kGround
    }
}
