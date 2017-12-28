import QtQuick 2.9
import QtMultimedia 5.9
import Bacon2D 1.0
import Seppuku 1.0
import "../singletons"

EntityBase {
    id: ninja
    width: 30
    height: ninja.standingHeight
    bodyType: Body.Dynamic
    sleepingAllowed: false
    fixedRotation: true
    bullet: true
    z: ninja.wearingDisguise ? Utils.zHeroDisguised : Utils.zHero

    signal selfDestruct
    signal disguised(bool putOn)
    signal infoRequested
    signal utilized(string type)
    signal teleported // After you have moved through a door

    // Where is the next door location
    property point nextDoorLocation: Qt.point(-1, -1)
    // Name of hero
    property string name: "tomahawk"

    // Current scene
    readonly property Scene scene: parent
    // Location of sprites
    readonly property string filePrefix: Global.paths.images + "hero/" + name + "_"
    // What's the distance moved with each step
    readonly property int xStep: 8

    readonly property bool inHoverArea: privateProperties.hoverAreaContactCount > 0

    readonly property bool facingRight: privateProperties.horizontalDirectionState == "right"
    readonly property bool facingLeft: privateProperties.horizontalDirectionState == "left"
    readonly property bool facingUp: privateProperties.verticalDirectionState == "up"
    readonly property bool facingDown: privateProperties.verticalDirectionState == "down"

    readonly property real standingHeight: 60
    readonly property real crouchingHeight: 38

    readonly property string deathCause: privateProperties.deathCause
    readonly property real healthStatus: privateProperties.healthStatus

    readonly property string verticalDirectionState: privateProperties.verticalDirectionState
    readonly property string horizontalDirectionState: privateProperties.horizontalDirectionState
    readonly property string actionState: privateProperties.actionState
    readonly property string altitudeState: privateProperties.altitudeState
    readonly property string rangeState: privateProperties.rangeState

    readonly property int totalCoinsCollected: privateProperties.totalCoinsCollected
    readonly property int totalKunaiCollected: privateProperties.totalKunaiCollected
    readonly property int totalBlueKeysCollected: privateProperties.totalBlueKeysCollected
    readonly property int totalYellowKeysCollected: privateProperties.totalYellowKeysCollected
    readonly property int totalRedKeysCollected: privateProperties.totalRedKeysCollected
    readonly property int totalGreenKeysCollected: privateProperties.totalGreenKeysCollected

    // Is the player on the ground
    readonly property bool grounded: privateProperties.groundContactCount > 0 && privateProperties.actionState != "clinging"
    // Am I on the ground?
    readonly property bool airborne: !ninja.grounded

    // Can the hero be seen by the enemy
    readonly property bool exposed: !ninja.wearingDisguise
    readonly property bool wearingDisguise: privateProperties.wearingDisguise

    readonly property bool inDisguiseRange: privateProperties.inDisguiseRange
    readonly property bool inInfoRange: privateProperties.inInfoRange
    readonly property bool inLeverRange: privateProperties.inLeverRange
    readonly property bool inDoorRange: privateProperties.inDoorRange
    readonly property bool inCameraMomentRange: privateProperties.inCameraMomentRange

    readonly property var cameraMoment: privateProperties.cameraMoment

    QtObject {
        id: privateProperties

        property string verticalDirectionState: "down"
        property string horizontalDirectionState: "right"
        property string actionState: "idle"
        property string altitudeState: ""
        property string rangeState: ""
        property var pressedKeys: {
            "up": false,
                    "down": false,
                    "left": false,
                    "right": false,
                    "attack": false,
                    "throw": false,
                    "use": false
        }

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
                privateProperties.actionState = "dying";
            }

            ouchSound.play();
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
            collidesWith: {
                Utils.kGround | Utils.kWall | Utils.kCollectible |
                            Utils.kEnemy | Utils.kLadder | Utils.kCovert |
                            Utils.kObstacle | Utils.kInteractive | Utils.kHoverArea |
                            Utils.kLava | Utils.kCameraMoment
            }

            readonly property bool exposed: ninja.exposed
            readonly property string type: "main_body"
            readonly property bool dead: privateProperties.actionState == "dead"

            onBeginContact: {
                if(privateProperties.actionState == "dead")
                    return;
                if(other.categories & Utils.kEnemy) {
                    if(other.type === "main_body") {
                        //console.log("Hero: I collided with the enemy. Ouch!")
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

                    if (privateProperties.actionState == "sliding")
                        ninja.stopSliding();

                    privateProperties.actionState = "clinging";
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
                else if (other.categories & Utils.kCameraMoment) {
                    privateProperties.cameraMoment = other.cameraMoment;
                    privateProperties.inCameraMomentRange = true;
                }
            }

            onEndContact: {
                if(privateProperties.actionState == "dead")
                    return
                if(other.categories & Utils.kLadder) {
                    privateProperties.ladderContactCount--;

                    if(privateProperties.ladderContactCount == 0) {
                        ninja.gravityScale = 1;

                        if (privateProperties.actionState == "clinging" || privateProperties.actionState == "climbing") {
                            if (!ninja.grounded || ninja.isRising() || ninja.isFalling())
                                privateProperties.actionState = "freefall";
                            else
                                privateProperties.actionState = "idle";
                        }
                    }
                }
                else if(other.categories & Utils.kCovert) {
                    privateProperties.inDisguiseRange = false;
                }
                else if(other.categories & Utils.kHoverArea) {
                    privateProperties.hoverAreaContactCount--;

                    if (privateProperties.hoverAreaContactCount == 0) {
                        ninja.stopHovering();
                        hoveringFreefallDelayTimer.stop();
                        if (ninja.airborne)
                            privateProperties.actionState = "freefall";
                        else
                            privateProperties.actionState = "idle";
                    }

                }
                else if(other.categories & Utils.kInteractive) {
                    if(other.type === "info_sign")
                        privateProperties.inInfoRange = false;
                    else if(other.type === "lever")
                        privateProperties.inLeverRange = false;
                }
                else if (other.categories & Utils.kCameraMoment) {
                    console.log("Hero: Camera moment gone!");
                    privateProperties.inCameraMomentRange = false;
                    privateProperties.cameraMoment = null;
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
            categories: Utils.kHero
            collidesWith: Utils.kObstacle

            readonly property string type: "head"

            onBeginContact: {
                if(privateProperties.actionState == "dead")
                    return;

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
                if(privateProperties.actionState == "dead")
                    return;

                if(other.categories & Utils.kGroundTop) {
                    privateProperties.groundContactCount++;

                    if (privateProperties.actionState == "freefall")
                        privateProperties.actionState = "idle";
                }
            }

            onEndContact: {
                if(other.categories & Utils.kGroundTop)
                    privateProperties.groundContactCount--;
            }
        }
    ]

    // Die
    onHealthStatusChanged: {
        if (privateProperties.healthStatus <= 0) {
            if(privateProperties.wearingDisguise)
                ninja.toggleDisguise();

            ninja.stopMovement();
            privateProperties.actionState = "dying";
            ninja.gravityScale = 1;
            privateProperties.healthStatus = 0;
            ninja.selfDestruct();
        }
    }

    onActionStateChanged: {
        if (sprite.animation == "dying" || sprite.animation == "dead")
            return;

        switch (privateProperties.actionState) {
        case "dead":
            sprite.animation = "dead";
            break;
        case "dying":
            sprite.animation = "die";
            break;
        case "hurting":
            sprite.animation = "hurt";
            break;
        case "throwing":
            sprite.animation = "throw";
            break;
        case "primary_attacking":
            sprite.animation = "attack_main";
            break;
        case "crouch_attacking":
            sprite.animation = "crouch_attack";
            break;
        case "jump_attacking":
            sprite.animation = "jump_attack";
            break;
        case "clinging":
            sprite.animation = "cling";
            break;
        case "climbing":
            sprite.animation = "climb";
            break;
        case "running":
            sprite.animation = "run";
            break;
        case "freefall":
            sprite.animation = "freefall";
            break;
        case "sliding":
            sprite.animation = "slide";
            break;
        case "crouching":
            sprite.animation = "crouch";
            break;
        case "rising":
            sprite.animation = "rise";
            break;
        case "hovering":
            sprite.animation = "hover";
            break;
        case "idle":
            sprite.animation = "idle";
            break;
        default:
            console.warn("Unhandled action state, defaulting to idle...");
            sprite.animation = "idle";
            break;
        }

        console.log("Action state:", actionState);
    }

    AnimatedSprite {
        id: sprite

        y: {
            switch (animation) {
            case "attack_main": -10; break;
            case "run": -25; break;
            case "slide": -40; break;
            case "cling":
            case "climb": -6; break;
            case "crouch": -40; break;
            case "crouch_attack": -40; break;
            default: -17; break;
            }
        }

        anchors.horizontalCenter: parent.horizontalCenter
        animation: ninja.airborne ? "freefall" : "idle"
        source: Global.paths.images + "hero/" + ninja.name + ".png"
        horizontalMirror: privateProperties.horizontalDirectionState == "left"
        horizontalFrameCount: 10
        verticalFrameCount: 17

        animations: [
            SpriteAnimation {
                name: "attack_main"
                finalFrame: 6
                frameY: 0
                duration: 500
                loops: 1
                inverse: privateProperties.horizontalDirectionState == "left"

                onFinished: privateProperties.actionState = "idle";
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

                onFinished: {
                    var downPressed = privateProperties.pressedKeys["down"];
                    if (downPressed)
                        privateProperties.actionState = "crouching"
                    else {
                        ninja.increaseHeight();
                        privateProperties.actionState = "idle";
                    }
                }
            },

            SpriteAnimation {
                name: "crouch_throw"
                finalFrame: 5
                frameY: 5 * frameHeight
                duration: 500
                loops: 1

                onFinished: privateProperties.actionState = privateProperties.pressedKeys["down"] ? "crouching" : "idle";
            },

            SpriteAnimation {
                name: "die"
                frameY: 6 * frameHeight
                frameWidth: .08102981029 * sprite.sourceSize.width
                duration: 500
                loops: 1

                onFinished: privateProperties.actionState = "dead";
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
                onFinished: privateProperties.actionState = "idle";
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

                onFinished: privateProperties.actionState = "freefall";
            },

            SpriteAnimation {
                name: "jump_throw"
                finalFrame: 5
                frameY: 12 * frameHeight
                duration: 500
                loops: 1

                onFinished: privateProperties.actionState = "freefall";
            },


            SpriteAnimation {
                name: "run"
                finalFrame: 7
                frameY: 13 * frameHeight
                duration: 500
                loops: Animation.Infinite
                inverse: privateProperties.horizontalDirectionState == "left"
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
                onFinished: privateProperties.actionState = "idle";
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

                onFinished: if (privateProperties.actionState == "rising") privateProperties.actionState = "freefall";
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
            if (fixture.categories & Utils.kEnemy && fixture.type === "main_body") {
            }
        }

        function cast() {
            if(privateProperties.actionState == "dead")
                return;

            scene.rayCast(this, p1, p2);
        }
    }

    /***************************** TIMERS *****************************************/
    Timer {
        id: rMoveLeftTimer
        interval: 50
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if(Global.gameWindow.paused)
                return;

            ninja.linearVelocity.x = privateProperties.actionState == "clinging" ? -ninja.xStep * 1.4 : -ninja.xStep;
            privateProperties.horizontalDirectionState = "left";

            if (privateProperties.actionState != "hovering" && privateProperties.actionState != "clinging") {
                if(!ninja.airborne)
                    privateProperties.actionState = "running"
                else if (privateProperties.actionState != "jump_attacking")
                    privateProperties.actionState = "freefall";
            }
        }
    }

    Timer {
        id: rMoveRightTimer
        interval: 50
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if(Global.gameWindow.paused)
                return;

            ninja.linearVelocity.x = privateProperties.actionState == "clinging" ? ninja.xStep * 1.4: ninja.xStep;
            privateProperties.horizontalDirectionState = "right";

            if (privateProperties.actionState != "hovering" && privateProperties.actionState != "clinging") {
                if (!ninja.airborne)
                    privateProperties.actionState = "running";
                else if (privateProperties.actionState != "jump_attacking")
                    privateProperties.actionState = "freefall";
            }
        }
    }

    // After climb up/down is called, it waits for the hero to move up a bit then stops him
    Timer {
        id: rClimbUpTimer
        interval: 50
        repeat: true
        onTriggered: {
            if(Global.gameWindow.paused)
                return;
            if(privateProperties.actionState == "dead")
                return;

            if (privateProperties.ladderContactCount > 0) {
                var upPressed = privateProperties.pressedKeys["up"];

                if (upPressed) {
                    if(ninja.linearVelocity == Qt.point(0, 0))
                        ninja.applyLinearImpulse(Qt.point(0, -ninja.getMass() * 3), ninja.getWorldCenter());

                    privateProperties.verticalDirectionState = "up";
                    privateProperties.actionState = "climbing";
                } else {
                    ninja.linearVelocity = Qt.point(0, 0);
                    privateProperties.actionState = "clinging";
                }
            }
        }
    }

    Timer {
        id: rClimbDownTimer
        interval: 50
        repeat: true
        onTriggered: {
            if(Global.gameWindow.paused)
                return;
            if(privateProperties.actionState == "dead")
                return;

            if (privateProperties.ladderContactCount > 0) {
                var downPressed = privateProperties.pressedKeys["down"];

                if (downPressed) {
                    if(ninja.linearVelocity == Qt.point(0, 0))
                        ninja.applyLinearImpulse(Qt.point(0, ninja.getMass() * 3), ninja.getWorldCenter());

                    privateProperties.verticalDirectionState = "down";
                    privateProperties.actionState = "climbing";
                } else {
                    ninja.linearVelocity = Qt.point(0, 0);
                    privateProperties.actionState = "clinging";
                }
            }
        }
    }

    Timer {
        id: rHoverTimer
        interval: 50
        repeat: true
        onTriggered: {
            if(Global.gameWindow.paused)
                return;

            var upPressed = privateProperties.pressedKeys["up"];

            if (upPressed) {
                ninja.gravityScale = 0;
                ninja.linearVelocity = Qt.point(0, -5);
                privateProperties.actionState = "hovering";
                privateProperties.verticalDirectionState = "up";
                hoveringFreefallDelayTimer.stop();
            } else {

            }
        }
    }

    Timer {
        id: hoveringFreefallDelayTimer
        interval: 200
        repeat: false
        onTriggered: privateProperties.actionState = "freefall";
    }

    Timer {
        id: attackRayTimer
        interval: 20
        repeat: true
        triggeredOnStart: true
        onTriggered: attackRay.cast();
    }

    // Wait for ninja to reach a certain level while jumping before he starts dropping
    Timer {
        id: jumpTimer
        interval: 100
    }

    /***************************** END TIMERS *****************************************/

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

        privateProperties.pressedKeys[name] = type === "press";
        var downPressed = privateProperties.pressedKeys["down"];
        var leftPressed = privateProperties.pressedKeys["left"];
        var rightPressed = privateProperties.pressedKeys["right"];

        switch (name) {
        case "left":
            if (type === "press") {
                if ((downPressed && leftPressed) || (downPressed && rightPressed))
                    ninja.startSliding();
                else
                    ninja.startMovingLeft();
            } else {
                if (privateProperties.actionState == "sliding" && !((downPressed && leftPressed) || (downPressed && rightPressed)))
                    ninja.stopSliding();

                ninja.stopMovingLeft();
            }
            break;
        case "right":
            if (type === "press") {
                if (privateProperties.actionState == "crouching" && (downPressed && leftPressed) || (downPressed && rightPressed))
                    ninja.startSliding();
                else
                    ninja.startMovingRight();
            } else {
                if (privateProperties.actionState == "sliding" && !((downPressed && leftPressed) || (downPressed && rightPressed)))
                    ninja.stopSliding();

                ninja.stopMovingRight();
            }
            break;
        case "up":
            if (type === "press") {
                if (privateProperties.actionState == "clinging" || privateProperties.actionState == "climbing")
                    ninja.startClimbingUp();
                else if (ninja.inHoverArea)
                    ninja.startHovering();
                else
                    ninja.jump();
            } else {
                if (privateProperties.actionState == "hovering")
                    ninja.stopHovering();
                else if (privateProperties.actionState == "clinging" || privateProperties.actionState == "climbing")
                    ninja.stopClimbingUp();
            }
            break;
        case "down":
            if (type === "press") {
                if (privateProperties.actionState == "clinging" || privateProperties.actionState == "climbing")
                    ninja.startClimbingDown();
                else if (privateProperties.actionState == "crouching" && ((downPressed && leftPressed) || (downPressed && rightPressed)))
                    ninja.startSliding();
                else
                    ninja.startCrouching();
            } else {
                if (privateProperties.actionState == "clinging" || privateProperties.actionState == "climbing")
                    ninja.stopClimbingDown();
                else if (privateProperties.actionState == "sliding")
                    ninja.stopSliding();
                else if (privateProperties.actionState == "crouching")
                    ninja.stopCrouching();
            }
            break;
        case "attack":
            if (type === "press") {
                ninja.attack();
            } else {

            }
            break;
        case "throw":
            if (type === "press") {
                ninja.throwKunai();
            } else {

            }
            break;
        case "use":
            if (type === "press") {
                ninja.use();
            } else {

            }
            break;
        }
    }

    function startMovingLeft() {
        switch (privateProperties.actionState) {
        case "hurting":
        case "dead":
        case "sliding":
            return;
        }

        rMoveLeftTimer.start();
    }

    function startMovingRight() {
        switch (privateProperties.actionState) {
        case "hurting":
        case "dead":
        case "sliding":
            return;
        }

        rMoveRightTimer.start();
    }

    function stopMovingLeft() {
        if (privateProperties.actionState != "clinging"
                && privateProperties.actionState != "hovering"
                && privateProperties.actionState != "crouching") {
            if (ninja.airborne)
                privateProperties.actionState = "freefall";
            else
                privateProperties.actionState = "idle";
        }

        rMoveLeftTimer.stop();

        var rightPressed = privateProperties.pressedKeys["right"];
        if (!rightPressed)
            ninja.linearVelocity.x = 0;
    }

    function stopMovingRight() {
        if (privateProperties.actionState != "clinging"
                && privateProperties.actionState != "hovering"
                && privateProperties.actionState != "crouching") {
            if (ninja.airborne)
                privateProperties.actionState = "freefall";
            else
                privateProperties.actionState = "idle";
        }

        rMoveRightTimer.stop();

        var leftPressed = privateProperties.pressedKeys["left"]
        if (!leftPressed)
            ninja.linearVelocity.x = 0;
    }

    function stopMovement() {
        ninja.stopMovingLeft();
        ninja.stopMovingRight();
    }

    function jump() {
        if (ninja.airborne)
            return;
        switch (privateProperties.actionState) {
        case "hurting":
        case "dead":
        case "clinging":
        case "crouching":
            return;
        }

        if(ninja.wearingDisguise)
            toggleDisguise();

        privateProperties.actionState = "rising";

        jumpSound.play();
        jumpTimer.restart();
        ninja.linearVelocity.y = 0;
        ninja.applyLinearImpulse(Qt.point(0, -ninja.getMass() * 9), ninja.getWorldCenter());
    }

    function startHovering() {
        if(!ninja.inHoverArea || privateProperties.actionState == "dead")
            return;

        rHoverTimer.start();
    }

    function stopHovering() {
        if(privateProperties.actionState == "dead" || privateProperties.actionState != "hovering")
            return;

        rHoverTimer.stop();
        ninja.gravityScale = 1;
        ninja.linearVelocity = Qt.point(0, 0);
        privateProperties.verticalDirectionState = "down";
        hoveringFreefallDelayTimer.restart();
    }

    function startCrouching() {
        if (ninja.airborne || ninja.inHoverArea || !ninja.isStationary())
            return;
        switch (privateProperties.actionState) {
        case "hurting":
        case "clinging":
        case "hovering":
        case "dead":
        case "running":
            return;
        }

        if(ninja.wearingDisguise)
            toggleDisguise();

        var downPressed = privateProperties.pressedKeys["down"];
        if((privateProperties.actionState == "idle" || privateProperties.actionState == "sliding") && downPressed) {
            ninja.decreaseHeight();
            privateProperties.actionState = "crouching";
        }
    }

    function stopCrouching() {
        if (!privateProperties.pressedKeys["down"]) {
            ninja.increaseHeight();
            privateProperties.actionState = "idle";
        }
    }

    function startSliding() {
        if(ninja.airborne || ninja.inHoverArea)
            return;
        switch (privateProperties.actionState) {
        case "hurting":
        case "dead":
        case "clinging":
        case "hovering":
            return;
        }

        var downPressed = privateProperties.pressedKeys["down"];
        var leftPressed = privateProperties.pressedKeys["left"];
        var rightPressed = privateProperties.pressedKeys["right"];

        if ((downPressed && leftPressed) || (downPressed && rightPressed)) {
            rMoveLeftTimer.stop();
            rMoveRightTimer.stop();

            if (privateProperties.actionState != "crouching")
                ninja.increaseHeight();

            privateProperties.actionState = "sliding";
            ninja.linearVelocity = Qt.point(0, 0);

            if(leftPressed) {
                privateProperties.horizontalDirectionState = "left";
                ninja.applyLinearImpulse(Qt.point(-ninja.getMass() * 10, 0), ninja.getWorldCenter());
            } else if (rightPressed) {
                privateProperties.horizontalDirectionState = "right";
                ninja.applyLinearImpulse(Qt.point(ninja.getMass() * 10, 0), ninja.getWorldCenter());
            }
        }
    }

    function stopSliding() {
        var downPressed = privateProperties.pressedKeys["down"];
        var leftPressed = privateProperties.pressedKeys["left"];
        var rightPressed = privateProperties.pressedKeys["right"];

        if (!((downPressed && leftPressed) || (downPressed && rightPressed))) {
            ninja.increaseHeight();

            console.log(downPressed, leftPressed, rightPressed);
            if (ninja.airborne)
                privateProperties.actionState = "freefall";
            else if (downPressed && !leftPressed && !rightPressed) {
                ninja.decreaseHeight();
                privateProperties.actionState = "crouching";
            }
            else if (ninja.isMoving())
                privateProperties.actionState = "running";
            else {
                ninja.linearVelocity = Qt.point(0, 0);
                privateProperties.actionState = "idle";
            }
        }
    }

    function startClimbingUp() {
        if (privateProperties.actionState == "dead")
            return;

        rClimbDownTimer.stop();
        rClimbUpTimer.start();
    }

    function startClimbingDown() {
        if (privateProperties.actionState == "dead")
            return;

        rClimbUpTimer.stop();
        rClimbDownTimer.start();
    }

    function stopClimbingUp() {
        if(ninja.inHoverArea || ninja.airborne || privateProperties.actionState != "climbing")
            return;
        switch (privateProperties.actionState) {
        case "dead":
        case "clinging":
        case "hovering":
            return;
        }

        rClimbUpTimer.stop();
        ninja.linearVelocity = Qt.point(0, 0);
        privateProperties.actionState = "clinging";
    }

    function stopClimbingDown() {
        if(ninja.inHoverArea || ninja.airborne || privateProperties.actionState != "climbing")
            return;
        switch (privateProperties.actionState) {
        case "dead":
        case "clinging":
        case "hovering":
            return;
        }

        rClimbDownTimer.stop();
        ninja.linearVelocity = Qt.point(0, 0);
        privateProperties.actionState = "clinging";
    }

    function attack() {
        if(ninja.inHoverArea)
            return;
        switch (privateProperties.actionState) {
        case "hurting":
        case "clinging":
        case "hovering":
        case "dead":
        case "jump_attacking":
        case "primary_attacking":
        case "crouch_attacking":
            return;
        }

        if(privateProperties.wearingDisguise)
            ninja.toggleDisguise();
        else if(ninja.airborne)
            privateProperties.actionState = "jump_attacking";
        else if(privateProperties.actionState == "crouching")
            privateProperties.actionState = "crouch_attacking";
        else
            privateProperties.actionState = "primary_attacking";

        swordSwingSound.play();
    }

    function throwKunai() {
        if(ninja.airborne)
            return;
        switch (privateProperties.actionState) {
        case "dead":
        case "clinging":
        case "throwing":
        case "dead":
            return;
        }

        if(totalKunaiCollected == 0) {
            dryFireSound.play();
            return;
        }
        if(privateProperties.wearingDisguise)
            ninja.toggleDisguise();

        privateProperties.actionState = "throwing";
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
        if(privateProperties.actionState == "dead")
            return;
        if(ninja.inDisguiseRange)
            ninja.toggleDisguise();
        else if(ninja.inInfoRange)
            ninja.infoRequested();
        else if(ninja.inLeverRange)
            utilized("lever");
        else if(ninja.inDoorRange)
            ninja.goToDoor();
    }

    function increaseHeight() {
        if (ninja.height == ninja.standingHeight)
            return;

        ninja.y -= ninja.standingHeight - ninja.crouchingHeight;
        ninja.height = ninja.standingHeight;
    }

    function decreaseHeight() {
        if (ninja.height == ninja.crouchingHeight)
            return;

        ninja.height = ninja.crouchingHeight;
        ninja.y += ninja.standingHeight - ninja.crouchingHeight;
    }

    function toggleDisguise() {
        if(!ninja.inDisguiseRange)
            return;

        ninja.wearingDisguise = !ninja.wearingDisguise;
        ninja.disguised(ninja.wearingDisguise);
    }

    function receivePain() {
        if(privateProperties.actionState == "dead")
            return;

        if (privateProperties.healthStatus > 0)
            privateProperties.actionState = "hurting";
        else {
            privateProperties.actionState = "dying";
            ninja.gravityScale = 1;
        }
        ninja.linearVelocity = Qt.point(0, 0);
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

    function goToDoor() {
        if(privateProperties.actionState == "dead")
            return;
        if(nextDoorLocation == Qt.point(-1, -1))
            return;

        ninja.x = nextDoorLocation.x;
        ninja.y = nextDoorLocation.y;
        ninja.teleported();
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

