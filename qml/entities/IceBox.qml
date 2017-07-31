import QtQuick 2.9
import Bacon2D 1.0
import Seppuku 1.0
import "../singletons"

EntityBase {
    id: iceBox
    bodyType: Body.Dynamic
    width: 60
    height: 60
    bullet: true
    sleepingAllowed: true
    sender: "ice_box"
    entityType: "IceBox"

    EntityManager { id: entityManager; parentScene: iceBox.scene }

    property real density: .8
    property real restitution: .5
    property bool platform: false
    property var warningSign: null

    signal selfDestruct

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
                entityManager.removeEntity(iceBox.entityId);
                break;
            }
        }
    }

    Image {
        source: Global.paths.images + "objects/ice_box.png"
        anchors.fill: parent
    }

    Component.onDestruction: iceBox.selfDestruct();
}
