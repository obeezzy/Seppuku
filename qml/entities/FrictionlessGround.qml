import QtQuick 2.12
import Bacon2D 1.0
import "../singletons"

EntityBase {
    entityType: "frictionlessGround"

    fixtures: Box {
        density: 1
        restitution: 0
        friction: 0.3
        categories: Utils.kGround | Utils.kGroundTop
    }
}
