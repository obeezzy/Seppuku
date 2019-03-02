import QtQuick 2.10
import Bacon2D 1.0
import QtMultimedia 5.4
import "../../js/Robot.js" as Ai
import "../gui"
import "../singletons"
import "../common"

EntityBase {
    id: robot
    entityType: "robot"

    property bool faceForward: true
    property var limits: limits
    property point motionVelocity: Qt.point(0, 5)
    property real healthStatus: 1
    property int waitInterval: 2000

    readonly property bool moving: linearVelocity !== Qt.point(0, 0)
    readonly property bool canMove: limits.leftX != 0 && limits.rightX != 0
    readonly property int boxXOffset: 18
    readonly property bool facingLeft: privateProperties.verticalDirectionState == "left"
    readonly property bool facingRight: privateProperties.verticalDirectionState == "right"
    readonly property bool grounded: privateProperties.groundContactCount > 0

    width: 30
    height: 68
    updateInterval: 50
    bodyType: Body.Dynamic
    sleepingAllowed: false
    fixedRotation: true
    z: Utils.zEnemy
    sender: "robot"

    QtObject {
        id: privateProperties

        property string verticalDirectionState: robot.faceForward ? "right" : "left"
        property string actionState: "idle"
        property point lastLinearVelocity: robot.motionVelocity
        property bool heroSpotted: false
        property int groundContactCount: 0
        property real maxFraction: 1

        readonly property bool leftLimitReached: robot.x <= robot.limits.leftX
        readonly property bool rightLimitReached: robot.x >= robot.limits.rightX

        onActionStateChanged: {
            switch (privateProperties.actionState) {
            case "dead":
                sprite.animation = "dead";
                break;
            case "dying":
                sprite.animation = "die";
                break;
            case "running":
                sprite.animation = "run";
                break;
            case "idle":
                sprite.animation = "idle";
                break;
            }

            console.log("Robot action: ", actionState);
        }

        function moveLeft() {
            //robot.linearVelocity = Utils.invertPoint(robot.motionVelocity);
            robot.linearVelocity = Qt.point(0, 0);
            privateProperties.verticalDirectionState = "left";
            privateProperties.actionState = "running";
            robot.applyLinearImpulse(Utils.invertPoint(robot.motionVelocity), robot.getWorldCenter());
        }

        function moveRight() {
            //robot.linearVelocity = robot.motionVelocity;
            robot.linearVelocity = Qt.point(0, 0);
            privateProperties.verticalDirectionState = "right";
            privateProperties.actionState = "running";
            robot.applyLinearImpulse(robot.motionVelocity, robot.getWorldCenter());
        }

        function switchDirection() {
            if (robot.canMove) {
                if (leftLimitReached)
                    moveRight();
                else if (rightLimitReached)
                    moveLeft();

                lastLinearVelocity = robot.linearVelocity;
            }
        }

        function lookoutForHero() {
            robot.linearVelocity = Qt.point(0, 0);
            privateProperties.actionState = "idle";
        }

        function depleteHealth(loss) {
            if(loss === undefined)
                loss = .1;
            else {
                if(robot.healthStatus - loss > 0)
                    robot.healthStatus -= loss;
                else {
                    robot.healthStatus = 0;
                    sprite.animation = "die";
                }
            }
        }
    }

    EntityManager { id: entityManager; parentScene: robot.scene }

    Limits { id: limits }

    fixtures: Box {
        id: mainBody
        friction: 0
        density: .2
        restitution: 0
        width: target.width
        height: target.height
        categories: Utils.kEnemy
        collidesWith: {
            if(hero !== null && (hero.wearingDisguise || hero.dead))
                Utils.kGround | Utils.kWall | Utils.kLava;
            else
                Utils.kGround | Utils.kHero | Utils.kWall | Utils.kLava;
        }

        readonly property string type: "main_body"
        readonly property string sender: robot.sender
        readonly property real damage: .1

        onBeginContact: {
            if (other.categories & Utils.kGroundTop) {
                privateProperties.groundContactCount++;
            }
        }

        onEndContact: {
            if (other.categories & Utils.kGroundTop) {
                privateProperties.groundContactCount--;
            }
        }
    }

    behavior: ScriptBehavior {
        script: {
            Ai.setUpdateInterval(robot.updateInterval);

            if (robot.canMove && !privateProperties.heroSpotted) {
                if (privateProperties.leftLimitReached) {
                    if (Ai.getElapsedTickTime("wait") < robot.waitInterval) {
                        privateProperties.lookoutForHero();
                        Ai.tick("wait");
                    } else {
                        privateProperties.switchDirection();
                        Ai.resetTicks("wait");
                    }
                } else if (privateProperties.rightLimitReached) {
                    if (Ai.getElapsedTickTime("wait") < robot.waitInterval) {
                        privateProperties.lookoutForHero();
                        Ai.tick("wait");
                    } else {
                        privateProperties.switchDirection();
                        Ai.resetTicks("wait");
                    }
                }
            } else if (privateProperties.heroSpotted) {

            }
        }
    }

    HealthBar {
        id: healthStatusBar
        anchors {
            bottom: parent.top
            bottomMargin: 5
            horizontalCenter: parent.horizontalCenter
        }
        height: 3
        width: 50
        radius: 3
        healthStatus: robot.healthStatus
    }

    Rectangle {
        color: "pink"
        opacity: .8
        width: 20
        height: width
        radius: width / 2
        x: 800
        y: 3040
        parent: robot.parent
        z: 10
    }

    Ray {
        id: leftRay
        enabled: robot.facingLeft
        scene: robot.scene

        p1: Qt.point(robot.x, robot.height / 2)
        p2: Qt.point(robot.x - multiplier * robot.width, robot.height / 2)

        onFixtureReported: {
            console.log("Fixture reported!", point.x, point.y, fixture.type, fixture.categories);
            if((fixture.categories & Utils.kHero) && fixture.type === "main_body") {
                if (closestFraction > fraction) {
                    closestFraction = fraction;
                    closestEntity = "hero";
                }

                leftRay.maxFraction = fraction;
                privateProperties.maxFraction = Math.abs(fraction);
                console.log("Found hero!!!");
            }
        }
    }

    Ray {
        id: rightRay
        enabled: robot.facingRight
        multiplier: 6
        scene: robot.scene

        p1: Qt.point(robot.x + robot.width, robot.height / 2)
        p2: Qt.point(robot.x + robot.width - multiplier * robot.width, robot.height / 2)
    }

    AnimatedSprite {
        id: sprite
        anchors.centerIn: parent
        horizontalMirror: robot.facingLeft
        spriteSheet: SpriteSheet {
            horizontalFrameCount: 10
            verticalFrameCount: 10
            source: Global.paths.images + "enemies/robot.png"
        }

        animation: "idle"
        y: {
            switch (animation) {
            case "run": -20; break;
            case "idle": 800; break;
            default: 0; break;
            }
        }

        animations: [
            SpriteAnimation {
                name: "dead"
                spriteStrip: SpriteStrip {
                    frameY: 0
                }
                duration: 500
                loops: Animation.Infinite
            },

            SpriteAnimation {
                name: "idle"
                spriteStrip: SpriteStrip {
                    frameY: frameHeight
                }
                duration: 500
                loops: Animation.Infinite
            },

            SpriteAnimation {
                name: "jump"
                spriteStrip: SpriteStrip {
                    frameY: 2 * frameHeight
                }
                duration: 500
                loops: Animation.Infinite
            },

            SpriteAnimation {
                name: "jump_melee"
                spriteStrip: SpriteStrip {
                    frameY: 3 * frameHeight
                    finalFrame: 7
                }
                duration: 500
                loops: Animation.Infinite
            },

            SpriteAnimation {
                name: "jump_shoot"
                spriteStrip: SpriteStrip {
                    finalFrame: 4
                    frameY: 4 * frameHeight
                }
                duration: 500
                loops: Animation.Infinite
            },

            SpriteAnimation {
                name: "melee"
                spriteStrip: SpriteStrip {
                    finalFrame: 7
                    frameY: 5 * frameHeight
                }
                duration: 500
                loops: Animation.Infinite
            },

            SpriteAnimation {
                name: "run"
                spriteStrip: SpriteStrip {
                    frameY: 6 * frameHeight
                    finalFrame: 7
                }
                duration: 800
                loops: Animation.Infinite
            },

            SpriteAnimation {
                name: "run_shoot"
                spriteStrip: SpriteStrip {
                    finalFrame: 8
                    frameY: 7 * frameHeight
                }
                duration: 500
                loops: Animation.Infinite
            },

            SpriteAnimation {
                name: "shoot"
                spriteStrip: SpriteStrip {
                    finalFrame: 3
                    frameY: 8 * frameHeight
                }
                duration: 500
                loops: Animation.Infinite
            },

            SpriteAnimation {
                name: "slide"
                spriteStrip: SpriteStrip {
                    frameY: 9 * frameHeight
                }
                duration: 500
                loops: Animation.Infinite
            }
        ]

        onAnimationChanged: {
            //console.log("robot animation: ", animation)
        }
    }

    /******************************** SOUNDS *********************************************/
    SoundEffect {
        id: clunkSound
        source: Global.paths.sounds + "sword_clunk.wav"
        volume: Global.settings.sfxVolume
        muted: Global.settings.noSound
    }

    /****************************** END SOUNDS *********************************************/

    function releaseBullet() {
        var bullet = entityManager.createEntity("Bullet.qml");
        bullet.y = robot.y + robot.height / 2 - 12;

        //var impulseX = newBullet.getMass() * 500;
        var impulseX = 5;
    }

    function startMovement() {
        if (robot.canMove) {
            privateProperties.actionState = "running";
            robot.linearVelocity = robot.motionVelocity;
        }
    }

    SequentialAnimation {
        id: dieAnimation

        NumberAnimation { target: robot; property: "opacity"; to: 0; duration: 250 }
        ScriptAction {
            script: {
                hero.comment();
                entityManager.destroyEntity(robot.entityId);
            }
        }
    }

    Connections {
        target: hero
        onExposedChanged: {
        }
    }

    //    Connections {
    //        target: robot.world
    //        onPreSolve: {
    //            if (contact.fixtureA.categories & Utils.kHero && contact.fixtureA.type === "main_body")
    //                contact.enabled = false;
    //            else if (contact.fixtureB.categories & Utils.kHero && contact.fixtureB.type === "main_body")
    //                contact.enabled = false;
    //        }
    //    }
}

