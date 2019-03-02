import QtQuick 2.12
import Bacon2D 1.0
import "../singletons"

EntityBase {
    id: groundTop
    entityType: "groundTop"

    fixtures: [
        Box {
            height: groundTop.TiledObjectGroup.instance.getProperty(groundTop.entityId, "height") * .1
            density: 1
            restitution: 0
            friction: 1
            categories: Utils.kGround | Utils.kGroundTop
        },

        Box {
            y: groundTop.TiledObjectGroup.instance.getProperty(groundTop.entityId, "height") * .1
            height: groundTop.TiledObjectGroup.instance.getProperty(groundTop.entityId, "height")* .9
            density: 1
            restitution: 0
            friction: 1
            categories: Utils.kGround
        }
    ]
}
