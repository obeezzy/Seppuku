import QtQuick 2.9
import Bacon2D 1.0
import Seppuku 1.0
import QtQuick.Controls 2.2
import "common"
import "scenes"
import "singletons"

ApplicationWindow {
    id: mainWindow
    width: 800
    height: 600
    title: "Seppuku"

    readonly property var levelScenes: {
        1: level1,
                2: level2,
                3: level3
    }

    GameItem {
        id: gameWindow
        anchors.fill: parent
        currentScene: splashScene.item
        levelScenes: {
            1: level1,
                    2: level2,
                    3: level3
        }

        onMainMenuRequested: gameWindow.push(mainMenuScene);
        onRestartLevelRequested: playLevel(Global.currentLevel);
    }

    SceneLoader {
        id: splashScene
        active: true
        sourceComponent: SplashScene { onTimeout: gameWindow.push(mainMenuScene); }
    }

    SceneLoader {
        id: mainMenuScene
        asynchronous: true
        sourceComponent: MainMenuScene {
            onLevelSelected: gameWindow.playLevel(level);
            onCloseRequested: mainWindow.close();
        }
    }

    SceneLoader {
        id: level1
        asynchronous: true
        source: "levels/Level1.qml"
    }

    SceneLoader {
        id: level2
        asynchronous: true
        source: "levels/Level2.qml"
    }

    SceneLoader {
        id: level3
        asynchronous: true
        source: "levels/Level3.qml"
    }

    Component.onCompleted: {
        if(Global.isMobile)
            showFullScreen();
        else
            showNormal();
    }
}
