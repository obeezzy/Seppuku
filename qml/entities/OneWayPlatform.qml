import QtQuick 2.12
import Bacon2D 1.0
import "../singletons"

EntityBase {
    id: oneWayPlatform
    entityType: "oneWayPlatform"
    bodyType: Body.Static
    sleepingAllowed: false

    fixtures: Polygon {
        readonly property string type: "one_way_platform"

        density: 1
        restitution: 0
        friction: 1
        categories: Utils.kGround | Utils.kGroundTop
    }
}
