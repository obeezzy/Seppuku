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

    readonly property point heroInitPos: Qt.point(heroPosition.x, heroPosition.y)
    //    heroInitPos: {
    //        Global.settings.checkpointState.level === 0 ? Qt.point(heroPosition.x, heroPosition.y) : Global.settings.checkpointState.pos
    //    }
    property alias musicSource: bgm.source
    property bool gameOver: false

    readonly property TutorText tutor: tutor
    readonly property Ninja hero: hero

    signal nextLevelRequested
    signal restartRequested
    signal paused
    signal resumed

    Ninja {
        id: hero
        x: heroInitPos.x
        y: heroInitPos.y

        onSelfDestruct: terminateLevel();
    }

    /*************************************** Heads Up Display (HUD) *********************************************/
    HeadsUpDisplay {
        id: hud
        x: viewport.xOffset + 6
        y: viewport.yOffset + 6
        width: viewport.width
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
                hero.handleEvent("left", "press");
                break;
            case Qt.Key_Right:
                hero.handleEvent("right", "press");
                break;
            case Qt.Key_Up:
                hero.handleEvent("up", "press");
                break;
            case Qt.Key_Down:
                hero.handleEvent("down", "press");
                break;
            case Qt.Key_Space:
                hero.handleEvent("attack", "press");
                break;
            case Qt.Key_Shift:
                hero.handleEvent("throw", "press");
                break;
            case Qt.Key_Z:
                hero.handleEvent("use", "press");
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

    function playNextLevel() { Global.gameWindow.playNextLevel(); }

    function restartLevel() { Global.gameWindow.restartLevel(); }

    function returnToMainMenu() { Global.gameWindow.returnToMainMenu(); }

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
            objects: TiledObject { id: heroPosition }
        },

        TiledLayer {
            name: "Boundaries"
            objects: TiledObject {
                fixtures: Chain {
                    density: 1
                    restitution: 0
                    friction: 0
                    categories: Utils.kGround
                }
            }
        },

        TiledLayer {
            name: "Block Ground"
            objects: TiledObject {
                fixtures: Box {
                    density: 1
                    restitution: 0
                    friction: 1
                    categories: Utils.kGround
                }
            }
        },

        TiledLayer {
            name: "Ground Top"
            objects: TiledObject {
                id: groundTopObject

                fixtures: [
                    Box {
                        height: groundTopObject.height * .1
                        density: 1
                        restitution: 0
                        friction: 1
                        categories: Utils.kGround | Utils.kGroundTop
                    },

                    Box {
                        y: groundTopObject.height * .1
                        height: groundTopObject.height * .9
                        density: 1
                        restitution: 0
                        friction: 1
                        categories: Utils.kGround
                    }
                ]
            }
        },

        TiledLayer {
            name: "Slope Ground"
            objects: TiledObject {
                fixtures: Polygon {
                    density: 1
                    restitution: 0
                    friction: .01
                    categories: Utils.kGround
                }
            }
        },

        TiledLayer {
            name: "Pentagon Ground"
            objects: TiledObject {
                fixtures: Polygon {
                    density: 1
                    restitution: 0
                    friction: 1
                    categories: Utils.kGround | Utils.kGroundTop
                }
            }
        },

        TiledLayer {
            name: "Frictionless Ground"
            objects: TiledObject {
                fixtures: Box {
                    density: 1
                    restitution: 0
                    friction: 0.3
                    categories: Utils.kGround | Utils.kGroundTop
                }
            }
        },

        TiledLayer {
            id: oneWayPlatformLayer
            name: "One Way Platforms"
            objects: TiledObject {
                fixtures: Polygon {
                    readonly property string type: "one_way_platform"

                    density: 1
                    restitution: 0
                    friction: 1
                    categories: Utils.kGround | Utils.kGroundTop
                }
            }
        },

        TiledLayer {
            name: "Ladders"
            objects: [
                TiledObject {
                    fixtures: Box {
                        sensor: true
                        categories: Utils.kLadder
                    }
                }
            ]
        },

        TiledLayer {
            id: limitLayer
            name: "Limits"
            objects: TiledObject {}
        },

        TiledLayer {
            id: cameraMomentLayer
            name: "Camera Moments"
            objects: TiledObject {}
        },

        TiledLayer {
            id: lavaLayer
            name: "Lava"
            objects: TiledObject {}
        },

        TiledLayer {
            id: crystalLayer
            name: "Crystals"
            objects: TiledObject {}
        },

        TiledLayer {
            id: laserCannonLayer
            name: "Laser Cannons"
            objects: TiledObject {}
        },

        TiledLayer {
            id: movingLaserCannonLayer
            name: "Moving Laser Cannons"
            objects: TiledObject {}
        },

        TiledLayer {
            id: laserLeverLayer
            name: "Laser Levers"
            objects: TiledObject {}
        },

        TiledLayer {
            id: leverSwitchLayer
            name: "Lever Switches"
            objects: TiledObject {}
        },

        TiledLayer {
            id: iceBoxLayer
            name: "Ice Boxes"
            objects: TiledObject {}
        },

        TiledLayer {
            id: infoSignLayer
            name: "Info Signs"
            objects: TiledObject {}
        },

        TiledLayer {
            id: nearFinishSignLayer
            name: "Near Finish Signs"
            objects: TiledObject {}
        },

        TiledLayer {
            id: finishSignLayer
            name: "Finish Signs"
            objects: TiledObject {}
        },

        TiledLayer {
            id: doorLayer
            name: "Doors"
            objects: [
                TiledObject {},

                TiledObject {
                    name: "lock"
                }
            ]
        },

        TiledLayer {
            id: machineLayer
            name: "Machines"
            objects: [
                TiledObject {
                    name: "sensor"
                },

                TiledObject {
                    name: "cannon"
                },

                TiledObject {
                    name: "laser_cannon"
                }
            ]
        },

        TiledLayer {
            id: pipeLayer
            name: "Pipes"
            objects: TiledObject {}
        },

        TiledLayer {
            id: keyLayer
            name: "Keys"
            objects: TiledObject {}
        },

        TiledLayer {
            id: movingPlatformLayer
            name: "Moving Platforms"
            objects: TiledObject {}
        },

        TiledLayer {
            id: snowmanLayer
            name: "Snowman"
            objects: TiledObject {}
        },

        TiledLayer {
            id: enemyLayer
            name: "Enemies"
            objects: TiledObject {}
        },

        TiledLayer {
            id: kunaiLayer
            name: "Kunai"
            objects: TiledObject {}
        },

        TiledLayer {
            id: gemLayer
            name: "Gems"
            objects: TiledObject {}
        },

        TiledLayer {
            id: leverLayer
            name: "Levers"
            objects: TiledObject {}
        },

        TiledLayer {
            id: laserLayer
            name: "Lasers"
            objects: [
                TiledObject {},
                TiledObject {name: "lever"}
            ]
        },

        TiledLayer {
            id: fishLayer
            name: "Fish"
            objects: TiledObject {}
        },

        TiledLayer {
            id: robotLayer
            name: "Robots"
            objects: TiledObject {}
        },

        TiledLayer {
            id: cannonLayer
            name: "Cannons"
            objects: TiledObject {}
        }
    ]

    /*************** ITEMS ***************/
    Timer {
        id: iceBoxDropTimer
        running: !Global.gameWindow.paused
        repeat: false
        interval: 2000

        onTriggered: createIceBox();
    }
    /**************** END ITEMS ***************/

    function createCameraMoments() {
        for(var i = 0; i < cameraMomentLayer.objects.length; ++i)
        {
            var object = cameraMomentLayer.objects[i];
            while(object.next())
            {
                var cameraMoment = entityManager.createEntity("../entities/CameraMoment.qml");
                cameraMoment.x = object.x;
                cameraMoment.y = object.y;
                cameraMoment.width = object.width;
                cameraMoment.height = object.height;
                cameraMoment.lockedX = object.getProperty("locked_x", true);
                cameraMoment.lockedY = object.getProperty("locked_y", true);
                cameraMoment.lockedMinX = object.getProperty("locked_min_x", false);
                cameraMoment.lockedMaxX = object.getProperty("locked_max_x", false);
                cameraMoment.lockedMinY = object.getProperty("locked_min_y", false);
                cameraMoment.lockedMaxY = object.getProperty("locked_max_y", false);
            }
        }
    }

    function createSea() {
        for(var i = 0; i < lavaLayer.objects.length; ++i)
        {
            var object = lavaLayer.objects[i];
            while(object.next())
            {
                var sea = entityManager.createEntity("../entities/Sea.qml");
                sea.x = object.x;
                sea.y = object.y;
                sea.width = object.width;
                sea.height = object.height;
                sea.objectName = object.getProperty("id");
            }
        }
    }

    function createMovingPlatforms() {
        for(var i = 0; i < movingPlatformLayer.objects.length; ++i)
        {
            var object = movingPlatformLayer.objects[i];
            while(object.next())
            {
                var platform = entityManager.createEntity("../entities/MovingPlatform.qml");
                platform.x = object.x;
                platform.y = object.y;
                platform.width = object.width;
                platform.height = object.height;
                platform.objectName = object.getProperty("id");
                platform.startVelocity = object.getProperty("start_velocity");
                platform.reverseVelocity = object.getProperty("reverse_velocity");
                platform.startPoint = object.getProperty("start_point");
                platform.reversePoint = object.getProperty("reverse_point");
                platform.moving = true;
            }
        }
    }

    function createCoins() {
        for(var i = 0; i < coinLayer.objects.length; ++i)
        {
            var object = coinLayer.objects[i];
            while(object.next())
            {
                var coin = entityManager.createEntity("../entities/Coin.qml");
                coin.x = object.x;
                coin.y = object.y;
                coin.width = object.width;
                coin.height = object.height;
                coin.objectName = object.getProperty("id");
            }
        }
    }

    function createSnowmen() {
        for(var i = 0; i < snowmanLayer.objects.length; ++i)
        {
            var object = snowmanLayer.objects[i];
            while(object.next())
            {
                if(object.name !== "")
                    continue;

                var snowman = entityManager.createEntity("../entities/Snowman.qml");
                snowman.x = object.x;
                snowman.y = object.y;
                snowman.initialY = object.y;
                snowman.objectName = object.getProperty("id");
                snowman.bounds.x = object.getProperty("boundsX");
                snowman.bounds.width = object.getProperty("boundsWidth");
                snowman.objectName = object.getProperty("id");
            }
        }
    }

    function createRobots() {
        for(var i = 0; i < robotLayer.objects.length; ++i)
        {
            var object = robotLayer.objects[i];
            if(object.name === "")
            {
                while(object.next())
                {
                    var robot = entityManager.createEntity("../entities/Robot.qml");
                    robot.x = object.x
                    robot.y = object.y
                    robot.objectName = object.getProperty("id")
                    robot.startX = object.getProperty("start_x")
                    robot.endX = object.getProperty("end_x")
                    robot.waitDelay = object.getProperty("wait_delay")
                    robot.facingLeft = object.getProperty("facing_left");
                }
            }
        }
    }

    function createFish() {
        for(var i = 0; i < fishLayer.objects.length; ++i)
        {
            var object = fishLayer.objects[i];
            if(object.name === "")
            {
                while(object.next())
                {
                    var fish = entityManager.createEntity("../entities/Fish.qml");
                    fish.x = object.x;
                    fish.y = object.y;
                    fish.objectName = object.getProperty("id");
                    fish.startX = object.getProperty("start_x");
                    fish.endX = object.getProperty("end_x");
                    //fish.facingLeft = object.getProperty("facing_left");
                }
            }
        }
    }

    function createKunai() {
        for(var i = 0; i < kunaiLayer.objects.length; ++i)
        {
            var object = kunaiLayer.objects[i];
            while(object.next())
            {
                var kunai = entityManager.createEntity("../entities/Kunai.qml");
                kunai.x = object.x;
                kunai.y = object.y;
                kunai.objectName = object.getProperty("id");
            }
        }
    }

    function createKeys() {
        for(var i = 0; i < keyLayer.objects.length; ++i)
        {
            var object = keyLayer.objects[i];
            while(object.next())
            {
                var key = entityManager.createEntity("../entities/Key.qml");
                key.x = object.x;
                key.y = object.y;
                key.width = object.width;
                key.height = object.height;
                key.objectName = object.getProperty("id");
                key.color = object.getProperty("color");
            }
        }
    }

    function createGems() {
        for(var i = 0; i < gemLayer.objects.length; ++i)
        {
            var object = gemLayer.objects[i];
            while(object.next())
            {
                var gem = entityManager.createEntity("../entities/Gem.qml");
                gem.x = object.x;
                gem.y = object.y;
                gem.objectName = object.getProperty("id");
                gem.color = object.getProperty("color");
            }
        }
    }

    function createChainedMass() {
//        var component = Qt.createComponent("../entities/IceBox.qml")
//        var iceBox = component.createObject(levelBase)
//        iceBox.x = hangerGround.x + hangerGround.width / 2
//        iceBox.y = hangerGround.y + hangerGround.height

//        component = Qt.createComponent("ChainRope.qml")
//        var chainRope = component.createObject(levelBase,
//                                                        {"entityA": hangerGround,
//                                                            "entityB": iceBlock,
//                                                            "length": 5
//                                                        })
//        chainRope.objectName = object.getProperty("id")
    }

    function createLevers() {
        for(var i = 0; i < leverLayer.objects.length; ++i)
        {
            var object = leverLayer.objects[i];
            while(object.next())
            {
                var lever = entityManager.createEntity("../entities/Lever.qml");
                lever.x = object.x;
                lever.y = object.y;
                lever.objectName = object.getProperty("id");
                lever.position = object.getProperty("position");
            }
        }
    }

    function createCrystals() {
        for(var i = 0; i < crystalLayer.objects.length; ++i)
        {
            var object = crystalLayer.objects[i];
            while(object.next())
            {
                var crystal = entityManager.createEntity("../entities/Crystal.qml");
                crystal.x = object.x;
                crystal.y = object.y;
                crystal.width = object.width;
                crystal.height = object.height;
                crystal.rotation = object.rotation;
                crystal.objectName = object.getProperty("id");
            }
        }
    }

    function createIceBox() {
        var object = iceBoxLayer.objects[0];
        object.index = Math.floor(Math.random() * object.count);

        var iceBox = entityManager.createEntity("../entities/IceBox.qml");
        iceBox.x = object.x;
        iceBox.y = object.y;
        iceBox.width = object.width;
        iceBox.height = object.height;
        iceBox.objectName = object.getProperty("id");

        var warningSignComponent = Qt.createComponent("../entities/WarningSign.qml");
        var warningSign = warningSignComponent.createObject(levelBase);
        warningSign.x = iceBox.x;
        warningSign.y = Qt.binding(function() { return viewport.yOffset + 6; });

        iceBox.warningSign = warningSign;
        iceBox.selfDestruct.connect(warningSign.destroy);
        iceBoxDropTimer.start();
    }

    function createInfoSigns() {
        for(var i = 0; i < infoSignLayer.objects.length; ++i)
        {
            var object = infoSignLayer.objects[i];
            var isFirstTime = false;

            while(object.next())
            {
                if(object.name === "")
                {
                    var sign = entityManager.createEntity("../entities/InfoSign.qml");
                    sign.x = object.x;
                    sign.y = object.y;
                    sign.objectId = object.getProperty("id");
                    sign.hintText = object.getProperty("hint_text");
                    sign.infoRequested.connect(function(properties) { popupStack.push(infoPopup, properties); });
                    sign.balloonVisible = !isFirstTime;
                    isFirstTime = true;

                    sign.tutorTextArray = object.getProperty("tutor_text").toString().split("; ");
                    sign.tutorDurationArray = object.getProperty("tutor_duration").toString().split("; ");
                }
            }
        }
    }

    function createNearFinishSigns() {
        for(var i = 0; i < nearFinishSignLayer.objects.length; ++i)
        {
            var object = nearFinishSignLayer.objects[i];
            while(object.next())
            {
                if(object.name === "")
                {
                    sign = entityManager.createEntity("../entities/NearFinishSign.qml");
                    sign.x = object.x;
                    sign.y = object.y;
                    sign.width = object.width;
                    sign.height = object.height;
                    sign.objectName = object.getProperty("id");
                }
            }
        }
    }

    function createFinishSigns() {
        for(var i = 0; i < finishSignLayer.objects.length; ++i)
        {
            var object = finishSignLayer.objects[i];
            while(object.next())
            {
                if(object.name === "")
                {
                    var sign = entityManager.createEntity("../entities/FinishSign.qml");
                    sign.x = object.x;
                    sign.y = object.y;
                    sign.width = object.width;
                    sign.height = object.height;
                    sign.objectName = object.getProperty("id");

                    sign.levelComplete.connect(levelBase.completeLevel);
                }
            }
        }
    }

    function createCheckpointSigns() {
        for(var i = 0; i < checkpointSignLayer.objects.length; ++i)
        {
            var object = checkpointSignLayer.objects[i];
            while(object.next())
            {
                if(object.name === "")
                {
                    sign = entityManager.createEntity("../entities/CheckpointSign.qml");
                    sign.x = object.x;
                    sign.y = object.y;
                    sign.width = object.width;
                    sign.height = object.height;
                    sign.objectName = object.getProperty("id");
                }
            }
        }
    }

    function createDoors() {
        var locks = {}; // used to link locks to doors
        var doors = {}; // used to link doors to doors

        for(var i = 0; i < doorLayer.objects.length; ++i)
        {
            var object = doorLayer.objects[i];
            while(object.next())
            {
                if(object.name === "lock")
                {
                    var lock = entityManager.createEntity("../entities/DoorLock.qml");
                    lock.x = object.x;
                    lock.y = object.y;
                    lock.width = object.width;
                    lock.height = object.height;
                    lock.objectName = object.getProperty("id");
                    lock.color = object.getProperty("color");
                    var link = object.getProperty("link");

                    if(link > 0)
                        locks[link] = lock;
                }
            }
        }

        for(i = 0; i < doorLayer.objects.length; ++i)
        {
            object = doorLayer.objects[i];
            object.reset();
            while(object.next())
            {
                if(object.name === "")
                {
                    var door = entityManager.createEntity("../entities/WoodenDoor.qml");
                    door.x = object.x;
                    door.y = object.y;
                    door.width = object.width;
                    door.height = object.height;
                    door.objectName = object.getProperty("id");
                    door.closed = object.getProperty("closed");
                    link = object.getProperty("link");

                    if(link > 0)
                    {
                        if(locks[link] !== undefined)
                            door.lock = locks[link];

                        // If I encounter this door for the first time, keep it in my dictionary
                        if(doors[link] === undefined)
                            doors[link] = door;
                        else
                        {
                            // If this link exists in the dictionary already, link the two doors
                            var firstDoor = doors[link]
                            var secondDoor = door;

                            if(firstDoor !== secondDoor)
                            {
                                firstDoor.nextDoor = secondDoor;
                                secondDoor.nextDoor = firstDoor;
                            }
                        }
                    }
                }
            }
        }
    }

    function createLaserCannons() {
        // Create laser cannons
        for(var i = 0; i < laserCannonLayer.objects.length; ++i)
        {
            var object = laserCannonLayer.objects[i];
            while(object.next())
            {
                if(object.name === "")
                {
                    var cannon = entityManager.createEntity("../entities/LaserCannon.qml");
                    cannon.x = object.x;
                    cannon.y = object.y;
                    cannon.width = object.width;
                    cannon.height = object.height;
                    cannon.objectId = object.getProperty("id");
                    cannon.direction = object.getProperty("direction");
                    cannon.laserColor = object.getProperty("laser_color");
                    cannon.fireInterval = object.getProperty("fire_interval");
                    cannon.ceaseInterval = object.getProperty("cease_interval");
                    cannon.startupDelay = object.getProperty("startup_delay");
                }
            }
        }
    }

    function createMovingLaserCannons() {
        // Create moving laser cannons
        for(var i = 0; i < movingLaserCannonLayer.objects.length; ++i)
        {
            var object = movingLaserCannonLayer.objects[i];
            while(object.next())
            {
                if(object.name === "")
                {
                    var cannon = entityManager.createEntity("../entities/MovingLaserCannon.qml");
                    cannon.x = object.x;
                    cannon.y = object.y;
                    cannon.width = object.width;
                    cannon.height = object.height;
                    cannon.objectId = object.getProperty("id");
                    cannon.direction = object.getProperty("direction");
                    cannon.laserColor = object.getProperty("laser_color");
                    cannon.fireInterval = object.getProperty("fire_interval");
                    cannon.ceaseInterval = object.getProperty("cease_interval");
                    cannon.startupDelay = object.getProperty("startup_delay");
                    cannon.motionVelocity.x = object.getProperty("motion_velocity_x", 0);
                    cannon.motionVelocity.y= object.getProperty("motion_velocity_y", 0);
                }
            }
        }
    }

    function createLaserLevers() {
        // Create and link levers to laser cannons
        for(var i = 0; i < laserLeverLayer.objects.length; ++i)
        {
            var object = laserLeverLayer.objects[i];
            while(object.next())
            {
                if(object.name === "")
                {
                    var lever = entityManager.createEntity("../entities/LaserLever.qml");
                    lever.x = object.x;
                    lever.y = object.y;
                    lever.width = object.width;
                    lever.height = object.height;
                    lever.objectName = object.getProperty("id");
                    lever.position = object.getProperty("position", "off");
                    lever.color = object.getProperty("color");
                    lever.duration = object.getProperty("duration", 0);
                    lever.mirror = object.getProperty("mirror", "false") === "true";
                    lever.laserLink = object.getProperty("laser_link", 0);

                    var cannon = entityManager.findEntity("laserCannon", "objectId", lever.laserLink);
                    if (cannon !== null && cannon.objectId > -1 && Object(cannon).hasOwnProperty("laserLever"))
                        cannon.laserLever = lever;
                }
            }
        }
    }

    function createLeverSwitches() {
        // Create laser cannons and link levers to them
        for(var i = 0; i < leverSwitchLayer.objects.length; ++i)
        {
            var object = leverSwitchLayer.objects[i];
            while(object.next())
            {
                if(object.name === "")
                {
                    var lever = entityManager.createEntity("../entities/LeverSwitch.qml");
                    lever.x = object.x;
                    lever.y = object.y;
                    lever.width = object.width;
                    lever.height = object.height;
                    lever.objectName = object.getProperty("id");
                    lever.position = object.getProperty("position", "left");
                    lever.motionLink = object.getProperty("motion_link", 0);

                    var cannon = entityManager.findEntity("laserCannon", "objectId", lever.motionLink);
                    if (cannon !== null && cannon.objectId > -1 && Object(cannon).hasOwnProperty("motionSwitch"))
                        cannon.motionSwitch = lever;
                }
            }
        }
    }

    function configureOneWayPlatforms() {
        for(var i = 0; i < oneWayPlatformLayer.objects.length; ++i)
        {
            var object = oneWayPlatformLayer.objects[i];
            while(object.next())
            {
                if(object.name === "")
                {
                    var platform = object.collisions[object.index];
                    for (var j = 0; j < platform.body.fixtures.length; ++j) {
                        platform.body.fixtures[j].type = "one_way_platform";
                    }
                }
            }
        }
    }

    function createLimits() {
        for (var i = 0; i < limitLayer.objects.length; ++i)
        {
            var object = limitLayer.objects[i];
            while (object.next())
            {
                if (object.name === "")
                {
                    var limit = entityManager.createEntity("../entities/Limit.qml");
                    limit.x = object.x;
                    limit.y = object.y;
                    limit.limitLink = object.getProperty("limit_link", 0);
                    limit.limitEdge = object.getProperty("limit_edge", "bottom");

                    var cannon = entityManager.findEntity("laserCannon", "objectId", limit.limitLink);
                    if (cannon !== null && cannon.objectId > -1 && Object(cannon).hasOwnProperty("limits")) {
                        switch (limit.limitEdge) {
                        case "top": cannon.limits.topY = limit.y; break;
                        case "bottom": cannon.limits.bottomY = limit.y - cannon.height; break;
                        case "left": cannon.limits.leftX = limit.x; break;
                        case "right": cannon.limits.rightX = limit.x - cannon.width; break;
                        }

                        cannon.startMovement();
                    }
                }
            }
        }
    }

    function createLasers() {
        var levers = {};

        // Create and store levers
        for(var i = 0; i < laserLayer.objects.length; ++i)
        {
            var object = laserLayer.objects[i];
            while(object.next())
            {
                if(object.name === "lever")
                {
                    var lever = entityManager.createEntity("../entities/LaserLever.qml");
                    lever.x = object.x;
                    lever.y = object.y;
                    lever.width = object.width;
                    lever.height = object.height;
                    lever.objectName = object.getProperty("id");
                    lever.color = object.getProperty("color");
                    lever.position = object.getProperty("position");
                    lever.duration = object.getProperty("duration", 0);
                    lever.mirror = object.getProperty("mirror", false);

                    var link = object.getProperty("link");
                    if(link > 0)
                        levers[link] = lever;
                }
            }
        }

        // Create laser cannons and link levers to them
        for(i = 0; i < laserLayer.objects.length; ++i)
        {
            object = laserLayer.objects[i];
            object.reset()
            while(object.next())
            {
                if(object.name === "")
                {
                    var cannon = entityManager.createEntity("../entities/LaserCannon.qml");
                    cannon.x = object.x;
                    cannon.y = object.y;
                    cannon.width = object.width;
                    cannon.height = object.height;
                    cannon.objectName = object.getProperty("id");
                    cannon.direction = object.getProperty("direction");
                    cannon.laserColor = object.getProperty("laser_color");
                    cannon.fireInterval = object.getProperty("fire_interval");
                    cannon.ceaseInterval = object.getProperty("cease_interval");
                    cannon.startupDelay = object.getProperty("startup_delay");

                    link = object.getProperty("link");

                    if(link > 0)
                        cannon.lever = levers[link];
                }
            }
        }
    }

    function createCannons() {
        var sensors = {};

        // Create and store sensors
        for(var i = 0; i < cannonLayer.objects.length; ++i)
        {
            var object = cannonLayer.objects[i];
            while(object.next())
            {
                if(object.name === "sensor")
                {
                    var sensor = entityManager.createEntity("../entities/Sensor.qml");
                    sensor.x = object.x;
                    sensor.y = object.y;
                    sensor.width = object.width;
                    sensor.height = object.height;
                    sensor.objectName = object.getProperty("id");
                    sensor.design = object.getProperty("design");
                    sensor.link = object.getProperty("link");

                    var link = object.getProperty("link");

                    if(link > 0)
                        sensors[link] = sensor;
                }
            }
        }

        // Create machines and link sensors to machines
        for(i = 0; i < cannonLayer.objects.length; ++i)
        {
            object = cannonLayer.objects[i];
            object.reset();
            if(object.name === "")
            {
                var cannon = entityManager.createEntity("../entities/Cannon.qml");
                cannon.x = object.x;
                cannon.y = object.y;
                cannon.mirror = object.getProperty("mirror");

                link = object.getProperty("link");

                if(link > 0)
                    cannon.sensor = sensors[link];
            }
        }
    }

    function createPipes() {
        for(var i = 0; i < pipeLayer.objects.length; ++i)
        {
            var object = pipeLayer.objects[i];
            while(object.next())
            {
                var pipe = entityManager.createEntity("../entities/Pipe.qml");
                pipe.x = object.x;
                pipe.y = object.y;
                pipe.width = object.width;
                pipe.height = object.height;
                pipe.objectName = object.getProperty("id");
                pipe.windHeight = object.getProperty("wind_height");
            }
        }
    }

    function createMachines() {
        var sensors = {};

        // Create and store sensors
        for(var i = 0; i < machineLayer.objects.length; ++i)
        {
            var object = machineLayer.objects[i];
            while(object.next())
            {
                if(object.name === "sensor")
                {
                    var sensor = entityManager.createEntity("../entities/Sensor.qml");
                    sensor.x = object.x;
                    sensor.y = object.y;
                    sensor.width = object.width;
                    sensor.height = object.height;
                    sensor.objectName = object.getProperty("id");
                    sensor.design = object.getProperty("design");
                    sensor.link = object.getProperty("link");

                    var link = object.getProperty("link");

                    if(link > 0)
                        sensors[link] = sensor;
                }
            }
        }

        // Create machines and link sensors to machines
        for(i = 0; i < machineLayer.objects.length; ++i)
        {
            object = machineLayer.objects[i];
            object.reset();
            while(object.next())
            {
                if(object.name === "cannon")
                {
                    var cannon = entityManager.createEntity("../entities/Cannon.qml");
                    cannon.x = object.x;
                    cannon.y = object.y;
                    cannon.mirror = object.getProperty("mirror");

                    link = object.getProperty("link");

                    if(link > 0)
                        cannon.sensor = sensors[link];
                }

                else if(object.name === "laser_cannon")
                {
                    cannon = entityManager.createEntity("../entities/LaserCannon.qml");
                    cannon.x = object.x;
                    cannon.y = object.y;
                    cannon.width = object.width;
                    cannon.height = object.height;
                    cannon.objectName = object.getProperty("id");
                    cannon.direction = object.getProperty("direction");
                    cannon.laserColor = object.getProperty("laser_color");
                    cannon.fireInterval = object.getProperty("fire_interval");
                    cannon.ceaseInterval = object.getProperty("cease_interval");
                    cannon.startupDelay = object.getProperty("startup_delay");
                }
            }
        }
    }

    function displayInstructions() {

    }

    /*********************************************************************************/

    Component.onCompleted: {
        Global.settings.currentLevel = level;
        Global.settings.checkpointState = null;

        // Create entities
        displayInstructions();
        createCameraMoments();
        createSea();
        createCrystals();
        createPipes();
        createLaserCannons();
        createMovingLaserCannons();
        // Must be created after cannons
        createLaserLevers();
        createLeverSwitches();
        createLimits();
        createInfoSigns();
        createFinishSigns();
        // End

        configureOneWayPlatforms();

        levelBase.viewport.reset();
//        createLasers();
//        createKeys();
//        createDoors();
        //createNearFinishSigns();
        //createFinishSigns();
        //createCheckpointSigns();
//        createFish();

//        createRobots();
//        createCannons();
//        createMovingPlatforms();
//        createSnowmen();
//        createKunai();
//        createKeys();
//        createGems();
//        createChainedMass();
//        createLevers();

//        //Delete
//        createMachines();
    }
}

