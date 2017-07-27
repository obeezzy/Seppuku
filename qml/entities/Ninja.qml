import QtQuick 2.9
import QtMultimedia 5.9
import Bacon2D 1.0
import Seppuku 1.0
import "../singletons"

EntityBase {
    id: ninja
    width: 40
    height: {
        if(ninja.sliding || ninja.crouching)
            ninja.crouchingHeight;
        else
            ninja.standingHeight;
    }
    onHeightChanged: if(ninja.sliding || ninja.crouching) y = y + ninja.crouchingYDelta;

    bodyType: Body.Dynamic
    sleepingAllowed: false
    fixedRotation: true
    bullet: true

    signal selfDestruct
    signal disguised(bool putOn)
    signal infoRequested
    signal utilized(string type)
    signal teleported // After you have moved through a door

    // Where is the next door location
    property point nextDoorLocation: Qt.point(-1, -1)
    // Name of actor
    property string name: "tomahawk"

    // Current scene
    readonly property Scene scene: parent
    // Location of sprites
    readonly property string filePrefix: Global.paths.images + "actor/" + name + "_"
    // What's the distance moved with each step
    readonly property int xStep: 12

    readonly property bool inHoverArea: privateProperties.hoverAreaContactCount > 0

    readonly property bool facingRight: privateProperties.facingRight
    readonly property bool facingLeft: privateProperties.facingLeft
    readonly property bool facingUp: !facingDown
    readonly property bool facingDown: privateProperties.facingDown

    // Am I on the ground?
    readonly property bool airborne: !collidingWithGround

    readonly property real standingY: ninja.crouching ? ninja.y - 24 : y
    readonly property real standingHeight: 60
    readonly property real crouchingHeight: 38
    readonly property real crouchingYDelta: 24

    readonly property bool striking: privateProperties.striking
    readonly property bool running: privateProperties.running
    readonly property bool jumping: privateProperties.jumping
    readonly property bool falling: privateProperties.falling
    readonly property bool clinging: privateProperties.clinging
    readonly property bool climbing: privateProperties.climbing
    readonly property bool hovering: privateProperties.hovering
    readonly property bool sliding: privateProperties.sliding
    readonly property bool crouching: privateProperties.crouching
    readonly property bool hurting: privateProperties.hurting
    readonly property bool dead: privateProperties.dead
    readonly property string deathCause: privateProperties.deathCause
    readonly property real healthStatus: privateProperties.healthStatus

    readonly property int totalCoinsCollected: privateProperties.totalCoinsCollected
    readonly property int totalKunaiCollected: privateProperties.totalKunaiCollected
    readonly property int totalBlueKeysCollected: privateProperties.totalBlueKeysCollected
    readonly property int totalYellowKeysCollected: privateProperties.totalYellowKeysCollected
    readonly property int totalRedKeysCollected: privateProperties.totalRedKeysCollected
    readonly property int totalGreenKeysCollected: privateProperties.totalGreenKeysCollected

    // Is the player on the ground
    readonly property bool collidingWithGround: privateProperties.groundContactCount > 0 && !privateProperties.clinging

    readonly property bool inDisguiseRange: privateProperties.inDisguiseRange
    readonly property bool wearingDisguise: privateProperties.wearingDisguise
    // Can the actor be seen by the enemy
    readonly property bool exposed: {
        if(!ninja.wearingDisguise)
            true
        else if(ninja.wearingDisguise && !ninja.running)
            false
        else
            true
    }

    readonly property bool inInfoRange: privateProperties.inInfoRange
    readonly property bool inLeverRange: privateProperties.inLeverRange
    readonly property bool inDoorRange: privateProperties.inDoorRange

    QtObject {
        id: privateProperties

        property int ladderContactCount: 0
        property int groundContactCount: 0
        property int hoverAreaContactCount: 0

        // Which way is the player facing
        readonly property bool facingRight: !facingLeft
        property bool facingLeft: false

        // While climbing a ladder...
        readonly property bool facingUp: !facingDown
        property bool facingDown: false

        // Is this ninja striking another ninja (when his weapon actually touches the enemy)
        property bool striking: false

        // Is playing pressing "crouch"?
        property bool crouchPressed: false

        property bool running: false
        property bool jumping: false
        property bool falling: false
        property bool clinging: false
        property bool climbing: false
        property bool hovering: false
        readonly property bool sliding: sprite.animation == "slide"
        readonly property bool crouching: sprite.animation == "crouch" || sprite.animation == "crouch_attack"

        // Is this ninja in pain?
        property bool hurting: false

        // Is ninja dead?
        property bool dead: false

        // Reason for death
        property string deathCause: ""

        // health values
        property real healthStatus: 1

        // Number of coins
        property int totalCoinsCollected: 0

        // Number of kunai
        property int totalKunaiCollected: 2

        // Number of keys
        property int totalBlueKeysCollected: 0
        property int totalYellowKeysCollected: 0
        property int totalRedKeysCollected: 0
        property int totalGreenKeysCollected: 0

        // Can he be disguised?
        property bool inDisguiseRange: false
        // Is he wearing disguise?
        property bool wearingDisguise: false

        // Can I read any info sign close to me
        property bool inInfoRange: false

        // Am i close to a lever?
        property bool inLeverRange: false

        // Am I in front of a door?
        property bool inDoorRange: false

        // Box margins
        readonly property int leftBoxMargin: 3
        readonly property int rightBoxMargin: 9

        function depleteHealth(loss, sender) {
            if(loss === undefined)
                loss = .1;
            if(sender === undefined)
                sender = "";

            if(privateProperties.healthStatus - loss > 0)
                privateProperties.healthStatus -= loss;
            else {
                privateProperties.healthStatus = 0;
                privateProperties.deathCause = sender;
                privateProperties.dead = true;
            }

            ouchSound.play();
        }
    }

    fixtures: [
        Box {
            id: mainBody
            friction: .6
            density: .4
            restitution: 0

            x: privateProperties.leftBoxMargin
            width: target.width - privateProperties.rightBoxMargin
            height: target.height
            categories: Utils.kActor
            collidesWith: {
                Utils.kGround | Utils.kWall | Utils.kCollectible |
                            Utils.kEnemy | Utils.kLadder | Utils.kCovert |
                            Utils.kObstacle | Utils.kInteractive | Utils.kHoverArea |
                            Utils.kLava
            }

            readonly property bool exposed: ninja.exposed
            readonly property string type: "main_body"

            onBeginContact: {
                if(ninja.dead)
                    return;
                if(other.categories & Utils.kEnemy) {
                    if(other.type === "main_body") {
                        //console.log("Actor: I collided with the enemy. Ouch!")
                        if(other.dead)
                            return;
                        privateProperties.depleteHealth(other.damage, other.sender);
                        ninja.receivePain();
                    }
                    else if(other.type === "vision") {
                        //console.log("I've been spotted by the enemy.");
                    }
                    else if(other.type === "bullet") {
                        privateProperties.depleteHealth(other.damage, other.sender);
                        ninja.receivePain();
                    }
                }
                else if(other.categories & Utils.kCollectible) {
                    if(other.type === "coin" && !other.picked)
                        addCoin();
                    else if(other.type === "kunai")
                        addKunai();
                    else if(other.type === "key")
                        addKey(other.color);
                }
                else if(other.categories & Utils.kLadder) {
                    privateProperties.ladderContactCount++;
                    ninja.gravityScale = 0;
                    ninja.linearVelocity = Qt.point(0, 0);
                    privateProperties.clinging = true;
                    sprite.animation = "cling";
                }
                else if(other.categories & Utils.kObstacle) {
                    if(other.type === "crystal") {
                        privateProperties.depleteHealth(other.damage, other.sender);
                        ninja.receivePain();
                    }
                    else if(other.type === "rope") {
                        // do nothing
                    }
                }
                else if(other.categories & Utils.kCovert) {
                    privateProperties.inDisguiseRange = true;
                }
                else if(other.categories & Utils.kHoverArea) {
                    privateProperties.hoverAreaContactCount++;
                }
                else if(other.categories & Utils.kInteractive) {
                    if(other.type === "info_sign")
                        privateProperties.inInfoRange = true;
                    else if(other.type === "lever")
                        privateProperties.inLeverRange = true;
                }
                else if(other.categories & Utils.kLava) {
                    privateProperties.depleteHealth(1, other.sender);
                }
                else if(other.categories & Utils.kDoor) {

                }
            }

            onEndContact: {
                if(ninja.dead)
                    return
                if(other.categories & Utils.kLadder) {
                    privateProperties.ladderContactCount--;

                    if(privateProperties.ladderContactCount == 0) {
                        ninja.gravityScale = 1;
                        privateProperties.clinging = false;

                        if(!privateProperties.collidingWithGround)
                            sprite.animation = "freefall";
                        else
                            sprite.animation = "idle";
                    }
                }
                else if(other.categories & Utils.kCovert) {
                    privateProperties.inDisguiseRange = false;
                }
                else if(other.categories & Utils.kHoverArea) {
                    privateProperties.hoverAreaContactCount--;
                }
                else if(other.categories & Utils.kInteractive) {
                    if(other.type === "info_sign")
                        privateProperties.inInfoRange = false;
                    else if(other.type === "lever")
                        privateProperties.inLeverRange = false;
                }
            }
        },

        Box {
            id: headSensor
            y: -height
            x: privateProperties.leftBoxMargin
            width: target.width - privateProperties.rightBoxMargin
            height: 1
            sensor: true
            categories: Utils.kActor
            collidesWith: Utils.kObstacle

            readonly property string type: "head"

            onBeginContact: {
                if(ninja.dead)
                    return;

                if(other.categories == (Utils.kObstacle | Utils.kGround)) {
                    // Do nothing
                }
                else if(other.categories & Utils.kObstacle) {
                    if(other.type === "ice_box")
                        privateProperties.depleteHealth(other.damage, other.sender);
                }
            }
        },

        Box {
            id: groundSensor
            x: 3
            y: target.height
            width: target.width - 3
            height: 1
            sensor: true
            categories: Utils.kActor
            collidesWith: Utils.kGroundTop

            readonly property string type: "ground"

            onBeginContact: {
                if(ninja.dead)
                    return;

                if(other.categories & Utils.kGroundTop) {
                    privateProperties.groundContactCount++;

                    if(!ninja.sliding && !ninja.running && !ninja.hurting)
                        sprite.animation = "idle";
                }
            }

            onEndContact: {
                if(other.categories & Utils.kGroundTop) {
                    privateProperties.hovering = false;
                    privateProperties.groundContactCount--;
                }
            }
        }
    ]

    AnimatedSprite {
        id: sprite
        y: {
            switch (animation) {
            case "attack_main": -10; break;
            case "run": -25; break;
            case "slide": -40; break;
            case "cling":
            case "climb": -6; break;
            default: -17; break;
            }
        }

        anchors.horizontalCenter: parent.horizontalCenter
        animation: "idle"
        source: Global.paths.images + "actor/" + ninja.name + ".png"
        horizontalMirror: ninja.facingLeft
        horizontalFrameCount: 10
        verticalFrameCount: 17

        Component.onCompleted: sprite.animation = "freefall";

        animations: [
            SpriteAnimation {
                name: "attack_main"
                finalFrame: 6
                frameY: 0
                duration: 500
                loops: 1
                inverse: ninja.facingLeft

                onFinished: sprite.animation = "idle";
            },

            SpriteAnimation {
                name: "attack_secondary"
                finalFrame: 7
                frameY: frameHeight
                duration: 500
                loops: Animation.Infinite
            },

            SpriteAnimation {
                name: "climb"
                frameY: 2 * frameHeight
                duration: 500
                loops: Animation.Infinite
            },

            SpriteAnimation {
                name: "crouch"
                frameY: 4 * frameHeight
                duration: 500
                loops: Animation.Infinite
            },

            SpriteAnimation {
                name: "crouch_attack"
                finalFrame: 7
                frameY: 3 * frameHeight
                duration: 500
                loops: 1

                onFinished: sprite.animation = privateProperties.crouchPressed ? "crouch" : "idle";
            },

            SpriteAnimation {
                name: "crouch_throw"
                finalFrame: 5
                frameY: 5 * frameHeight
                duration: 500
                loops: 1

                onFinished: sprite.animation = privateProperties.crouchPressed ? "crouch" : "idle";
            },

            SpriteAnimation {
                name: "die"
                frameY: 6 * frameHeight
                frameWidth: .08102981029 * sprite.sourceSize.width
                duration: 500
                loops: 1

                onFinished: sprite.animation = "dead";
            },

            SpriteAnimation {
                name: "hover"
                frameY: 7 * frameHeight
                duration: 500
                loops: Animation.Infinite
            },

            SpriteAnimation {
                name: "hurt"
                finalFrame: 7
                frameY: 8 * frameHeight
                duration: 500
                loops: 1

                onRunningChanged: if (!running) privateProperties.hurting = false;
                onFinished: sprite.animation = "idle";
            },

            SpriteAnimation {
                name: "idle"
                frameY: 9 * frameHeight
                duration: 500
                loops: Animation.Infinite
            },

            SpriteAnimation {
                name: "jump"
                frameY: 11 * frameHeight
                duration: 500
                loops: Animation.Infinite
            },

            SpriteAnimation {
                name: "jump_attack"
                finalFrame: 6
                frameY: 10 * frameHeight
                duration: 500
                loops: 1

                onFinished: if(!ninja.dead) sprite.animation = "freefall";
            },

            SpriteAnimation {
                name: "jump_throw"
                finalFrame: 5
                frameY: 12 * frameHeight
                duration: 500
                loops: 1

                onFinished: if(!ninja.dead) sprite.animation = "freefall";
            },

            SpriteAnimation {
                name: "run"
                finalFrame: 7
                frameY: 13 * frameHeight
                duration: 500
                loops: Animation.Infinite
                inverse: ninja.facingLeft
            },

            SpriteAnimation {
                name: "slide"
                frameY: 14 * frameHeight
                duration: 500
                loops: Animation.Infinite
            },

            SpriteAnimation {
                name: "throw"
                finalFrame: 5
                frameY: 15 * frameHeight
                duration: 500
                loops: 1
                onRunningChanged: if(!running) sprite.animation = "idle";
            },

            SpriteAnimation {
                name: "walk"
                frameY: 16 * frameHeight
                duration: 500
                loops: Animation.Infinite
            },

            SpriteAnimation {
                name: "freefall"
                frameY: 11 * frameHeight
                initialFrame: 9
                duration: 250
                loops: Animation.Infinite
            },

            SpriteAnimation {
                name: "rise"
                frameY: 11 * frameHeight
                finalFrame: 8
                duration: 500
                loops: 1

                onFinished: if(!ninja.dead) sprite.animation = "freefall";
            },

            SpriteAnimation {
                name: "dead"
                frameY: 6 * frameHeight
                frameWidth: .08102981029 * sprite.sourceSize.width
                initialFrame: 9
                duration: 500
                loops: Animation.Infinite
            },

            SpriteAnimation {
                name: "cling"
                initialFrame: 9
                frameY: 2 * frameHeight
                duration: 500
                loops: Animation.Infinite
            }
        ]
    } // end of Sprite

    RayCast {
        id: attackRay

        property point p1: {
            if(ninja.facingLeft)
                Qt.point(ninja.x + ninja.width, ninja.y + ninja.height / 2);
            else
                Qt.point(ninja.x, ninja.y + ninja.height / 2);
        }
        property point p2: {
            if(ninja.facingLeft)
                Qt.point(ninja.x - ninja.width * multiplier, p1.y);
            else
                Qt.point(ninja.x + ninja.width + ninja.width * multiplier, p1.y);
        }

        readonly property int multiplier: 2
        readonly property int pXDiff: Math.abs(p2.x - p1.x)
        readonly property int pYDiff: Math.abs(p2.y - p1.y)

        onFixtureReported: {
            if (fixture.categories & Utils.kEnemy && fixture.type === "main_body") {
            }
        }

        function cast() {
            if(ninja.dead)
                return;

            scene.rayCast(this, p1, p2);
        }
    }

    Timer {
        id: rMoveLeftTimer
        interval: 50
        repeat: true
        triggeredOnStart: true
        onTriggered: ninja.rMoveLeft();
    }

    Timer {
        id: rMoveRightTimer
        interval: 50
        repeat: true
        triggeredOnStart: true
        onTriggered: ninja.rMoveRight();
    }

    // After climb up/down is called, it waits for the actor to move up a bit then stops him
    Timer {
        id: rClimbUpTimer
        interval: 59
        repeat: false
        running: ninja.climbing
        onTriggered: ninja.rClimbUp();
    }

    Timer {
        id: rClimbDownTimer
        interval: 50
        repeat: false
        running: ninja.climbing
        onTriggered: ninja.rClimbDown();
    }

    Timer {
        id: rHoverTimer
        interval: 50
        repeat: true
        onTriggered: ninja.rHover();
    }

    Timer {
        id: hoveringFreefallDelayTimer
        interval: 200
        repeat: false
        onTriggered: if(!ninja.dead) sprite.animation = "freefall";
    }

    Timer {
        id: rCrouchTimer
        interval: 200
        repeat: true
        triggeredOnStart: true
        onTriggered: sprite.animation = "crouch";
    }

    Timer {
        id: attackRayTimer
        interval: 20
        repeat: true
        triggeredOnStart: true
        running: ninja.striking
        onTriggered: attackRay.cast();
    }

    /***************************** SOUNDS *****************************************/
    SoundEffect {
        id: throwSound
        source: Global.paths.sounds + "throw.wav"
        volume: Global.settings.sfxVolume
        muted: Global.settings.noSound
    }

    SoundEffect {
        id: swordSwingSound
        source: Global.paths.sounds + "sword.wav"
        volume: Global.settings.sfxVolume
        muted: Global.settings.noSound
    }

    SoundEffect {
        id: dryFireSound
        source: Global.paths.sounds + "dry_fire.wav"
        volume: Global.settings.sfxVolume
        muted: Global.settings.noSound
    }

    SoundEffect {
        id: jumpSound
        source: Global.paths.sounds + "jump.wav"
        volume: Global.settings.sfxVolume
        muted: Global.settings.noSound
    }

    SoundEffect {
        id: commentSound
        source: Global.paths.sounds + "that_would_teach_them.wav"
        volume: Global.settings.sfxVolume
        muted: Global.settings.noSound
    }

    SoundEffect {
        id: ouchSound
        source: Global.paths.sounds + "ouch.wav"
        volume: Global.settings.sfxVolume
        muted: Global.settings.noSound

        readonly property variant sourceList: [
            Global.paths.sounds + "ouch.wav",
            Global.paths.sounds + "ouch2.wav"
        ]

        onPlayingChanged: if(!playing) source = getRandomSource();

        function getRandomSource() { return sourceList[Math.floor(Math.random() * sourceList.length)]; }
    }

    /*********************** END SOUNDS *********************************************/

    function moveLeft() {
        if(Global.gameWindow.paused)
            return;
        if(ninja.hurting)
            return;
        if(ninja.dead)
            return;
        if(ninja.sliding)
            return;

        rMoveLeftTimer.start();
        rMoveRightTimer.stop();
        ninja.facingLeft = true;
    }

    function moveRight() {
        if(Global.gameWindow.paused)
            return;
        if(ninja.hurting)
            return;
        if(ninja.dead)
            return;
        if(ninja.sliding)
            return;

        rMoveLeftTimer.stop();
        rMoveRightTimer.start();
        ninja.facingLeft = false;
    }

    // Repeat move left
    function rMoveLeft() {
        if(Global.gameWindow.paused)
            return;
        if(ninja.dead)
            return;
        if(ninja.sliding)
            return;

        ninja.x -= ninja.xStep;
        ninja.facingLeft = true;

        if(ninja.clinging)
            return;
        if(ninja.hovering)
            return;

        if(!ninja.airborne) {
            privateProperties.running = true;
            sprite.animation = "run";
        }
        else {
            privateProperties.running = false;
            if (sprite.animation != "freefall")
                sprite.animation = "rise";
        }
    }

    // Repeat move right
    function rMoveRight() {
        if(Global.gameWindow.paused)
            return;
        if(ninja.dead)
            return;
        if(ninja.sliding)
            return;

        ninja.x += ninja.xStep;
        ninja.facingLeft = false;

        if(ninja.clinging)
            return;
        if(ninja.hovering)
            return;

        if(!ninja.airborne) {
            privateProperties.running = true;
            sprite.animation = "run";
        }
        else {
            privateProperties.running = false;
            if (sprite.animation != "freefall")
                sprite.animation = "rise";
        }
    }

    function stopMovingLeft() {
        if(ninja.dead)
            return;

        rMoveLeftTimer.stop()
        ninja.facingLeft = true;
        privateProperties.running = false;

        if(ninja.clinging)
            return;
        if(ninja.inHoverArea && !privateProperties.collidingWithGround)
            return;

        if(!ninja.airborne && !ninja.hurting)
            sprite.animation = "idle";
    }

    function stopMovingRight() {
        if(ninja.dead)
            return;

        rMoveRightTimer.stop();
        ninja.facingLeft = false;
        privateProperties.running = false;

        if(ninja.clinging)
            return;
        if(ninja.inHoverArea && !privateProperties.collidingWithGround)
            return;

        if(!ninja.airborne && !ninja.hurting)
            sprite.animation = "idle";
    }

    function jump() {
        if(Global.gameWindow.paused)
            return;
        if(ninja.hurting)
            return;
        if(ninja.dead)
            return;
        if(ninja.clinging)
            return;
        if(ninja.airborne)
            return;

        if(ninja.wearingDisguise)
            toggleDisguise();

        if(sprite.animation == "idle" || privateProperties.running)
            sprite.animation = "rise";
        else
            return;

        jumpSound.play()
        ninja.applyLinearImpulse(Qt.point(0, -ninja.getMass() * 10), ninja.getWorldCenter());
    }

    function crouch() {
        if(Global.gameWindow.paused)
            return;
        if(ninja.hurting)
            return;
        if(ninja.dead)
            return;
        if(ninja.clinging)
            return;
        if(!privateProperties.collidingWithGround)
            return;

        if(ninja.wearingDisguise)
            toggleDisguise();

        if(sprite.animation == "idle")
            sprite.animation = "crouch";

        privateProperties.crouchPressed = true;
    }

    function stopCrouching() {
        if(!ninja.dead)
            sprite.animation = "idle";
        privateProperties.crouchPressed = false;
    }

    // Flag that tells the privateProperties.rightBoxMargin if the hover button (e.g. button A on an Xbox pad) is still held down
    // If it is, the privateProperties.rightBoxMargin would be kept afloat in the hover area, else, the privateProperties.rightBoxMargin would drop
    property bool hoverKeyHeldDown: false

    function hover(heldDown) {
        if(Global.gameWindow.paused)
            return;
        if(ninja.hurting)
            return;
        if(ninja.dead)
            return;
        if(ninja.sliding)
            return;

        if(heldDown === undefined)
            heldDown = false;

        hoverKeyHeldDown = heldDown;
        rHoverTimer.restart();
    }

    function rHover() {
        if(ninja.dead)
            return;
        if(ninja.hurting)
            return;
        if(Global.gameWindow.paused)
            return;

        if(ninja.inHoverArea) {
            ninja.gravityScale = 0;
            ninja.linearVelocity = Qt.point(0, -5);
            sprite.animation = "hover";
            privateProperties.facingDown = false;
            //privateProperties.collidingWithGround = false;
            privateProperties.hovering = true;
            hoveringFreefallDelayTimer.stop();
        }
        else {
            ninja.gravityScale = 1;
            ninja.linearVelocity = Qt.point(0, 0);
            ninja.facingDown = true;
            hoveringFreefallDelayTimer.restart();
            rHoverTimer.stop();

            if(hoverKeyHeldDown) {
                rHoverTimer.start();
                hoverKeyHeldDown = false;
            }
        }
    }

    function stopHovering() {
        ninja.gravityScale = 1;
        ninja.linearVelocity = Qt.point(0, 0);
        privateProperties.facingDown = true;
        privateProperties.hovering = false;
        hoveringFreefallDelayTimer.stop();
        rHoverTimer.stop();
    }

    function slide() {
        if(Global.gameWindow.paused)
            return false;
        if(ninja.hurting)
            return false;
        if(ninja.dead)
            return false;
        if(ninja.airborne)
            return false;
        if(ninja.clinging)
            return false;
        if(!ninja.running)
            return false;

        sprite.animation = "slide";

        // Stop privateProperties.rightBoxMargin if he was moving before
        linearVelocity.x = linearVelocity.x > 5 ? 0: linearVelocity.x;
        if(ninja.facingLeft)
            ninja.applyLinearImpulse(Qt.point(-ninja.getMass() * 10, 0), ninja.getWorldCenter());
        else
            ninja.applyLinearImpulse(Qt.point(ninja.getMass() * 10, 0), ninja.getWorldCenter());

        return true;
    }

    function climbUp() {
        if(Global.gameWindow.paused)
            return;
        if(ninja.dead)
            return;
        if(!ninja.clinging)
            return;

        rClimbDownTimer.stop();
        rClimbUpTimer.start();
    }

    function climbDown() {
        if(Global.gameWindow.paused)
            return;
        if(ninja.dead)
            return;
        if(!ninja.clinging)
            return;

        rClimbUpTimer.stop();
        rClimbDownTimer.start();
    }

    function rClimbUp() {
        if(Global.gameWindow.paused)
            return;
        if(ninja.dead)
            return;
        if(ninja.linearVelocity == Qt.point(0, 0))
            ninja.applyLinearImpulse(Qt.point(0, -ninja.getMass() * 3), ninja.getWorldCenter());

        privateProperties.climbing = true;
        privateProperties.facingDown = false;
        sprite.animation = "climb";
    }

    function rClimbDown() {
        if(Global.gameWindow.paused)
            return;
        if(ninja.dead)
            return;
        if(ninja.linearVelocity == Qt.point(0, 0))
            ninja.applyLinearImpulse(Qt.point(0, ninja.getMass() * 3), ninja.getWorldCenter());
        privateProperties.climbing = true;
        privateProperties.facingDown = true;
        sprite.animation = "climb";
    }

    function stopClimbingUp() {
        if(ninja.dead)
            return;
        if(!ninja.clinging)
            return;

        rClimbUpTimer.stop();
        ninja.linearVelocity = Qt.point(0, 0);
        sprite.animation = "cling";
    }

    function stopClimbingDown() {
        if(ninja.dead)
            return;
        if(!ninja.clinging)
            return;

        rClimbDownTimer.stop();
        ninja.linearVelocity = Qt.point(0, 0);
        sprite.animation = "cling";
    }

    function attack() {
        if(Global.gameWindow.paused)
            return;
        if(ninja.hurting)
            return;
        if(ninja.dead)
            return;
        if(ninja.clinging)
            return;
        if(ninja.hovering)
            return;
        if(sprite.animation == "attack_main")
            return;
        if(sprite.animation == "attack_secondary")
            return;
        if(sprite.animation == "jump_attack")
            return;
        if(sprite.animation == "crouch_attack")
            return;

        if(wearingDisguise)
            toggleDisguise();
        else if(ninja.airborne)
            sprite.animation = "jump_attack";
        else if(ninja.crouching)
            sprite.animation = "crouch_attack";
        else
            sprite.animation = "attack_main";

        swordSwingSound.play();
    }

    function throwKunai() {
        if(Global.gameWindow.paused)
            return;
        if(ninja.hurting)
            return;
        if(ninja.dead)
            return;
        if(ninja.airborne)
            return;
        if(ninja.clinging)
            return;
        if(sprite.animation == "throw")
            return;
        if(totalKunaiCollected == 0) {
            dryFireSound.play();
            return;
        }
        if(wearingDisguise)
            toggleDisguise();

        sprite.animation = "throw";
    }

    function createKunai() {
        var component = Qt.createComponent("Kunai.qml");
        var kunai = component.createObject(scene);
        var impulseX = 10;
        var rSpeed = 0; //700;

        if(ninja.facingLeft) {
            kunai.x = ninja.x; //+ 60;
            kunai.y = ninja.y + ninja.height / 2 - 12;
            kunai.rotation = 270;
            kunai.linearVelocity = Qt.point(-impulseX, 0);
            kunai.angularVelocity = rSpeed;
        }
        else {
            kunai.x = ninja.x + ninja.width; //+ 60
            kunai.y = ninja.y + ninja.height / 2 - 12;
            kunai.rotation = 90;
            kunai.linearVelocity = Qt.point(impulseX, 0);
            kunai.angularVelocity = -rSpeed;
        }
    }

    function use() {
        if(ninja.dead)
            return;
        if(ninja.inDisguiseRange)
            ninja.toggleDisguise();
        else if(ninja.inInfoRange)
            ninja.infoRequested();
        else if(ninja.inLeverRange)
            utilized("lever");
        else if(ninja.inDoorRange)
            ninja.goToDoor();
        else
            ninja.slide();
    }

    function toggleDisguise() {
        if(!ninja.inDisguiseRange)
            return;

        ninja.wearingDisguise = !ninja.wearingDisguise;
        ninja.disguised(ninja.wearingDisguise);
    }

    function receivePain() {
        if(ninja.dead)
            return;

        privateProperties.hurting = true;
        sprite.animation = "hurt";
        linearVelocity = Qt.point(0, 0);
    }

    function stun(sender) {
        privateProperties.depleteHealth(.4, sender);
        ninja.receivePain();
        ninja.stopHovering();
    }

    function addCoin() { privateProperties.totalCoinsCollected++; }

    function addKunai() { privateProperties.totalKunaiCollected++; }

    function addKey(color) {
        switch(color) {
        case "yellow":
            privateProperties.totalYellowKeysCollected++;
            break;
        case "red":
            privateProperties.totalRedKeysCollected++;
            break;
        case "green":
            privateProperties.totalGreenKeysCollected++;
            break;
        default:
            privateProperties.totalBlueKeysCollected++;
            break;
        }
    }

    function dropKey(color) {
        switch(color) {
        case "yellow":
            if(privateProperties.totalYellowKeysCollected > 0)
                privateProperties.totalYellowKeysCollected--;
            break;
        case "red":
            if(privateProperties.totalRedKeysCollected > 0)
                privateProperties.totalRedKeysCollected--;
            break;
        case "green":
            if(privateProperties.totalGreenKeysCollected > 0)
                privateProperties.totalGreenKeysCollected--;
            break
        default:
            if(privateProperties.totalBlueKeysCollected > 0)
                privateProperties.totalBlueKeysCollected--;
            break;
        }
    }

    function comment() { commentSound.play(); }

    function stopAllActions() {
        ninja.stopMovingLeft();
        ninja.stopMovingRight();
        ninja.stopHovering();
        ninja.stopClimbingUp();
        ninja.stopClimbingDown();
        ninja.stopCrouching();
    }

    function goToDoor() {
        if(ninja.daed)
            return;
        if(nextDoorLocation == Qt.point(-1, -1))
            return;

        ninja.x = nextDoorLocation.x;
        ninja.y = nextDoorLocation.y;
        ninja.teleported();
    }

    onDeadChanged: {
        if (privateProperties.dead) {
            if(wearingDisguise)
                toggleDisguise();

            rMoveLeftTimer.stop();
            rMoveRightTimer.stop();
            sprite.animation = "die";
            ninja.gravityScale = 1;
            privateProperties.healthStatus = 0;
            selfDestruct();
        }
    }
}

