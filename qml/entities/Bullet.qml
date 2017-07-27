import QtQuick 2.9
import Bacon2D 1.0
import Seppuku 1.0
import "../singletons"

EntityBase {
    id: bulletEntity
    width: 6
    height: 6
    //bullet: true
    bodyType: Body.Kinematic

    readonly property string sender: "robot"

    EntityManager { id: entityManager; parentScene: bulletEntity.scene }

    fixtures: Circle {
        radius: 6
        density: .01
        friction: .01
        restitution: 0.2
        categories: Utils.kEnemy
        collidesWith: Utils.kActor | Utils.kGround

        readonly property string type: "bullet"
        readonly property real damage: .2
        readonly property string sender: bulletEntity.sender

        onBeginContact: {
            destructionOnContactTimer.start();
            destructionOTimeoutTimer.stop();
        }
    }

    Timer {
        id: destructionOnContactTimer
        repeat: false
        interval: 5

        onTriggered: entityManager.removeEntity(bullet.entityId);
    }

    Timer {
        id: destructionOTimeoutTimer
        repeat: false
        interval: 3000

        onTriggered: entityManager.removeEntity(entityId);
    }

    property bool facingLeft: false
    AnimatedSprite {
        id: sprite
        animation: "moving"
        horizontalMirror: facingLeft

        animations: [
            SpriteAnimation {
                name: "moving"
                source: Global.paths.images + "robot/bullet.png"
                frames: 5
                duration: 500
                loops: Animation.Infinite
            }
        ]
    }

    Component.onCompleted: destructionOTimeoutTimer.start();
}
