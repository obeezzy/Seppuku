import QtQuick 2.0
import Bacon2D 1.0
import "../singletons"

EntityBase {
    entityType: "slopeGround"

    fixtures: Polygon {
        density: 1
        restitution: 0
        friction: .01
        categories: Utils.kGround
    }
}
