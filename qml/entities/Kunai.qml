import QtQuick 2.9
import Bacon2D 1.0
import QtMultimedia 5.9
import Seppuku 1.0
import "../singletons"

EntityBase {
    id: kunai
    width: image.width
    height: image.height
    bodyType: Body.Kinematic
    sleepingAllowed: false
    fixedRotation: false
    type: "kunai"

    fixtures: [
        Box {
            //y: (target.height / 2)
            width: target.width
            height: target.height
            density: .01
            friction: .3
            restitution: .4
            categories: Utils.kActor
            collidesWith: Utils.kGround | Utils.kWall | Utils.kEnemy | Utils.kObstacle | Utils.kInteractive

//            vertices: [
//                Qt.point(0, target.height / 2),
//                Qt.point(0, target.height),
//                Qt.point(target.width, target.height),
//                Qt.point(target.width, target.height / 2),
//                Qt.point(target.width / 2, 0)
//            ]

            readonly property string type: kunai.type
            readonly property real damage: .2

            onBeginContact: {
                if((other.categories & Utils.kGround & Utils.kGroundTop & Utils.kEnemy) && other.type === "main_body")
                {
                    kunai.bodyType = Body.Dynamic;
                    kunai.linearVelocity = Qt.point(0, 0);
                    //collidesWith = Utils.kGround | Utils.kWall;
                    destructionOnContactAnimation.start();
                    destructionOnTimeoutAnimation.stop();
                }

                else if((other.categories & Utils.kInteractive)/* && other.type === "lever" && actor.facingRight && other.mirror*/)
                {
                    console.log("Hey there man!!!");
                    kunai.bodyType = Body.Dynamic;
                    kunai.linearVelocity = Qt.point(0, 0);
                    actor.utilized("lever");
                    destructionOnContactAnimation.start();
                    destructionOnTimeoutAnimation.stop();
                }
            }
        }
    ]

    Image {
        id: image
        source: Global.paths.images + "projectiles/kunai.png"
    }

    SequentialAnimation {
        id: destructionOnTimeoutAnimation
        running: true

        PauseAnimation { duration: 5000 }
        ScriptAction { script: kunai.destroy(); }
    }

    SequentialAnimation {
        id: destructionOnContactAnimation

        PauseAnimation { duration: 100 }
        NumberAnimation { target: kunai; property: "opacity"; to: 0; duration: 250 }
        ScriptAction { script: kunai.destroy(); }
    }

    onYChanged: {
        if(y > scene.height)
            destroy();
    }
}


