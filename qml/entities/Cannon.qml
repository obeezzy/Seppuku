import QtQuick 2.9
import Bacon2D 1.0
import QtMultimedia 5.4
import Seppuku 1.0
import "../singletons"

EntityBase {
    id: cannon
    bodyType: Body.Static
    width: 148
    height: 57

    EntityManager { id: entityManager; parentScene: cannon.scene }

    fixtures: Box {
        id: cannonFixture
        width: cannon.width
        height: cannon.height
        density: .5
        categories: Utils.kGround | Utils.kGroundTop
    }

    readonly property Scene scene: parent
    property Sensor sensor: null
    property int bulletLifeSpan: 1000
    property bool mirror: false

    Component {
        id: ball
        PhysicsEntity {
            id: ballEntity
            width: 12
            height: 12
            bullet: true
            bodyType: Body.Dynamic
            z: Utils.zCannonBullet

            fixtures: Circle {
                radius: 6
                density: .9
                friction: .9
                restitution: .2

                categories: Utils.kEnemy
                collidesWith: Utils.kHero | Utils.kObstacle | Utils.kGround

                readonly property string type: "bullet"
            }
            Rectangle {
                anchors.centerIn: parent
                radius: 6
                width: 12
                height: 12
                color: "black"
                smooth: true
            }

            Timer {
                id: destructionTimer
                repeat: false
                interval: cannon.bulletLifeSpan

                onTriggered: entityManager.destroyEntity(cannon.entityId);
            }

            Component.onCompleted: destructionTimer.start();
        }
    }

    Image {
        id: image
        source: Global.paths.images + "machines/cannon.png"
        anchors.fill: parent
        mirror: cannon.mirror
    }

    function shoot() {
        var newBall = ball.createObject(scene);
        newBall.y = cannon.y + cannon.height / 2 - 12;

        var impulseX = newBall.getMass() * 500;

        if(image.mirror) {
            newBall.x = cannon.x - 6;
            newBall.applyLinearImpulse(Qt.point(-impulseX, 0), newBall.getWorldCenter());
        }
        else {
            newBall.x = cannon.x + cannon.width + 6;
            newBall.applyLinearImpulse(Qt.point(impulseX, 0), newBall.getWorldCenter());
        }

        //shotSound.play()
    }

    onSensorChanged: {
        createLink();
    }

    function createLink() {
        if(sensor == null)
            return;

        sensor.triggered.connect(shoot);
    }

//    SoundEffect {
//        id: shotSound
//        source: Global.paths.sounds + "cannon.wav"
//        muted: settings.noSound
//        volume: .1
//    }
}
