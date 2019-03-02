import QtQuick 2.0
import Bacon2D 1.0
import "../singletons"

EntityBase {
    entityType: "boundaries"

    Chain {
        density: 1
        restitution: 0
        friction: 0
        categories: Utils.kGround
    }
}
