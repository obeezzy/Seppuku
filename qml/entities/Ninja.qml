import QtQuick 2.9
import QtMultimedia 5.9
import Bacon2D 1.0
import Seppuku 1.0
import QtQml.StateMachine 1.0 as DSM
import "../singletons"

EntityBase {
    id: ninja
    entityType: "ninja"

    // Face forward or backwards?
    property alias faceForward: sprite.horizontalMirror
    // Name of hero
    property string name: "tomahawk"
    // Current scene
    readonly property Scene scene: parent
    // Location of sprites
    readonly property string filePrefix: Global.paths.images + "hero/" + name + "_"
    // What's the distance moved with each step
    readonly property int xStep: 8
    // Where is the next door location
    property point nextDoorLocation: Qt.point(-1, -1)

    readonly property bool airborne: privateProperties.groundContactCount === 0

    readonly property bool hurting: false
    readonly property bool clinging: false
    readonly property bool climbing: false

    readonly property string deathCause: privateProperties.deathCause
    readonly property real healthStatus: privateProperties.healthStatus
    readonly property bool inHoverArea: privateProperties.hoverAreaContactCount > 0
    readonly property int totalCoinsCollected: privateProperties.totalCoinsCollected
    readonly property int totalKunaiCollected: privateProperties.totalKunaiCollected
    readonly property int totalBlueKeysCollected: privateProperties.totalBlueKeysCollected
    readonly property int totalYellowKeysCollected: privateProperties.totalYellowKeysCollected
    readonly property int totalRedKeysCollected: privateProperties.totalRedKeysCollected
    readonly property int totalGreenKeysCollected: privateProperties.totalGreenKeysCollected

    signal selfDestruct
    signal infoRequested
    signal utilized

    x: Global.checkpointAvailable ? Global.checkpoint.pos.x
                                  : ninja.TiledObjectGroup.instance.getProperty("x")
    y: Global.checkpointAvailable ? Global.checkpoint.pos.y
                                  : ninja.TiledObjectGroup.instance.getProperty("y")
    faceForward: Global.checkpointAvailable ? Global.checkpoint.face_forward
                                            : TiledObjectGroup.instance.getProperty("face_forward") || true

    width: 30
    height: 60
    bodyType: Body.Dynamic
    sleepingAllowed: false
    fixedRotation: true
    bullet: true
    z: Utils.zHero

    EntityManager { id: entityManager }

    QtObject {
        id: privateProperties

        property int ladderContactCount: 0
        property int groundContactCount: 0
        property int hoverAreaContactCount: 0

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

        // Are there fixed camera positions for this area?
        property bool inCameraMomentRange: false

        // Where should the camera be placed?
        property var cameraMoment: null

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
            }

            ouchSound.play();
        }
    }

    Item {
        id: actions

        property QtObject keys: QtObject {
            property bool upPressed: false
            property bool downPressed: false
            property bool leftPressed: false
            property bool rightPressed: false
            property bool attackPressed: false
            property bool tossPressed: false
            property bool usePressed: false
        }

        signal goLeft(string eventType)
        signal goRight(string eventType)
        signal goUp(string eventType)
        signal goDown(string eventType)
        signal attack(string eventType)
        signal toss(string eventType)
        signal use(string eventType)

        Connections {
            onGoLeft: {
                actions.keys.leftPressed = eventType === "press";
                if (eventType === "press")
                    sprite.horizontalMirror = true;
            }
            onGoRight: {
                actions.keys.rightPressed = eventType === "press";
                if (eventType === "press")
                    sprite.horizontalMirror = false;
            }
            onGoUp: actions.keys.upPressed = eventType === "press";
            onGoDown: actions.keys.downPressed = eventType === "press";
        }
    }

    fixtures: [
        Box {
            id: mainBody
            friction: .001
            density: .4
            restitution: 0

            x: privateProperties.leftBoxMargin
            width: target.width - privateProperties.rightBoxMargin
            height: target.height
            categories: Utils.kHero
            collidesWith: Utils.kAll

            readonly property bool exposed: true //ninja.exposed
            readonly property string type: "main_body"
            readonly property bool dead: false

            onBeginContact: {

            }

            onEndContact: {

            }
        },

        Box {
            id: headSensor
            y: -height
            x: privateProperties.leftBoxMargin
            width: target.width - privateProperties.rightBoxMargin
            height: 1
            sensor: true
            categories: Utils.kHero
            collidesWith: Utils.kObstacle

            readonly property string type: "head"

            onBeginContact: {
                if(other.categories === (Utils.kObstacle | Utils.kGround)) {
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
            x: target.width * .3
            y: target.height
            width: target.width - target.width * .3
            height: 1
            sensor: true
            categories: Utils.kHero
            collidesWith: Utils.kGroundTop

            readonly property string type: "ground"

            onBeginContact: {
                if(other.categories & Utils.kGroundTop) {
                    privateProperties.groundContactCount++;
                }
            }

            onEndContact: {
                if(other.categories & Utils.kGroundTop)
                    privateProperties.groundContactCount--;
            }
        }
    ]

    AnimatedSprite {
        id: sprite
        y: {
            switch (animation) {
            case "attack_main": -10; break;
            case "run": -8; break;
            case "slide": -40; break;
            case "cling":
            case "climb": -6; break;
            case "crouch": -12; break;
            case "crouch_attack": -12; break;
            default: -8; break;
            }
        }

        anchors.horizontalCenter: parent.horizontalCenter
        animation: ninja.airborne ? "freefall" : "idle"
        spriteSheet: SpriteSheet {
            source: Global.paths.images + "hero/" + ninja.name + ".png"
            horizontalFrameCount: 10
            verticalFrameCount: 17
        }

        animations: [
            SpriteAnimation {
                name: "attack_main"
                spriteStrip: SpriteStrip {
                    finalFrame: 6
                    frameY: 0
                }
                duration: 500
                loops: 1
                onFinished: {
                    if (actions.keys.leftPressed || actions.keys.rightPressed)
                        sprite.animation = "run";
                    else
                        sprite.animation = "idle";
                }
            },

            SpriteAnimation {
                name: "attack_secondary"
                spriteStrip: SpriteStrip {
                    finalFrame: 7
                    frameY: frameHeight
                }
                duration: 500
                loops: Animation.Infinite
            },

            SpriteAnimation {
                name: "climb"
                spriteStrip: SpriteStrip {
                    finalFrame: 6
                    frameY: 2 * frameHeight
                }
                duration: 500
                loops: Animation.Infinite
            },

            SpriteAnimation {
                name: "crouch"
                spriteStrip: SpriteStrip {
                    frameY: 4 * frameHeight
                }
                duration: 500
                loops: Animation.Infinite
            },

            SpriteAnimation {
                name: "crouch_attack"
                spriteStrip: SpriteStrip {
                    finalFrame: 7
                    frameY: 3 * frameHeight
                }
                duration: 500
                loops: 1
                onFinished: sprite.animation = "crouch";
            },

            SpriteAnimation {
                name: "crouch_throw"
                spriteStrip: SpriteStrip {
                    finalFrame: 5
                    frameY: 5 * frameHeight
                }
                duration: 500
                loops: 1
            },

            SpriteAnimation {
                name: "die"
                spriteStrip: SpriteStrip {
                    frameY: 6 * frameHeight
                    frameWidth: .08102981029 * sprite.spriteSheet.sourceSize.width
                }
                duration: 500
                loops: 1
            },

            SpriteAnimation {
                name: "hover"
                spriteStrip: SpriteStrip {
                    frameY: 7 * frameHeight
                }
                duration: 500
                loops: Animation.Infinite
            },

            SpriteAnimation {
                name: "hurt"
                spriteStrip: SpriteStrip {
                    finalFrame: 7
                    frameY: 8 * frameHeight
                }
                duration: 500
                loops: 1
                onFinished: sprite.animation = "idle";
            },

            SpriteAnimation {
                name: "idle"
                spriteStrip: SpriteStrip {
                    frameY: 9 * frameHeight
                }
                duration: 500
                loops: Animation.Infinite
            },

            SpriteAnimation {
                name: "jump"
                spriteStrip: SpriteStrip {
                    frameY: 11 * frameHeight
                }
                duration: 800
                loops: 1
                onFinished: sprite.animation = "freefall";
            },

            SpriteAnimation {
                name: "jump_attack"
                spriteStrip: SpriteStrip {
                    frameY: 10 * frameHeight
                    finalFrame: 6
                }
                duration: 500
                loops: 1

                onFinished: {
                    if (ninja.airborne)
                        sprite.animation = "freefall";
                    else
                        sprite.animation = (actions.keys.leftPressed || actions.keys.rightPressed) ? "run" : "idle";
                }
            },

            SpriteAnimation {
                name: "jump_throw"
                spriteStrip: SpriteStrip {
                    finalFrame: 5
                    frameY: 12 * frameHeight
                }
                duration: 500
                loops: 1

                onFinished: sprite.animation = "freefall";
            },


            SpriteAnimation {
                name: "run"
                spriteStrip: SpriteStrip {
                    frameY: 13 * frameHeight
                    finalFrame: 7
                }
                duration: 500
                loops: Animation.Infinite
            },

            SpriteAnimation {
                name: "slide"
                spriteStrip: SpriteStrip {
                    frameY: 14 * frameHeight
                }
                duration: 500
                loops: Animation.Infinite
            },

            SpriteAnimation {
                name: "throw"
                spriteStrip: SpriteStrip {
                    finalFrame: 5
                    frameY: 15 * frameHeight
                }
                duration: 500
                loops: 1
            },

            SpriteAnimation {
                name: "walk"
                spriteStrip: SpriteStrip {
                    frameY: 16 * frameHeight
                }
                duration: 500
                loops: Animation.Infinite
            },

            SpriteAnimation {
                name: "freefall"
                spriteStrip: SpriteStrip {
                    frameY: 11 * frameHeight
                    initialFrame: 9
                }
                duration: 250
                loops: Animation.Infinite
            },

            SpriteAnimation {
                name: "rise"
                spriteStrip: SpriteStrip {
                    frameY: 7 * frameHeight
                    finalFrame: 8
                }
                duration: 500
                loops: 1
            },

            SpriteAnimation {
                name: "dead"
                spriteStrip: SpriteStrip {
                    frameY: 6 * frameHeight
                    frameWidth: .08102981029 * sprite.spriteSheet.sourceSize.width
                    initialFrame: 9
                }
                duration: 500
                loops: Animation.Infinite
            },

            SpriteAnimation {
                name: "cling"
                spriteStrip: SpriteStrip {
                    initialFrame: 9
                    frameY: 2 * frameHeight
                }
                duration: 500
                loops: Animation.Infinite
            }
        ]
    }

    DSM.StateMachine {
        id: stateMachine
        running: true
        childMode: DSM.State.ParallelStates

        DSM.State {
            id: directionState
            initialState: actions.keys.leftPressed ? leftDirectionState
                                                     : actions.keys.rightPressed ? rightDirectionState
                                                                                   : noDirectionState

            DSM.State {
                id: leftDirectionState
                onEntered: {
                    if (!crouchState.active && !crouchAttackState.active)
                        ninja.linearVelocity.x = -ninja.xStep;
                }

                DSM.SignalTransition {
                    targetState: rightDirectionState
                    signal: actions.goRight
                    guard: eventType === "press"
                }

                DSM.SignalTransition {
                    targetState: noDirectionState
                    signal: actions.goLeft
                    guard: eventType === "release"
                }
            }

            DSM.State {
                id: rightDirectionState
                onEntered: {
                    if (!crouchState.active && !crouchAttackState.active)
                        ninja.linearVelocity.x = ninja.xStep;
                }

                DSM.SignalTransition {
                    targetState: leftDirectionState
                    signal: actions.goLeft
                    guard: eventType === "press"
                }

                DSM.SignalTransition {
                    targetState: noDirectionState
                    signal: actions.goRight
                    guard: eventType === "release"
                }
            }

            DSM.State {
                id: noDirectionState
                onEntered: ninja.linearVelocity.x = 0;

                DSM.SignalTransition {
                    targetState: leftDirectionState
                    signal: actions.goLeft
                    guard: eventType === "press"
                }

                DSM.SignalTransition {
                    targetState: rightDirectionState
                    signal: actions.goRight
                    guard: eventType === "press"
                }
            }
        }

        DSM.State {
            id: spriteState
            initialState: !ninja.airborne ? idleState : freefallState

            DSM.State {
                id: idleState

                onEntered: {
                    console.log("IDLE");
                    sprite.animation = "idle";
                }

                DSM.SignalTransition {
                    targetState: runState
                    signal: actions.goLeft
                    guard: eventType === "press"
                }

                DSM.SignalTransition {
                    targetState: runState
                    signal: actions.goRight
                    guard: eventType === "press"
                }

                DSM.SignalTransition {
                    targetState: jumpState
                    signal: actions.goUp
                    guard: eventType === "press"
                }

                DSM.SignalTransition {
                    targetState: crouchState
                    signal: actions.goDown
                    guard: eventType === "press"
                }

                DSM.SignalTransition {
                    targetState: attackMainState
                    signal: actions.attack
                    guard: eventType === "press"
                }
            }

            DSM.State {
                id: runState
                onEntered: {
                    console.log("RUN");
                    sprite.animation = "run";
                }

                DSM.SignalTransition {
                    targetState: idleState
                    signal: actions.goLeft
                    guard: eventType === "release" && !actions.keys.rightPressed
                }

                DSM.SignalTransition {
                    targetState: idleState
                    signal: actions.goRight
                    guard: eventType === "release" && !actions.keys.leftPressed
                }

                DSM.SignalTransition {
                    targetState: jumpState
                    signal: actions.goUp
                    guard: eventType === "press"
                }

                DSM.SignalTransition {
                    targetState: freefallState
                    signal: ninja.onAirborneChanged
                    guard: ninja.airborne
                }
            }

            DSM.State {
                id: jumpState
                onEntered: {
                    console.log("JUMP");
                    sprite.animation = "jump";
                    ninja.applyLinearImpulse(Qt.point(0, -ninja.getMass() * 8), ninja.getWorldCenter());
                }

                DSM.SignalTransition {
                    targetState: actions.keys.leftPressed || actions.keys.rightPressed ? runState : idleState
                    signal: ninja.onAirborneChanged
                    guard: !ninja.airborne
                }

                DSM.SignalTransition {
                    targetState: jumpAttackState
                    signal: actions.onAttack
                    guard: ninja.airborne
                }
            }

            DSM.State {
                id: jumpAttackState

                onEntered: {
                    sprite.animation = "jump_attack"
                    console.info("JUMP ATTACK");
                }

                DSM.SignalTransition {
                    targetState: freefallState
                    signal: sprite.onAnimationChanged
                    guard: sprite.animation === "freefall"
                }

                DSM.SignalTransition {
                    targetState: idleState
                    signal: ninja.onAirborneChanged
                    guard: !ninja.airborne
                }

                DSM.SignalTransition {
                    targetState: runState
                    signal: sprite.onAnimationChanged
                    guard: !ninja.airborne && (actions.keys.leftPressed || actions.keys.rightPressed)
                }
            }

            DSM.State {
                id: freefallState
                onEntered: {
                    console.log("FREEFALL");
                    sprite.animation = "freefall";
                }

                DSM.SignalTransition {
                    targetState: actions.keys.leftPressed || actions.keys.rightPressed ? runState : idleState
                    signal: ninja.onAirborneChanged
                    guard: !ninja.airborne
                }

                DSM.SignalTransition {
                    targetState: jumpAttackState
                    signal: actions.onAttack
                    guard: ninja.airborne
                }
            }

            DSM.State {
                id: crouchState
                onEntered: {
                    console.log("CROUCH");
                    sprite.animation = "crouch";
                }

                DSM.SignalTransition {
                    targetState: idleState
                    signal: actions.goDown
                    guard: eventType === "release"
                }

                DSM.SignalTransition {
                    targetState: crouchAttackState
                    signal: actions.attack
                    guard: eventType === "press"
                }
            }

            DSM.State {
                id: crouchAttackState
                onEntered: {
                    console.log("CROUCH ATTACK");
                    sprite.animation = "crouch_attack";
                }

                DSM.SignalTransition {
                    targetState: crouchState
                    signal: sprite.onAnimationChanged
                    guard: sprite.animation === "crouch"
                }

                DSM.SignalTransition {
                    targetState: idleState
                    signal: actions.goDown
                    guard: eventType === "release"
                }
            }

            DSM.State {
                id: attackMainState
                onEntered: {
                    console.log("PRIMARY ATTACK");
                    sprite.animation = "attack_main";
                }

                DSM.SignalTransition {
                    targetState: idleState
                    signal: sprite.onAnimationChanged
                    guard: sprite.animation === "idle"
                }

                DSM.SignalTransition {
                    targetState: runState
                    signal: sprite.onAnimationChanged
                    guard: sprite.animation === "run"
                }
            }
        }
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

    // Allow hero to pass through one-way platforms
    Connections {
        target: ninja.world
        onPreSolve: {
            if (contact.fixtureA.categories & Utils.kGround && contact.fixtureA.type === "one_way_platform") {
                if (ninja.isRising())
                    contact.enabled = false;

            } else if (contact.fixtureB.categories & Utils.kGround && contact.fixtureB.type === "one_way_platform") {
                if (ninja.isRising())
                    contact.enabled = false;
            }
        }
    }

    /************************************** FUNCTIONS ************************************************/
    function handleEvent(name, type) {
        if(Global.gameWindow.paused)
            return;

        console.log("Event:", name, type);
        switch (name) {
        case "left":
            actions.goLeft(type);
            break;
        case "right":
            actions.goRight(type);
            break;
        case "up":
            actions.goUp(type);
            break;
        case "down":
            actions.goDown(type);
            break;
        case "attack":
            actions.attack(type);
            break;
        }
    }

    function isRising() {
        return ninja.linearVelocity.y < 0;
    }

    function isFalling() {
        return ninja.linearVelocity.y > 0;
    }

    function isMovingLeft() {
        return ninja.linearVelocity.x < 0;
    }

    function isMovingRight() {
        return ninja.linearVelocity > 0;
    }

    function isMoving() {
        return ninja.isMovingLeft() || ninja.isMovingRight();
    }

    function isStationary() {
        return !ninja.isMoving();
    }

    /************************* END FUNCTIONS *********************************************/
}

