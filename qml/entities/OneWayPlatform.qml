import QtQuick 2.9
import Bacon2D 1.0
import "../singletons"

EntityBase {
    id: oneWayPlatform
    bodyType: Body.Static
    sleepingAllowed: false

    fixtures: Box {
        density: 1
        restitution: 0
        friction: 1
        categories: Utils.kGround
    }
}
