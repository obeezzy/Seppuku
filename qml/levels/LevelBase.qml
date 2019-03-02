import QtQuick 2.9
import Bacon2D 1.0
import QtMultimedia 5.9
import QtQuick.Window 2.2
import QtQuick.Controls 2.2
import Seppuku 1.0
import "../singletons"
import "../gui"
import "../common"
import "../entities"

TiledScene {
    id: levelBase
    physics: true
    debug: false
    pixelsPerMeter: 33
    gravity: Qt.point(0, 9.8);

    EntityManager { id: entityManager }

    viewport: HeroCamera {
        hero: levelBase.hero
        contentWidth: levelBase.width
        contentHeight: levelBase.height
    }

    // Level information
    property int level: 0
    property string levelTitle: ""

    property bool gameOver: false

    readonly property TutorText tutor: tutor
    readonly property Ninja hero: player.getEntity()
    property alias musicSource: bgm.source


    signal nextLevelRequested
    signal restartRequested
    signal paused
    signal resumed

    /*************************************** Heads Up Display (HUD) *********************************************/
    HeadsUpDisplay {
        id: hud
        x: viewport.xOffset + 6
        y: viewport.yOffset + 6
        width: viewport.width
        onPauseRequested: levelBase.toggleLevelPause();
    }

    TutorText {
        id: tutor
        x: viewport.xOffset
        y: hud.y + hud.height + 24
        width: viewport.width
    }

    /***************************** END HEADS-UP DISPLAY *********************************************************/


    /**************************** INPUT HANDLING *************************************************************/
    // Key handling
    Keys.enabled: !popupStack.enabled && !levelBase.gameOver && !Global.gameWindow.paused
    Keys.onPressed: {
        if (!event.isAutoRepeat) {
            switch (event.key) {
            case Qt.Key_Left:
                player.getEntity().handleEvent("left", "press");
                break;
            case Qt.Key_Right:
                player.getEntity().handleEvent("right", "press");
                break;
            case Qt.Key_Up:
                player.getEntity().handleEvent("up", "press");
                break;
            case Qt.Key_Down:
                player.getEntity().handleEvent("down", "press");
                break;
            case Qt.Key_Space:
                player.getEntity().handleEvent("attack", "press");
                break;
            case Qt.Key_Shift:
                player.getEntity().handleEvent("throw", "press");
                break;
            case Qt.Key_Z:
                player.getEntity().handleEvent("use", "press");
                break;
            case Qt.Key_F11:
                Global.fullscreenEnabled = !Global.fullscreenEnabled;
                break;
            case Qt.Key_Escape:
                levelBase.toggleLevelPause();
                break;
            case Qt.Key_D:
                levelBase.debug = !levelBase.debug;
                break;
            }
        }

        event.accepted = true;
    }

    Keys.onReleased: {
        if (!event.isAutoRepeat) {
            switch (event.key) {
            case Qt.Key_Left:
                hero.handleEvent("left", "release");
                break;
            case Qt.Key_Right:
                hero.handleEvent("right", "release");
                break;
            case Qt.Key_Up:
                hero.handleEvent("up", "release");
                break;
            case Qt.Key_Down:
                hero.handleEvent("down", "release");
                break;
            }
        }

        event.accepted = true;
    }

    PlayerVirtualPad {
        id: vPad
        x: viewport.xOffset
        y: viewport.yOffset + viewport.height - height
        width: viewport.width
    }

    PlayerGamePad {
        id: gamePad
        //onPauseRequested: levelBase.toggleLevelPause();
    }

    /*************************************** END INPUT HANDLING ***********************************************/

    /************************* VIEWPORT POSITIONING **************************************/
    readonly property int positionDelta: 120
    MouseArea {
        id: topArea
        x: viewport.xOffset
        y: viewport.yOffset
        enabled: levelBase.debug
        width: viewport.width
        height: 60
        z: Utils.zCamera

        Timer {
            running: parent.pressed
            repeat: true
            interval: 100
            triggeredOnStart: true

            onTriggered: viewport.vScroll(viewport.yOffset - positionDelta);
        }
    }

    MouseArea {
        id: bottomArea
        x: viewport.xOffset
        y: viewport.yOffset + viewport.height - height
        enabled: levelBase.debug
        width: viewport.width
        height: 60
        z: Utils.zCamera

        Timer {
            running: parent.pressed
            repeat: true
            interval: 100
            triggeredOnStart: true
            onTriggered: viewport.vScroll(viewport.yOffset + positionDelta);
        }
    }

    MouseArea {
        id: leftArea
        x: viewport.xOffset
        y: viewport.yOffset
        enabled: levelBase.debug
        width: 60
        height: viewport.height
        z: Utils.zCamera

        Timer {
            running: parent.pressed
            repeat: true
            interval: 100
            triggeredOnStart: true

            onTriggered: viewport.hScroll(viewport.xOffset - positionDelta);
        }
    }

    MouseArea {
        id: rightArea
        enabled: levelBase.debug
        x: viewport.xOffset + viewport.width - width
        y: viewport.yOffset
        width: 60
        height: viewport.height
        z: Utils.zCamera

        Timer {
            running: parent.pressed
            repeat: true
            interval: 100
            triggeredOnStart: true

            onTriggered: viewport.hScroll(viewport.xOffset + positionDelta);
        }
    }

    /************************ END VIEWPORT POSITIONING ***********************************/


    // When pause is requested by the user . . .
    function toggleLevelPause() {
        if(!Global.gameWindow.paused)
            popupStack.push(pausePopup);
        else
            popupStack.clear();
    }

    function playNextLevel() { Global.checkpoint = null; Global.gameWindow.playNextLevel(); }

    function resumeFromCheckpoint() { Global.gameWindow.restartLevel(); }

    function restartLevel() { Global.checkpoint = null; Global.gameWindow.restartLevel(); }

    function returnToMainMenu() { Global.checkpoint = null; Global.gameWindow.returnToMainMenu(); }

    /************************************************************************************/

    // When level is paused, stop timers
    function handlePause() {
        levelBase.paused();
        //bgm.pause()
    }

    // When level is resumed, start timers.
    function handleResume() {
        levelBase.resumed();

        if(popupStack.depth != 0 || levelBase.gameOver)
            bgm.pause();
        else
            bgm.play();
    }

    // When hero reaches the end of the level
    function completeLevel() {
        levelBase.gameOver = true;
        hud.stopTimer();
        completeLevelTimer.start();
    }

    // When the hero dies and you want to end the level
    function terminateLevel() {
        levelBase.gameOver = true;
        hud.stopTimer();
        terminateLevelTimer.start();
    }

    Timer {
        id: completeLevelTimer
        repeat: false
        interval: 1500

        onTriggered: {
            popupStack.push(statsPopup);
            bgm.stop();
        }
    }

    Timer {
        id: terminateLevelTimer
        repeat: false
        interval: 1500

        onTriggered: {
            popupStack.push(failPopup);
            bgm.stop();
        }
    }

    Connections {
        target: Global.gameWindow

        onGameStateChanged: {
            switch(Global.gameWindow.gameState) {
            case Bacon2D.Suspended:
            case Bacon2D.Paused:
            case Bacon2D.Inactive:
                handlePause();
                break;
            default:
                handleResume();
                break;
            }
        }
    }

    Connections {
        target: Qt.application
        onStateChanged: {
            switch(Qt.application.state) {
            case Qt.ApplicationSuspended:
            case Qt.ApplicationInactive:
            case Qt.ApplicationHidden:
                bgm.pause();
                break;
            default:
                levelBase.handleResume();
            }
        }
    }

    Audio {
        id: bgm
        source: Global.paths.music + "level_music1.mp3"
        autoPlay: true
        muted: Global.settings.noSound
        volume: Global.settings.bgmVolume
        loops: Audio.Infinite
    }





    /************************* POPUP HANDLING ********************************************/

    PopupStack {
        id: popupStack
        x: viewport.xOffset
        y: viewport.yOffset
        width: viewport.width
        height: viewport.height

        onEnabledChanged: {
            if (enabled)
                Global.gameWindow.gameState = Bacon2D.Paused;
            else {
                Global.gameWindow.gameState = Bacon2D.Running;
                levelBase.forceActiveFocus();
            }
        }

        Component {
            id: pausePopup

            PausePopup {
                onResumeClicked: levelBase.toggleLevelPause();
                onRestartClicked: levelBase.restartLevel();
                onQuitClicked: levelBase.returnToMainMenu();
            }
        }

        Component {
            id: statsPopup

            StatsPopup {
                id: statsPopupItem
                totalCoins: 60
                elapsedSeconds: hud.elapsedSeconds
                tasksCompleted: 3
                totalTasks: 20
                stars: 3

                Connections {
                    target: statsPopupItem
                    onNextLevelClicked: levelBase.playNextLevel();
                    onRestartClicked: levelBase.restartLevel();
                    onHomeClicked: levelBase.returnToMainMenu();
                }
            }
        }

        Component {
            id: failPopup

            FailPopup {
                id: failPopupItem
                cause: hero.deathCause

                Connections {
                    target: failPopupItem
                    onResumeFromCheckpointClicked: levelBase.resumeFromCheckpoint();
                    onRestartClicked: levelBase.restartLevel();
                    onHomeClicked: levelBase.returnToMainMenu();
                }
            }
        }

        Component {
            id: infoPopup

            InfoPopup {
                onDismissed: popupStack.clear();
                StackView.onRemoved: tutor.startDisplay();
            }
        }
    }

    /************************** END POPUP HANDLING **************************************/


    /******************************** LEVEL ENTITIES *********************************/
    layers: [
        TiledLayer {
            name: "Hero"

            TiledObjectGroup {
                id: player
                entity: Ninja { onSelfDestruct: terminateLevel(); }
            }
        },

        TiledLayer {
            name: "Boundaries"

            TiledObjectGroup {
                entity: Boundaries { }
            }
        },

        TiledLayer {
            name: "Block Ground"

            TiledObjectGroup {
                entity: BlockGround { }

                TiledPropertyMapping { property: "x" }
                TiledPropertyMapping { property: "y" }
            }
        },

        TiledLayer {
            name: "Ground Top"

            TiledObjectGroup {
                id: groundTopObject
                entity: GroundTop { }

                TiledPropertyMapping { property: "x" }
                TiledPropertyMapping { property: "y" }
            }
        },

        TiledLayer {
            name: "Slope Ground"

            TiledObjectGroup {
                entity: SlopeGround { }

                TiledPropertyMapping { property: "x" }
                TiledPropertyMapping { property: "y" }
            }
        },

        TiledLayer {
            name: "Pentagon Ground"
            TiledObjectGroup {
                entity: PentagonGround { }

                TiledPropertyMapping { property: "x" }
                TiledPropertyMapping { property: "y" }
            }
        },

        TiledLayer {
            name: "Frictionless Ground"
            TiledObjectGroup {
                entity: FrictionlessGround { }

                TiledPropertyMapping { property: "x" }
                TiledPropertyMapping { property: "y" }
            }
        },

        TiledLayer {
            id: oneWayPlatformLayer
            name: "One Way Platforms"

            TiledObjectGroup {
                entity: OneWayPlatform { }
            }
        },

        TiledLayer {
            name: "Ladders"

            TiledObjectGroup {
                entity: Ladder { }
                TiledPropertyMapping { property: "x" }
                TiledPropertyMapping { property: "y" }
            }
        },

        TiledLayer {
            id: limitLayer
            name: "Limits"

            TiledObjectGroup {
                id: limitObjectGroup
                entity: Limit { }

                TiledPropertyMapping { property: "x" }
                TiledPropertyMapping { property: "y" }
                TiledPropertyMapping { property: "link" }
                TiledPropertyMapping { property: "edge"; defaultValue: "bottom" }

                function startMovements() {
                    var cannon = entityManager.findEntity("laserCannon", "objectId", entity.link);
                    if (cannon !== null && cannon.objectId > -1 && Object(cannon).hasOwnProperty("limits")) {
                        Utils.applyLimit(entity, cannon);
                        cannon.startMovement();
                    }

                    var robot = entityManager.findEntity("robot", "objectId", entity.link);
                    if (robot !== null) {
                        Utils.applyLimit(entity, robot);
                        robot.startMovement();
                    }
                }
            }
        },

        TiledLayer {
            id: cameraMomentLayer
            name: "Camera Moments"

            TiledObjectGroup {
                entity: CameraMoment { }
                TiledPropertyMapping { property: "x" }
                TiledPropertyMapping { property: "y" }
                TiledPropertyMapping { property: "width" }
                TiledPropertyMapping { property: "height" }
                TiledPropertyMapping { property: "locked_x"; mapsTo: "lockedX" }
                TiledPropertyMapping { property: "locked_y"; mapsTo: "lockedY" }
                TiledPropertyMapping { property: "locked_min_x"; mapsTo: "lockedMinX" }
                TiledPropertyMapping { property: "locked_max_x"; mapsTo: "lockedMaxX" }
                TiledPropertyMapping { property: "locked_min_y"; mapsTo: "lockedMinY" }
                TiledPropertyMapping { property: "locked_max_y"; mapsTo: "lockedMaxY" }
            }
        },

        TiledLayer {
            id: lavaLayer
            name: "Lava"

            TiledObjectGroup {
                entity: Sea { }
                TiledPropertyMapping { property: "x" }
                TiledPropertyMapping { property: "y" }
                TiledPropertyMapping { property: "width" }
                TiledPropertyMapping { property: "height" }
                TiledPropertyMapping { property: "id"; mapsTo: "objectId" }
            }
        },

        TiledLayer {
            id: crystalLayer
            name: "Crystals"

            TiledObjectGroup {
                entity: Crystal { }
                TiledPropertyMapping { property: "x" }
                TiledPropertyMapping { property: "y" }
                TiledPropertyMapping { property: "width" }
                TiledPropertyMapping { property: "height" }
                TiledPropertyMapping { property: "rotation" }
                TiledPropertyMapping { property: "id"; mapsTo: "objectId" }
            }
        },

        TiledLayer {
            id: laserCannonLayer
            name: "Laser Cannons"

            TiledObjectGroup {
                entity: LaserCannon { }
                TiledPropertyMapping { property: "x" }
                TiledPropertyMapping { property: "y" }
                TiledPropertyMapping { property: "width" }
                TiledPropertyMapping { property: "height" }
                TiledPropertyMapping { property: "id"; mapsTo: "objectId" }
                TiledPropertyMapping { property: "direction" }
                TiledPropertyMapping { property: "laser_color"; mapsTo: "laserColor" }
                TiledPropertyMapping { property: "fire_interval"; mapsTo: "fireInterval" }
                TiledPropertyMapping { property: "cease_interval"; mapsTo: "ceaseInterval" }
                TiledPropertyMapping { property: "startup_delay"; mapsTo: "startupDelay" }
            }
        },

        TiledLayer {
            id: movingLaserCannonLayer
            name: "Moving Laser Cannons"

            TiledObjectGroup {
                entity: MovingLaserCannon { }
                TiledPropertyMapping { property: "x" }
                TiledPropertyMapping { property: "y" }
                TiledPropertyMapping { property: "width" }
                TiledPropertyMapping { property: "height" }
                TiledPropertyMapping { property: "id"; mapsTo: "objectId" }
                TiledPropertyMapping { property: "direction" }
                TiledPropertyMapping { property: "laser_color"; mapsTo: "laserColor" }
                TiledPropertyMapping { property: "fire_interval"; mapsTo: "fireInterval" }
                TiledPropertyMapping { property: "cease_interval"; mapsTo: "ceaseInterval" }
                TiledPropertyMapping { property: "startup_delay"; mapsTo: "startupDelay" }
                TiledPropertyMapping { property: "motion_velocity_x"; mapsTo: "motionVelocity.x" }
                TiledPropertyMapping { property: "motion_velocity_y"; mapsTo: "motionVelocity.y" }
            }
        },

        TiledLayer {
            id: laserLeverLayer
            name: "Laser Levers"

            TiledObjectGroup {
                entity: LaserLever { }
                TiledPropertyMapping { property: "x" }
                TiledPropertyMapping { property: "y" }
                TiledPropertyMapping { property: "width" }
                TiledPropertyMapping { property: "height" }
                TiledPropertyMapping { property: "id"; mapsTo: "objectId" }
                TiledPropertyMapping { property: "position"; defaultValue: "off" }
                TiledPropertyMapping { property: "color" }
                TiledPropertyMapping { property: "duration" }
                TiledPropertyMapping { property: "mirror"; defaultValue: false }
                TiledPropertyMapping { property: "laser_link"; mapsTo: "laserLink" }
            }
        },

        TiledLayer {
            id: leverSwitchLayer
            name: "Lever Switches"

            TiledObjectGroup {
                entity: LeverSwitch { }
                TiledPropertyMapping { property: "x" }
                TiledPropertyMapping { property: "y" }
                TiledPropertyMapping { property: "width" }
                TiledPropertyMapping { property: "height" }
                TiledPropertyMapping { property: "id"; mapsTo: "objectId" }
                TiledPropertyMapping { property: "position"; defaultValue: "left" }
                TiledPropertyMapping { property: "motion_link"; mapsTo: "motionLink" }
                TiledPropertyMapping { property: "y" }

                onEntityCreated: {
                    var cannon = entityManager.findEntity("laserCannon", { "objectId": entity.motionLink });
                    if (cannon !== null && cannon.objectId > -1 && Object(cannon).hasOwnProperty("motionSwitch"))
                        cannon.motionSwitch = lever;
                }
            }
        },

        TiledLayer {
            id: iceBoxLayer
            name: "Ice Boxes"

            TiledObjectGroup {
                id: iceBoxObject
                entity: IceBox { }
                TiledPropertyMapping { property: "x" }
                TiledPropertyMapping { property: "y" }
                TiledPropertyMapping { property: "width" }
                TiledPropertyMapping { property: "height" }
                TiledPropertyMapping { property: "id"; mapsTo: "objectId" }

                onEntityCreated: createIceBox();

                function createIceBox() {
//                    var warningSignComponent = Qt.createComponent("../entities/WarningSign.qml");
//                    var warningSign = warningSignComponent.createObject(levelBase);
//                    warningSign.x = iceBox.x;
//                    if (hero.clinging|| hero.climbing)
//                        warningSign.y = Qt.binding(function() { return viewport.yOffset + 6; });

//                    entity.warningSign = warningSign;
//                    entity.selfDestruct.connect(warningSign.destroy);
//                    iceBoxDropTimer.start();
                }
            }
        },

        TiledLayer {
            id: infoSignLayer
            name: "Info Signs"

            TiledObjectGroup {
                entity: InfoSign { }
                TiledPropertyMapping { property: "x" }
                TiledPropertyMapping { property: "y" }
                TiledPropertyMapping { property: "id"; mapsTo: "objectId" }
                TiledPropertyMapping { property: "hint_text"; mapsTo: "hintText" }
                TiledPropertyMapping { property: "balloon_text"; mapsTo: "balloonText" }

                onEntityCreated: {
                    entity.infoRequested.connect(function(properties) { popupStack.push(infoPopup, properties); });
                    entity.tutorTextArray = entity.TiledObjectGroup.instance.getProperty(entity.entityId, "tutor_text").toString().split("; ");
                    entity.tutorDurationArray = entity.TiledObjectGroup.instance.getProperty(entity.entityId, "tutor_duration").toString().split("; ");
                }
            }
        },

        TiledLayer {
            id: checkpointSignLayer
            name: "Checkpoint Signs"

            TiledObjectGroup {
                entity: CheckpointSign { }
                TiledPropertyMapping { property: "x" }
                TiledPropertyMapping { property: "y" }
                TiledPropertyMapping { property: "width" }
                TiledPropertyMapping { property: "height" }
                TiledPropertyMapping { property: "id"; mapsTo: "objectId" }
            }
        },

        TiledLayer {
            id: nearFinishSignLayer
            name: "Near Finish Signs"

            TiledObjectGroup {
                entity: NearFinishSign { }
                TiledPropertyMapping { property: "x" }
                TiledPropertyMapping { property: "y" }
                TiledPropertyMapping { property: "width" }
                TiledPropertyMapping { property: "height" }
                TiledPropertyMapping { property: "id"; mapsTo: "objectId" }
            }
        },

        TiledLayer {
            id: finishSignLayer
            name: "Finish Signs"

            TiledObjectGroup {
                entity: FinishSign { }
                TiledPropertyMapping { property: "x" }
                TiledPropertyMapping { property: "y" }
                TiledPropertyMapping { property: "width" }
                TiledPropertyMapping { property: "height" }
                TiledPropertyMapping { property: "id"; mapsTo: "objectId" }

                onEntityCreated: entity.levelComplete.connect(levelBase.completeLevel);
            }
        },

        TiledLayer {
            id: doorLayer
            name: "Doors"

            TiledObjectGroup {
                entity: WoodenDoor { }
                TiledPropertyMapping { property: "x" }
                TiledPropertyMapping { property: "y" }
                TiledPropertyMapping { property: "width" }
                TiledPropertyMapping { property: "height" }
                TiledPropertyMapping { property: "id"; mapsTo: "objectId" }
                TiledPropertyMapping { property: "closed" }
            }

            TiledObjectGroup {
                name: "lock"
                entity: DoorLock { }
                TiledPropertyMapping { property: "x" }
                TiledPropertyMapping { property: "y" }
                TiledPropertyMapping { property: "width" }
                TiledPropertyMapping { property: "height" }
                TiledPropertyMapping { property: "id"; mapsTo: "objectId" }
                TiledPropertyMapping { property: "color" }
            }
        },

        TiledLayer {
            id: machineLayer
            name: "Machines"

            TiledObjectGroup {
                name: "sensor"
                entity: Sensor { }
                TiledPropertyMapping { property: "x" }
                TiledPropertyMapping { property: "y" }
                TiledPropertyMapping { property: "width" }
                TiledPropertyMapping { property: "height" }
                TiledPropertyMapping { property: "design" }
                TiledPropertyMapping { property: "link" }
            }

            TiledObjectGroup {
                name: "cannon"
                entity: Cannon { }
                TiledPropertyMapping { property: "x" }
                TiledPropertyMapping { property: "y" }
                TiledPropertyMapping { property: "mirror" }
            }

            TiledObjectGroup {
                name: "laser_cannon"
                entity: LaserCannon { }
                TiledPropertyMapping { property: "x" }
                TiledPropertyMapping { property: "y" }
            }
        },

        TiledLayer {
            id: pipeLayer
            name: "Pipes"

            TiledObjectGroup {
                entity: Pipe { }
                onEntityCreated: console.log("Creating a pipe!", entity, entity.TiledObjectGroup.instance.count);
                TiledPropertyMapping { property: "x" }
                TiledPropertyMapping { property: "y" }
                TiledPropertyMapping { property: "width" }
                TiledPropertyMapping { property: "height" }
                TiledPropertyMapping { property: "id"; mapsTo: "objectId" }
                TiledPropertyMapping { property: "wind_height"; mapsTo: "windHeight" }
            }
        },

        TiledLayer {
            id: keyLayer
            name: "Keys"

            TiledObjectGroup {
                entity: Key { }
                TiledPropertyMapping { property: "x" }
                TiledPropertyMapping { property: "y" }
                TiledPropertyMapping { property: "width" }
                TiledPropertyMapping { property: "height" }
                TiledPropertyMapping { property: "id"; mapsTo: "objectId" }
                TiledPropertyMapping { property: "color" }
            }
        },

        TiledLayer {
            id: movingPlatformLayer
            name: "Moving Platforms"

            TiledObjectGroup {
                entity: MovingPlatform { moving: true }
                TiledPropertyMapping { property: "x" }
                TiledPropertyMapping { property: "y" }
                TiledPropertyMapping { property: "width" }
                TiledPropertyMapping { property: "height" }
                TiledPropertyMapping { property: "id"; mapsTo: "objectId" }
                TiledPropertyMapping { property: "start_velocity"; mapsTo: "startVelocity" }
                TiledPropertyMapping { property: "reverse_velocity"; mapsTo: "reverseVelocity" }
                TiledPropertyMapping { property: "start_point"; mapsTo: "startPoint" }
                TiledPropertyMapping { property: "reverse_point"; mapsTo: "reversePoint" }
            }
        },

        TiledLayer {
            id: snowmanLayer
            name: "Snowman"

            TiledObjectGroup {
                entity: Snowman { }
                TiledPropertyMapping { property: "x" }
                TiledPropertyMapping { property: "y" }
                TiledPropertyMapping { property: "y"; mapsTo: "initialY" }
                TiledPropertyMapping { property: "id"; mapsTo: "objectId" }
                TiledPropertyMapping { property: "boundsX"; mapsTo: "bounds.x" }
                TiledPropertyMapping { property: "boundsWidth"; mapsTo: "bounds.width" }
            }
        },

        TiledLayer {
            id: enemyLayer
            name: "Enemies"
            TiledObjectGroup {
                entity: Robot { }
                TiledPropertyMapping { property: "x" }
                TiledPropertyMapping { property: "y" }
            }
        },

        TiledLayer {
            id: kunaiLayer
            name: "Kunai"

            TiledObjectGroup {
                entity: Kunai { }
                TiledPropertyMapping { property: "x" }
                TiledPropertyMapping { property: "y" }
                TiledPropertyMapping { property: "id"; mapsTo: "objectId" }
                TiledPropertyMapping { property: "y" }
            }
        },

        TiledLayer {
            id: gemLayer
            name: "Gems"

            TiledObjectGroup {
                entity: Gem { }
                TiledPropertyMapping { property: "x" }
                TiledPropertyMapping { property: "y" }
                TiledPropertyMapping { property: "id"; mapsTo: "objectId" }
                TiledPropertyMapping { property: "color" }
            }
        },

        TiledLayer {
            id: leverLayer
            name: "Levers"

            TiledObjectGroup {
                entity: LeverSwitch { }
                TiledPropertyMapping { property: "x" }
                TiledPropertyMapping { property: "y" }
                TiledPropertyMapping { property: "id"; mapsTo: "objectId" }
                TiledPropertyMapping { property: "position" }
            }
        },

        TiledLayer {
            id: laserLayer
            name: "Lasers"
            TiledObjectGroup {
                entity: LaserCannon { }
                TiledPropertyMapping { property: "x" }
                TiledPropertyMapping { property: "y" }
            }
            TiledObjectGroup { name: "lever" }
        },

        TiledLayer {
            id: fishLayer
            name: "Fish"

            TiledObjectGroup {
                entity: Fish { }
                TiledPropertyMapping { property: "x" }
                TiledPropertyMapping { property: "y" }
                TiledPropertyMapping { property: "id"; mapsTo: "objectId" }
                TiledPropertyMapping { property: "start_x"; mapsTo: "startX" }
                TiledPropertyMapping { property: "end_x"; mapsTo: "endX" }
            }
        },

        TiledLayer {
            id: robotLayer
            name: "Robots"

            TiledObjectGroup {
                entity: Robot { }
                TiledPropertyMapping { property: "x" }
                TiledPropertyMapping { property: "y" }
                TiledPropertyMapping { property: "id"; mapsTo: "objectId" }
                TiledPropertyMapping { property: "face_forward"; mapsTo: "faceForward" }
                TiledPropertyMapping { property: "motion_velocity_x"; mapsTo: "motionVelocity.x" }
                TiledPropertyMapping { property: "motion_velocity_y"; mapsTo: "motionVelocity.y" }
            }
        },

        TiledLayer {
            id: cannonLayer
            name: "Cannons"

            TiledObjectGroup {
                entity: Cannon { }
                TiledPropertyMapping { property: "x" }
                TiledPropertyMapping { property: "y" }
            }
        }
    ]

    /*************** ITEMS ***************/
    Timer {
        id: iceBoxDropTimer
        running: !Global.gameWindow.paused
        repeat: false
        interval: 2000

        onTriggered: iceBoxObject.createIceBox();
    }
    /**************** END ITEMS ***************/

    function displayInstructions() {

    }

    /*********************************************************************************/

    Component.onCompleted: {
        limitObjectGroup.startMovements();
        levelBase.viewport.reset();
    }
}

