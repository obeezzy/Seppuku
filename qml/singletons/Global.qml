pragma Singleton
import QtQuick 2.9
import Bacon2D 1.0
import QtGamepad 1.0

// ----------- Prefixes --------------
// k = Box2D Category
// g = Group index
// z = position on z axis

Item {
    id: global

    // const static variables
    readonly property var paths: paths
    readonly property var gamepad: gamepad1
    readonly property int defaultWidth: 800
    readonly property int defaultHeight: 600

    readonly property bool checkpointAvailable: checkpoint !== null && checkpoint["level"] === currentLevel
    readonly property bool nextLevelAvailable: false
    readonly property int levelTotal: 10
    property int currentLevel: -1
    property var checkpoint: null

    readonly property bool isMobile: {
        switch(Qt.platform.os) {
            case "android":
            case "blackberry":
            case "ios":
                true;
                break;
            case "osx":
            case "linux":
            case "unix":
            case "windows":
            case "wince":
                false;
                break;
        }
    }

    readonly property Settings settings: Settings {
        readonly property int levelCount: 2
        property int highScore: 0
        property bool noSound: false
        property real sfxVolume: .4
        property real bgmVolume: .4
        property int newestAvailableLevel: 0
        category: "obeezzy"
    }

    property var gameWindow: undefined
    property bool fullscreenEnabled: false

    /********************* PATHS *******************************/
    QtObject {
        id: paths

        readonly property url assets: "../../assets/"
        readonly property url images: assets + "images/"
        readonly property url fonts: assets + "fonts/"
        readonly property url sounds: assets + "sounds/"
        readonly property url music: assets + "music/"
        readonly property url levels: assets + "levels/"
    }

    /******************* GAMEPADS *********************************/
    Gamepad {
        id: gamepad1
        deviceId: GamepadManager.connectedGamepads.length > 0 ? GamepadManager.connectedGamepads[0] : -1
    }

    Connections {
        target: GamepadManager
        onGamepadConnected: gamepad1.deviceId = deviceId;
    }
    /****************** END GAMEPADS ******************************/
}

