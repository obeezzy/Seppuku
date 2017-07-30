import QtQuick 2.9
import Bacon2D 1.0
import Seppuku 1.0
import QtQuick.Controls 2.2
import QtGamepad 1.0
import "common"
import "scenes"
import "singletons"

ApplicationWindow {
    id: mainWindow
    width: 800
    height: 600
    title: "Seppuku"
    visibility: Global.isMobile || Global.fullscreenEnabled ? ApplicationWindow.FullScreen : ApplicationWindow.Maximized
    visible: true

    readonly property var levelScenes: {
        1: level1,
                2: level2,
                3: level3
    }

    GameItem {
        id: gameWindow
        anchors.fill: parent
        currentScene: splashScene.item
        levelScenes: mainWindow.levelScenes

        onMainMenuRequested: gameWindow.push(mainMenuScene);
        onRestartLevelRequested: playLevel(Global.settings.currentLevel);
    }

    SceneLoader {
        id: splashScene
        asynchronous: false
        active: true
        sourceComponent: SplashScene { onTimeout: gameWindow.push(mainMenuScene); }
    }

    SceneLoader {
        id: mainMenuScene
        sourceComponent: MainMenuScene {
            onLevelSelected: gameWindow.playLevel(level);
            onCloseRequested: mainWindow.close();
        }
    }

    SceneLoader {
        id: level1
        source: "levels/Level1.qml"
    }

    SceneLoader {
        id: level2
        source: "levels/Level2.qml"
    }

    SceneLoader {
        id: level3
        source: "levels/Level3.qml"
    }
}
