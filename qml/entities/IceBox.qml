import QtQuick 2.9
import Bacon2D 1.0
import Seppuku 1.0
import "../singletons"

EntityBase {
    id: iceBox
    entityType: "iceBox"

    property real density: .8
    property real restitution: .5
    property bool platform: false
    property var warningSign: null

    signal selfDestruct

    EntityManager { id: entityManager; parentScene: iceBox.scene }

    bodyType: Body.Dynamic
    width: 60
    height: 60
    sleepingAllowed: true
    sender: "ice_box"

    fixtures: Box {
        width: target.width
        height: target.height
        friction: 1
        density: iceBox.density
        restitution: iceBox.restitution
        categories: {
            if(iceBox.platform)
                Utils.kGround | Utils.kObstacle | Utils.kGroundTop
            else
                Utils.kObstacle
        }
        collidesWith: Utils.kGround | Utils.kHero | Utils.kObstacle |
                      Utils.kEnemy | Utils.kLava

        readonly property string type: "ice_box"
        readonly property real damage: .5
        readonly property string sender: iceBox.sender

        onBeginContact: {
            switch(other.categories) {
            case Utils.kLava:
                entityManager.destroyEntity(iceBox.entityId);
                break;
            }
        }
    }

    Sprite {
        spriteSheet: SpriteSheet { source: Global.paths.images + "objectsets/winter.png" }
        anchors.fill: parent
        frameX: 200
        frameY: 0
        frameWidth: 100
        frameHeight: 100
    }

    Component.onDestruction: iceBox.selfDestruct();
}
