import QtQuick 2.9
import Bacon2D 1.0
import QtMultimedia 5.4
import Seppuku 1.0
import "../../js/Robot.js" as Ai
import "../gui"
import "../singletons"

EntityBase {
    id: robot
    //y: robot.dead ? 28 : 0
    width: 40
    height: 55
    //height: robot.dead ? 28 : 55
    updateInterval: Ai.updateInterval
    bodyType: Body.Dynamic
    sleepingAllowed: false
    fixedRotation: true
    z: Global.zEnemy
    //bullet: true
    sender: "robot"

    property int startX: 0
    property int endX: 0
    property int waitDelay: parseInt(robot.waitDelay)

    property bool facingLeft: false
    readonly property bool facingRight: !facingLeft

    // Is this enemy dead
    property bool dead: false

    // Have i seen the actor
    property bool actorSpotted: false

    // Check ranges
    property bool withinSightRange: false
    property bool withinLeftAttackingRange: false
    property bool withinRightAttackingRange: false

    // Am I striking the actor
    property bool striking: false

    readonly property int boxXOffset: 18

    property real healthStatus: 1

    QtObject {
        id: privateProperties
        property bool collidingWithGround: false

        function depleteHealth(loss) {
            if(loss === undefined)
                loss = .1;

            if(healthStatus - loss > 0)
                healthStatus -= loss;
            else {
                healthStatus = 0;
                robot.dead = true;
                sprite.animation = "die";
            }
        }
    }

    fixtures: [
        Box {
            id: mainBody
            friction: .8
            density: .8
            restitution: .1
            x: boxXOffset
            width: target.width
            height: target.height
            categories: Global.kEnemy
            collidesWith: {
                if(actor != null && (actor.wearingDisguise || actor.dead))
                    Global.kGround | Global.kWall | Global.kLava;
                else
                    Global.kGround | Global.kActor | Global.kWall | Global.kLava;
            }

            readonly property string type: "main_body"
            readonly property bool dead: robot.dead
            readonly property string sender: robot.sender
            readonly property real damage: .1

            onBeginContact: {
                if(robot.dead)
                    return
                switch(other.categories) {
                case Global.kGround:
                    privateProperties.collidingWithGround = true;
                    sprite.animation = "idle";
                    break;
                case Global.kActor:
                    if(other.type === "kunai") {
                        robot.linearDamping = 50;
                        privateProperties.depleteHealth(.2);
                    }
                    break;
                case Global.kLava:
                    robot.dead = true;
                    break;
                }
            }

            onEndContact: {
                switch(other.categories) {
                case Global.kGround:
                    privateProperties.collidingWithGround = false;
                    break;
                }
            }
        },

        Chain {
            id: leftAttackEdge
            collidesWith: Global.kActor
            sensor: true

            vertices: [
                Qt.point(boxXOffset, 0),
                Qt.point(boxXOffset, target.height)
            ]

            readonly property string type: "left_attack"
            readonly property string sender: robot.sender

            onBeginContact: {
                if(robot.dead)
                    return
                switch(other.categories) {
                case Global.kActor:
                    if(other.type === "main_body") {
//                        console.log("Robot: I can attack the ninja (left)!")
                        withinLeftAttackingRange = true;
                    }
                    break
                }
            }

            onEndContact:  {
                switch(other.categories) {
                case Global.kActor:
                    if(other.type === "main_body") {
//                        console.log("Robot: I can attack the ninja (left)!")
                        withinLeftAttackingRange = false;
                    }
                    break;
                }
            }
        },

        Chain {
            id: rightAttackEdge
            collidesWith: Global.kActor
            sensor: true

            vertices: [
                Qt.point(target.width + boxXOffset, 0),
                Qt.point(target.width + boxXOffset, target.height)
            ]

            readonly property string type: "right_attack"
            readonly property string sender: robot.sender

            onBeginContact: {
                if(robot.dead)
                    return
                switch(other.categories) {
                case Global.kActor:
                    if(other.type === "main_body") {
//                        console.log("Robot: I can attack the ninja (right)!")
                        withinRightAttackingRange = true;
                    }
                     break;
                }
            }

            onEndContact:  {
                switch(other.categories) {
                case Global.kActor:
                    if(other.type === "main_body") {
//                        console.log("Robot: I can no longer attack the ninja (right)!")
                        withinRightAttackingRange = false;
                    }
                     break;
                }
            }
        },

        Chain {
            id: leftBackEdge
            collidesWith: Global.kActor
            sensor: true

            vertices: [
                Qt.point(boxXOffset, 0),
                Qt.point(boxXOffset, target.height)
            ]

            readonly property string type: "left_back"
            readonly property string sender: robot.sender

            onBeginContact: {
                if(robot.dead)
                    return;

                switch(other.categories) {
                case Global.kActor:
                    if(other.type === "main_body") {
//                        console.log("Robot: I can attack the ninja (left)!")
                        withinLeftAttackingRange = true;
                    }
                    else if(other.type === "right_attack" && other.striking) {
                        // This is a "pearl harbor"! Once I'm hit, I perish instantly!
                        privateProperties.depleteHealth(1);
                        clunkSound.play();
                    }
                    else if(other.type === "left_attack" && other.striking) {
                        // Normal front attack
                        privateProperties.depleteHealth(.1);
                    }
                    break;
                }
            }

            onEndContact:  {
                switch(other.categories) {
                case Global.kActor:
                    if(other.type === "main_body") {
//                        console.log("Robot: I can attack the ninja (left)!")
                        withinLeftAttackingRange = false;
                    }
                    break;
                }
            }
        },

        Chain {
            id: rightBackEdge
            collidesWith: Global.kActor
            sensor: true

            vertices: [
                Qt.point(target.width + boxXOffset, 0),
                Qt.point(target.width + boxXOffset, target.height)
            ]

            readonly property string type: "right_back"
            readonly property string sender: robot.sender

            onBeginContact: {
                if(robot.dead)
                    return
                switch(other.categories) {
                case Global.kActor:
                    if(other.type === "main_body") {
//                        console.log("Robot: I can attack the ninja (right)!")
                        withinRightAttackingRange = true;
                    }
                    else if(other.type === "left_attack" && other.striking) {
                        // This is a "pearl harbor"! Once I'm hit, I perish instantly!
                        privateProperties.depleteHealth(1);
                        clunkSound.play();
                    }
                    else if(other.type === "right_attack" && other.striking) {
                        // Normal front attack
                        privateProperties.depleteHealth(.1);
                    }
                     break;
                }
            }

            onEndContact:  {
                switch(other.categories) {
                case Global.kActor:
                    if(other.type === "main_body") {
//                        console.log("Robot: I can no longer attack the ninja (right)!")
                        withinRightAttackingRange = false;
                    }
                     break;
                }
            }
        }
    ]

    behavior: ScriptBehavior {
            script: {
                if(robot.dead)
                    return;
                // Don't attack while the actor is hurting
                if(actor.hurting)
                    return;

                // Set the "actor spotted" flag
                Ai.setActorSpotted(withinSightRange /*actorSpotted*/);

                // If actor is not spotted . . .
                if(!Ai.actorSpotted || actor.dead)  {
                    // Reset shot counter
                    Ai.resetShots();
                    Ai.resetTicks("shot");

                    // If the robot is facing right . . .
                    if(robot.facingRight)
                    {
                        // Move right until "endX" is reached
                        if(robot.x < robot.endX) {
                            Ai.resetTicks("wait");
                            moveRight();
                        }

                        // Once the robot has reached the end, wait and stare
                        else if(Ai.getTicks() !== robot.waitDelay) {
                            Ai.tick("wait");
                            sprite.animation = "idle";
                        }

                        // Face the left
                        else {
                            robot.facingLeft = true;
                        }
                    }
                    else {
                        // Move left until "startX" is reached
                        if(robot.x > robot.startX) {
                            Ai.resetTicks("wait");
                            moveLeft();
                        }

                        // Once the robot has reached the end, wait and stare
                        else if(Ai.getTicks("wait") !== robot.waitDelay) {
                            Ai.tick("wait");
                            sprite.animation = "idle";
                        }

                        // Face the right
                        else
                            robot.facingLeft = false;
                    }
                }

                // If actor is spotted . . .
                else {
                    // The robot has left alert mode. He is ready to attack the actor!
                    if(Ai.getTicks("alert") >= Ai.getAlertDelay())
                    {
                        // The robot stops shooting after the maximum shots have been reached
                        if(Ai.getShots() >= Ai.getMaxShots())
                        {
                            // The shot timer ticks until the "shot delay" period is reached
                            if(Ai.getTicks("shot") < Ai.getShotDelay())
                                Ai.tick("shot");

                            // After the delay has been reached, the shot timer and shot counter is reset.
                            // The robot shoots the actor again (which increases the shot counter by 1).
                            else {
                                Ai.resetTicks("shot");
                                Ai.resetShots();

                                // Only increment shots if the actor was actually shot
                                if(shootActor())
                                    Ai.incrementShots();
                            }
                        }

                        // The robot shoots at the actor.
                        else
                        {
                            // Only increment shots if the actor was actually shot
                            if(shootActor())
                                Ai.incrementShots();
                        }
                    }

                    // The robot goes into alert mode. While in alert mode, he stays idle for the "alert delay"
                    // period.
                    else
                    {
                        Ai.tick("wait");
                        sprite.animation = "idle";
                    }
                }
            }
    }

    HealthBar {
        id: healthStatusBar
        anchors.bottom: parent.top
        anchors.bottomMargin: 5
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: 8
        height: 3
        width: 50
        radius: 3
        healthStatus: robot.healthStatus
    }

    Rectangle {
        height: 1
        color: "red"
        x: sensorRay1.facingLeft ? sensorRay1.p2.x : sensorRay1.p1.x
        y: sensorRay1.p2.y
        width: sensorRay1.pXDiff
        parent: scene
    }

    RayCast {
        id: sensorRay1
        property point p1: initialP1
        property point p2: initialP2

        readonly property point initialP1: {
            if(robot.facingLeft)
                Qt.point(robot.x + rayMargin, robot.y + robot.height / 2);
            else
                Qt.point(robot.x + robot.width + rayMargin, robot.y + robot.height / 2);
        }

        readonly property point initialP2: {
            if(robot.facingLeft)
                Qt.point(robot.x - visionSpan + rayMargin, robot.y + robot.height / 2);
            else
                Qt.point(robot.x + robot.width + visionSpan + rayMargin, robot.y + robot.height / 2);

        }

        readonly property real pXDiff: Math.abs(p1.x - p2.x)
        readonly property int multiplier: 8
        readonly property int visionSpan: 30 * multiplier
        readonly property bool facingLeft: robot.facingLeft
        readonly property int rayMargin: 0

        onFixtureReported: {
            if(fixture.categories & Global.kEnemy)
                return;

            console.log("categories?", fixture.categories);

            if (fixture.categories & Global.kActor && fixture.type === "main_body") {
                if(!actor.dead) {
                    withinSightRange = true;

                    if(actor.exposed) {
                        actorSpotted = true;
                    }
                }
            }
            else if(fixture.categories & Global.kGround) {
                if(point.x == undefined)
                    return;
//                if(facingLeft)
//                    p2.x = point.x;
//                else
//                    p1.x = point.x;
            }
            else {
                withinSightRange = false;
                //actorSpotted = false;
            }
        }

        function cast() {
            scene.rayCast(this, p1, p2);
//            console.log("p1=", p1);
//            console.log("p2=", p2);
        }
    }

    Timer {
        id: rayTimer
        running: !Global.gameWindow.paused
        repeat: true
        interval: 100

        onTriggered: sensorRay1.cast();
    }

    Sprite {
        id: sprite
        horizontalMirror: robot.facingLeft

        animations: [
            SpriteAnimation {
                name: "idle"
                source: Global.paths.images + "robot/idle.png"
                frames: 10
                duration: 500
                loops: Animation.Infinite
            },

            SpriteAnimation {
                name: "run"
                source: Global.paths.images + "robot/run.png"
                frames: 8
                duration: 1000
                loops: Animation.Infinite
                inverse: robot.facingLeft
            },

            SpriteAnimation {
                name: "melee_attack"
                source: Global.paths.images + "robot/melee_attack.png"
                frames: 8
                duration: 700
                loops: 1
                inverse: robot.facingLeft

                onFinished: sprite.animation = "idle"
            },

            SpriteAnimation {
                name: "shoot"
                source: Global.paths.images + "robot/shoot.png"
                frames: 4
                duration: 700
                loops: 1
                inverse: robot.facingLeft

                onFinished: sprite.animation = "idle"
                onFrameChanged: {
                    if(frame == frames / 2) {
                        releaseBullet()
                    }
                }
            },

            SpriteAnimation {
                name: "rise"
                source: Global.paths.images + "robot/rise.png"
                frames: 5
                duration: 1000
                loops: 1

                onFinished: sprite.animation = "fall"
            },

            SpriteAnimation {
                name: "fall"
                source: Global.paths.images + "robot/fall.png"
                frames: 5
                duration: 500
                loops: 1

                onFinished: sprite.animation = "freefall"
            },

            SpriteAnimation {
                name: "freefall"
                source: Global.paths.images + "robot/freefall.png"
                frames: 1
                duration: 500
                loops: Animation.Infinite
            },

            SpriteAnimation {
                name: "die"
                source: Global.paths.images + "robot/die.png"
                frames: 10
                duration: 1000
                loops: 1

                onFinished: sprite.animation = "dead"
            },

            SpriteAnimation {
                name: "dead"
                source: Global.paths.images + "robot/dead.png"
                frames: 1
                duration: 1000
                loops: 1

                onFinished: {
                    // After killed, fade away gradually
                    dieAnimation.start();
                }
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
        volume: settings.sfxVolume
        muted: settings.noSound
    }

    /****************************** END SOUNDS *********************************************/

    function moveLeft() {
        robot.facingLeft = true;
        sprite.animation = "run";
        robot.x -= 6;
    }

    function moveRight() {
        robot.facingLeft = false
        sprite.animation = "run";
        robot.x += 6;
    }

    function runAndAttack() {
        if(isWithinAttackingRange()) {
            attack();
        }
        else {
            runTowardsActor();
        }
    }

    function runTowardsActor() {
        if((actor.x + actor.width) < robot.x + robot.boxXOffset) {
            robot.facingLeft = true;
            sprite.animation = "run";
            moveLeft();
        }
        else {
            robot.facingLeft = false;
            sprite.animation = "run";
            moveRight();
        }
    }

    function jump() {
        if(!privateProperties.collidingWithGround) {
            console.log("Not colliding with ground");
            return;
        }

        if(sprite.animation == "idle")
            sprite.animation = "rise";
        else
            return;

        robot.applyLinearImpulse(Qt.point(0, -robot.getMass() * 10), robot.getWorldCenter());
    }

    function attack() {
        sprite.animation = "melee_attack";
    }

    function shootActor() {
        if(sprite.animation == "shoot")
            return false;

        sprite.animation = "shoot";
        return true;
    }

    function isWithinSightRange() {
        return false;
    }

    function isWithinAttackingRange() {
        return withinLeftAttackingRange || withinRightAttackingRange;
    }

    function releaseBullet() {
        var component = Qt.createComponent("Bullet.qml");
        var newBullet = component.createObject(gameWindow.currentScene)
        newBullet.y = robot.y + robot.height / 2 - 12
        newBullet.facingLeft = robot.facingLeft

        //var impulseX = newBullet.getMass() * 500
        var impulseX = 5

        if(robot.facingLeft) {
            newBullet.x = robot.x - 6
            newBullet.linearVelocity = Qt.point(-impulseX, 0)
        }
        else {
            newBullet.x = robot.x + robot.width + 6
            newBullet.linearVelocity = Qt.point(impulseX, 0)
        }
    }

    SequentialAnimation {
        id: dieAnimation

        NumberAnimation { target: robot; property: "opacity"; to: 0; duration: 250 }
        ScriptAction {
            script: {
                actor.comment();
                robot.destroy();
            }
        }
    }

//    onActorSpottedChanged: {
//        if(actorSpotted)
//            console.log("Robot: Actor has been spotted!")
//        else
//            console.log("Robot: Actor has left my sight.")
//    }

    Connections {
        target: actor
        onExposedChanged: {
            if(actor.exposed && robot.withinSightRange)
                robot.actorSpotted = true;
        }
    }

    Connections {
        target: gameWindow

        onPausedChanged: {
            if(gameWindow.paused)
                sprite.animation = "idle";
        }
    }
}

