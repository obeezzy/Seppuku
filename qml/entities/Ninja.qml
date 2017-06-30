import QtQuick 2.9
import QtMultimedia 5.9
import Bacon2D 1.0
import Seppuku 1.0
import "../singletons"

EntityBase {
    id: ninja
    width: 48
    height: {
        if(ninja.sliding)
            38;
        else
            60;
    }
    bodyType: Body.Dynamic
    sleepingAllowed: false
    fixedRotation: true
    bullet: true

    Rectangle {
        anchors.fill: parent
        color: "green"
        opacity: 0
    }

    onHeightChanged: {
        if(ninja.sliding)
            y = y + 60 - 36;
    }

    signal selfDestruct
    signal disguised(bool putOn)
    signal displayMessage()
    signal utilized(string type)

    // Current scene
    readonly property Scene scene: parent

    // Location of sprites
    readonly property string fileLocation: Global.paths.images + "actor/" + name + "/"

    // Name of actor
    property string name: "tomahawk"

    // What's the distance moved with each step
    readonly property int xStep: 12

    // Is he in the wind area?
    readonly property bool inHoverArea: hoverAreaContactCount > 0

    property int ladderContactCount: 0
    property int groundContactCount: 0
    property int hoverAreaContactCount: 0

    // Which way is the player facing
    readonly property bool facingRight: !facingLeft
    property bool facingLeft: false

    // While climbing a ladder...
    readonly property bool facingUp: !facingDown
    property bool facingDown: false

    // Check if you just finished sliding
    property bool slidingDone: false

    // Is this ninja striking another ninja (when his weapon actually touches the enemy)
    property bool striking: false

    // Am I on the ground?
    readonly property bool airborne: {
        (sprite.animation == "rise"
                 || sprite.animation == "fall"
                 || sprite.animation == "freefall"
                 || sprite.animation == "hover"
                 || jumping)
                && !privateProperties.collidingWithGround
    }

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
    // Can the actor be seen by the enemy
    readonly property bool exposed: {
        if(!ninja.wearingDisguise)
            true
        else if(ninja.wearingDisguise && !ninja.running)
            false
        else
            true
    }

    // Can I read any info sign close to me
    property bool inInfoRange: false

    // Am i close to a lever?
    property bool inLeverRange: false

    // Am I in front of a door?
    property bool inDoorRange: false

    // Where is the next door location
    property point nextDoorLocation: Qt.point(-1, -1)

    // After you have moved through a door
    signal teleported

    QtObject {
        id: privateProperties

        // Is the player on the ground
        readonly property bool collidingWithGround: groundContactCount > 0

        // Is playing pressing "crouch"?
        property bool crouchPressed: false

        //
        readonly property int leftBoxMargin: 3
        readonly property int rightBoxMargin: 9

        function depleteHealth(loss, sender) {
            if(loss === undefined)
                loss = .1;
            if(sender === undefined)
                sender = "";

            if(healthStatus - loss > 0)
                healthStatus -= loss;
            else {
                healthStatus = 0;
                ninja.deathCause = sender;
                ninja.dead = true;
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
            categories: Global.kActor
            collidesWith: {
                Global.kGround | Global.kWall | Global.kCollectible |
                            Global.kEnemy | Global.kLadder | Global.kCovert |
                            Global.kObstacle | Global.kInteractive | Global.kHoverArea |
                            Global.kLava
            }

            readonly property bool exposed: ninja.exposed
            readonly property string type: "main_body"

            onBeginContact: {
                if(ninja.dead)
                    return;
                if(other.categories & Global.kEnemy) {
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
                else if(other.categories & Global.kCollectible) {
                    if(other.type === "coin" && !other.picked)
                        addCoin();
                    else if(other.type === "kunai")
                        addKunai();
                    else if(other.type === "key")
                        addKey(other.color);
                }
                else if(other.categories & Global.kLadder) {
                    ninja.ladderContactCount++;
                    ninja.gravityScale = 0;
                    ninja.linearVelocity = Qt.point(0, 0);
                    ninja.clinging = true;
                    ninja.setAnimation("cling");
                }
                else if(other.categories & Global.kObstacle) {
                    if(other.type === "crystal") {
                        privateProperties.depleteHealth(other.damage, other.sender);
                        ninja.receivePain();
                    }
                    else if(other.type === "rope") {
                        // do nothing
                    }
                }
                else if(other.categories & Global.kCovert) {
                    ninja.inDisguiseRange = true;
                }
                else if(other.categories & Global.kHoverArea) {
                    ninja.hoverAreaContactCount++;
                }
                else if(other.categories & Global.kInteractive) {
                    if(other.type === "info_sign")
                        ninja.inInfoRange = true;
                    else if(other.type === "lever")
                        ninja.inLeverRange = true;
                }
                else if(other.categories & Global.kLava) {
                    privateProperties.depleteHealth(1, other.sender);
                }
                else if(other.categories & Global.kDoor) {

                }
            }

            onEndContact: {
                if(ninja.dead)
                    return
                if(other.categories & Global.kLadder) {
                    ninja.ladderContactCount--;

                    if(ninja.ladderContactCount == 0) {
                        ninja.gravityScale = 1;
                        ninja.clinging = false;

                        if(!privateProperties.collidingWithGround)
                            ninja.setAnimation("freefall");
                        else
                            ninja.setAnimation("idle");
                    }
                }
                else if(other.categories & Global.kCovert) {
                    ninja.inDisguiseRange = false;
                }
                else if(other.categories & Global.kHoverArea) {
                    ninja.hoverAreaContactCount--;
                }
                else if(other.categories & Global.kInteractive) {
                    if(other.type === "info_sign")
                        ninja.inInfoRange = false;
                    else if(other.type === "lever")
                        ninja.inLeverRange = false;
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
            categories: Global.kActor
            collidesWith: Global.kObstacle

            readonly property string type: "head"

            onBeginContact: {
                if(ninja.dead)
                    return;

                if(other.categories == (Global.kObstacle | Global.kGround)) {
                    // Do nothing
                }
                else if(other.categories & Global.kObstacle) {
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
            categories: Global.kActor
            collidesWith: Global.kGroundTop

            readonly property string type: "ground"

            onBeginContact: {
                if(ninja.dead)
                    return;

                if(other.categories & Global.kGroundTop) {
                    ninja.groundContactCount++;

                    if(!ninja.sliding && !ninja.running && !ninja.hurting)
                        ninja.setAnimation("idle");
                }
            }

            onEndContact: {
                if(other.categories & Global.kGroundTop) {
                    ninja.hovering = false;
                    ninja.groundContactCount--;
                }
            }
        },

        Box {
            id: leftStrikeSensor
            x: ninja.striking && ninja.facingLeft ? -target.width * .6 : 0
            y: 5
            width: ninja.striking && ninja.facingLeft ? target.width * .6 : 0
            height: target.height - 10

            sensor: true
            categories: ninja.striking ? Global.kActor : Global.kIntangible

            readonly property string type: "left_attack"
            readonly property bool striking: ninja.striking
        },

        Box {
            id: rightStrikeSensor
            x: target.width
            y: 0
            width: ninja.striking && ninja.facingRight ? target.width * .6 : 0
            height: target.height - 10

            sensor: true
            categories: ninja.striking ? Global.kActor : Global.kIntangible

            readonly property string type: "right_attack"
            readonly property bool striking: ninja.striking
        }
    ]

    Sprite {
        id: sprite
        animation: "idle"
        horizontalMirror: ninja.facingLeft
        //x: animation == "attack" && ninja.facingLeft ? -30 : 0
        x: -ninja.width / 2
        y: animation == "slide" ? -ninja.height / 2 : 0
        width: ninja.width

        animations: [
            SpriteAnimation {
                name: "idle"
                source: ninja.fileLocation + "idle.png"
                frames: 10
                duration: 500
                loops: Animation.Infinite

                //onFinished: console.log("SPRITE_ANIMATION: ", name, " done")
            },

            SpriteAnimation {
                name: "crouch"
                source: ninja.fileLocation + "crouch.png"
                frames: 10
                duration: 500
                loops: Animation.Infinite
            },

            SpriteAnimation {
                name: "run"
                source: ninja.fileLocation + "run.png"
                frames: 8
                duration: 500
                loops: Animation.Infinite
                inverse: ninja.facingLeft

                //onFinished: console.log("SPRITE_ANIMATION: ", name, " done")
            },

            SpriteAnimation {
                name: "climb"
                source: ninja.fileLocation + "climb.png"
                frames: 10
                duration: 300
                loops: Animation.Infinite
                inverse: ninja.facingDown

                //onFinished: console.log("SPRITE_ANIMATION: ", name, " done")
            },

            SpriteAnimation {
                name: "cling"
                source: ninja.fileLocation + "cling.png"
                frames: 2
                duration: 100
                loops: Animation.Infinite

                //onFinished: console.log("SPRITE_ANIMATION: ", name, " done")
            },

            SpriteAnimation {
                name: "slide"
                source: ninja.fileLocation + "slide.png"
                frames: 10
                duration: 1000
                loops: 1
                inverse: ninja.facingLeft

                onFinished: {
                    //console.log("SPRITE_ANIMATION: ", name, " done")
                    ninja.slidingDone = true;

                    if(sprite.animation == name)
                        ninja.setAnimation("idle");

                    ninja.linearVelocity = Qt.point(0, 0);
                }
            },

            SpriteAnimation {
                name: "jump_attack"
                source: ninja.fileLocation + "jump_attack.png"
                frames: 10
                duration: 1400
                loops: 1
                inverse: ninja.facingLeft

                onFrameChanged: {
                    if(frame == frames / 2)
                        ninja.striking = true;
                }

                onFinished: {
                    //console.log("SPRITE_ANIMATION: ", name, " done")
                    ninja.striking = false;
                }
            },

            SpriteAnimation {
                name: "hover"
                source: ninja.fileLocation + "glide.png"
                frames: 10
                duration: 500
                loops: Animation.Infinite
                inverse: ninja.facingLeft

//                onFrameChanged: {
//                    console.log("This can go on forever!!! ", running)
//                }

                onFinished: ninja.hovering = false;
                //onFinished: console.log("SPRITE_ANIMATION: ", name, " done")
            },

            SpriteAnimation {
                name: "attack"
                source: ninja.fileLocation + "attack.png"
                frames: 7
                duration: 500
                loops: 1
                inverse: ninja.facingLeft

                onFrameChanged: {
                    if(frame == frames / 2)
                        ninja.striking = true;
                }

                onFinished: {
                    if(sprite.animation == name)
                        ninja.setAnimation("idle");

                    ninja.striking = false;
                    //console.log(name, "done")
                }
            },

            SpriteAnimation {
                name: "crouch_attack"
                source: ninja.fileLocation + "crouchattack.png"
                frames: 8
                loops: 1
                duration: 500

                onFinished: ninja.setAnimation(privateProperties.crouchPressed ? "crouch" : "idle");
            },

            SpriteAnimation {
                name: "throw"
                source: ninja.fileLocation + "throw.png"
                frames: 6
                loops: 1
                duration: 250
                //inverse: ninja.facingLeft

                onFrameChanged: {
                    if(frame == frames / 2) {
                        createKunai();

                        if(totalKunaiCollected > 0)
                            totalKunaiCollected--;
                    }
                }

                onFinished: {
                    //console.log("SPRITE_ANIMATION: ", name, " done")

                    throwSound.play();
                    if(sprite.animation == name)
                        ninja.setAnimation("idle");
                }
            },

            SpriteAnimation {
                name: "rise"
                source: ninja.fileLocation + "rising.png"
                frames: 5
                duration: 1000
                loops: 1

                onFinished: {
                    //console.log("SPRITE_ANIMATION: ", name, " done")
                    ninja.jumping = false;
                    ninja.facingDown = false;

                    if(ninja.airborne && sprite.animation == name)
                        ninja.setAnimation("fall");
                }
            },

            SpriteAnimation {
                name: "fall"
                source: ninja.fileLocation + "falling.png"
                frames: 5
                duration: 500
                loops: 1
                //inverse: ninja.facingLeft

                onFinished: {
                    //console.log("SPRITE_ANIMATION: ", name, " done")
                    ninja.facingDown = true;

                    if(ninja.airborne && sprite.animation == name)
                        ninja.setAnimation("freefall");
                }
            },

            SpriteAnimation {
                name: "freefall"
                source: ninja.fileLocation + "freefall.png"
                frames: 2
                duration: 2000
                loops: Animation.Infinite
                inverse: ninja.facingLeft

                onFrameChanged: {
                    ninja.facingDown = true;
                }

                onFinished: {
                    //console.log("SPRITE_ANIMATION: ", name, " done")
                    ninja.facingDown = true;
                }
            },

            SpriteAnimation {
                name: "die"
                source: ninja.fileLocation + "die.png"
                frames: 10
                duration: 1000
                loops: 1

                onFinished: {
                    //console.log("SPRITE_ANIMATION: ", name, " done")
                    if(sprite.animation == name)
                        ninja.setAnimation("dead");
                }
            },

            SpriteAnimation {
                name: "dead"
                source: ninja.fileLocation + "dead.png"
                frames: 2
                duration: 2000
                loops: Animation.Infinite

                //onFinished: console.log("SPRITE_ANIMATION: ", name, " done")
            },

            SpriteAnimation {
                name: "hurt"
                source: ninja.fileLocation + "hurt.png"
                frames: 8 // 2
                duration: 1000
                loops: 1

                onFinished: {
                    //console.log("SPRITE_ANIMATION: ", name, " done")
                    if(sprite.animation == name) {
                        if(healthStatus <= 0)
                            ninja.setAnimation("die");
                        else
                            ninja.setAnimation("idle");
                    }

                    ninja.hurting = false;
                }
            }
        ]

        onAnimationChanged: {
            //console.log("Ninja animation: ", animation)
            ninja.striking = false;
            if(sprite.animation != "hurt")
                ninja.hurting = false;
        }
    }

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
            if (fixture.categories & Global.kEnemy && fixture.type === "main_body") {
            }
        }

        function cast() {
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

        onTriggered: {
            ninja.setAnimation("freefall");
        }
    }

    Timer {
        id: rCrouchTimer
        interval: 200
        repeat: true
        triggeredOnStart: true

        onTriggered: {
            ninja.setAnimation("crouch");
            console.log("Amen!!!");
        }
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

        onPlayingChanged: {
            if(!playing)
                source = getRandomSource();
        }

        function getRandomSource() {
            return sourceList[Math.floor(Math.random() * sourceList.length)];
        }
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

        ninja.x -= ninja.xStep
        ninja.facingLeft = true

        if(ninja.clinging)
            return;
        if(ninja.hovering)
            return;

        if(!ninja.airborne) {
            ninja.running = true;
            //console.log("Calling run!")
            ninja.setAnimation("run");
        }
        else {
            ninja.running = false;
            if(sprite.animation != "rise" || sprite.animation != "fall")
                ninja.setAnimation("freefall");
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
            ninja.running = true;
            ninja.setAnimation("run");
        }
        else {
            ninja.running = false;
            if(sprite.animation != "rise" || sprite.animation != "fall")
                ninja.setAnimation("freefall");
        }
    }

    function stopMovingLeft() {
        if(ninja.dead)
            return;

        rMoveLeftTimer.stop()
        ninja.facingLeft = true;
        ninja.running = false;

        if(ninja.clinging)
            return;
        if(ninja.inHoverArea && !privateProperties.collidingWithGround)
            return;

        if(!ninja.airborne && !ninja.hurting)
            ninja.setAnimation("idle");
    }

    function stopMovingRight() {
        if(ninja.dead)
            return;

        rMoveRightTimer.stop();
        ninja.facingLeft = false;
        ninja.running = false;

        if(ninja.clinging)
            return;
        if(ninja.inHoverArea && !privateProperties.collidingWithGround)
            return;

        if(!ninja.airborne && !ninja.hurting)
            ninja.setAnimation("idle");
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
        if(!privateProperties.collidingWithGround)
            return;

        if(ninja.wearingDisguise)
            toggleDisguise();

        if(sprite.animation == "idle" || ninja.running/*sprite.animation == "run"*/)
            ninja.setAnimation("rise");
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
            ninja.setAnimation("crouch");

        privateProperties.crouchPressed = true;
    }

    function stopCrouching() {
        ninja.setAnimation("idle");
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
            ninja.setAnimation("hover");
            ninja.facingDown = false;
            //privateProperties.collidingWithGround = false;
            ninja.hovering = true;
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
        ninja.facingDown = true;
        ninja.hovering = false;
        hoveringFreefallDelayTimer.restart();
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

        ninja.setAnimation("slide");

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
        if(ninja.linearVelocity == Qt.point(0, 0))
            ninja.applyLinearImpulse(Qt.point(0, -ninja.getMass() * 3), ninja.getWorldCenter());

        ninja.climbing = true;
        ninja.facingDown = false;
        ninja.setAnimation("climb");
    }

    function rClimbDown() {
        if(Global.gameWindow.paused)
            return;
        if(ninja.linearVelocity == Qt.point(0, 0))
            ninja.applyLinearImpulse(Qt.point(0, ninja.getMass() * 3), ninja.getWorldCenter());
        ninja.climbing = true;
        ninja.facingDown = true;
        ninja.setAnimation("climb");
    }

    function stopClimbingUp() {
        if(ninja.dead)
            return;
        if(!ninja.isClinging())
            return;

        rClimbUpTimer.stop();
        ninja.linearVelocity = Qt.point(0, 0);
        ninja.setAnimation("cling");
    }

    function stopClimbingDown() {
        if(ninja.dead)
            return;
        if(!ninja.isClinging())
            return;

        rClimbDownTimer.stop();
        ninja.linearVelocity = Qt.point(0, 0);
        ninja.setAnimation("cling");
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

        if(wearingDisguise)
            toggleDisguise();
        if(ninja.airborne)
            ninja.setAnimation("jump_attack");
        if(ninja.crouching)
            ninja.setAnimation("crouch_attack");
        else
            ninja.setAnimation("attack");

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
        if(totalKunaiCollected == 0) {
            dryFireSound.play();
            return;
        }
        if(wearingDisguise)
            toggleDisguise();

        ninja.setAnimation("throw");
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
        if(ninja.inDisguiseRange)
            ninja.toggleDisguise();
        else if(ninja.inInfoRange)
            ninja.displayMessage();
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


    function isClinging() {
        return ninja.clinging;
    }

    function isInHoverArea() {
        return ninja.inHoverArea;
    }

    function isFacingLeft() {
        return ninja.facingLeft;
    }

    function isFacingRight() {
        return ninja.facingRight;
    }

    function isFacingUp() {
        return ninja.facingUp;
    }

    function isFacingDown() {
        return ninja.facingDown;
    }

    function isAirborne() {
        return ninja.airborne;
    }

    function receivePain() {
        if(ninja.dead)
            return;

        ninja.hurting = true;
        ninja.setAnimation("hurt");
        linearVelocity = Qt.point(0, 0);
    }

    function stun(sender) {
        privateProperties.depleteHealth(.4, sender);
        ninja.receivePain();
        ninja.stopHovering();
    }

    function addCoin() {
        totalCoinsCollected++;
    }

    function addKunai() {
        totalKunaiCollected++;
    }

    function addKey(color) {
        switch(color) {
        case "yellow":
            totalYellowKeysCollected++;
            break;
        case "red":
            totalRedKeysCollected++;
            break;
        case "green":
            totalGreenKeysCollected++;
            break;
        default:
            totalBlueKeysCollected++;
            break;
        }
    }

    function dropKey(color) {
        switch(color) {
        case "yellow":
            if(totalYellowKeysCollected > 0)
                totalYellowKeysCollected--;
            break;
        case "red":
            if(totalRedKeysCollected > 0)
                totalRedKeysCollected--;
            break;
        case "green":
            if(totalGreenKeysCollected > 0)
                totalGreenKeysCollected--;
            break
        default:
            if(totalBlueKeysCollected > 0)
                totalBlueKeysCollected--;
            break;
        }
    }

    function comment() {
        commentSound.play();
    }

    function stopAllActions() {
        ninja.stopMovingLeft();
        ninja.stopMovingRight();
        ninja.stopHovering();
        ninja.stopClimbingUp();
        ninja.stopClimbingDown();
        ninja.stopCrouching();
    }

    function setAnimation(name) {
        var oldName = sprite.animation;

        switch(name) {
        case "attack":
            if(privateProperties.collidingWithGround)
                sprite.animation = name;
            else
                sprite.animation = "jump_attack";
            break;
        case "climb":
            sprite.animation = name;
            break;
        case "cling":
            sprite.animation = name;
            break;
        case "crouch":
            sprite.animation = name;
            break;
        case "dead":
            sprite.animation = name;
            break;
        case "die":
            sprite.animation = name;
            break;
        case "fall":
            sprite.animation = name;
            break;
        case "freefall":
            if(ninja.dead)
                sprite.animation = "dead"
            else if(privateProperties.collidingWithGround)
                sprite.animation = "idle"
            else
                sprite.animation = name;
            break;
        case "hover":
            sprite.animation = name;
            break;
        case "hurt":
            sprite.animation = name;
            break;
        case "jump_attack":
            if(!privateProperties.collidingWithGround)
                sprite.animation = name;
            else
                sprite.animation = "attack";
            break;
        case "jump_throw":
            if(!privateProperties.collidingWithGround)
                sprite.animation = name;
            else
                sprite.animation = "throw";
            break;
        case "idle":
            if(privateProperties.collidingWithGround)
                sprite.animation = name;
            else
                sprite.animation = "freefall";
            break;
        case "rise":
            sprite.animation = name;
            break;
        case "run":
            if(privateProperties.collidingWithGround)
                sprite.animation = name;
            else
                sprite.animation = "freefall";
            break;
        case "slide":
            sprite.animation = name;
            break
        case "throw":
            if(privateProperties.collidingWithGround)
                sprite.animation = name;
            else
                sprite.animation = "jump_throw";
            break
        case "crouch_attack":
            sprite.animation = name;
            break;
        default:
            console.log("UNHANDLED ANIMATION CASE:", name)
            sprite.animation = name;
            break
        }
    }

    function goToDoor() {
        if(nextDoorLocation == Qt.point(-1, -1))
            return;

        ninja.x = nextDoorLocation.x;
        ninja.y = nextDoorLocation.y;
        teleported();
    }

    onDeadChanged: {
        if(wearingDisguise)
            toggleDisguise();

        rMoveLeftTimer.stop();
        rMoveRightTimer.stop();
        ninja.setAnimation("die");
        ninja.gravityScale = 1;
        healthStatus = 0;
        console.log("Actor: I'm dead!!!");
        selfDestruct();
    }

    Component.onCompleted: ninja.setAnimation("freefall");
}

