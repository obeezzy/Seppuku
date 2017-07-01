import QtQuick 2.9
import Bacon2D 1.0
import "../singletons"
import "../scenes"

Game {
    id: gameItem
    width: 800
    height: 600
    objectName: "Game"
    gameName: "com.geckogames.seppuku"
    ups: 30

    property var levelScenes: null
    signal mainMenuRequested
    signal restartLevelRequested

    SceneLoader {
        id: loadingScene
        sourceComponent: LoadingScene { }
    }

    readonly property bool paused: {
        switch(gameState) {
        case Bacon2D.Paused:
        case Bacon2D.Inactive:
        case Bacon2D.Suspended:
            true;
            break;
        default:
            false;
        }
    }

    function togglePause() {
        switch(gameState) {
        case Bacon2D.Running:
            gameState = Bacon2D.Paused;
            break;
        default:
            gameState = Bacon2D.Running;
            break;
        }
    }

    function pause() {
        gameState = Bacon2D.Paused;
    }

    function resume() {
        gameState = Bacon2D.Running;
    }

    function push(sceneLoader) {
        sceneLoader.active = true;

        if (sceneLoader.status === Loader.Ready)
            gameItem.pushScene(sceneLoader.item);
        else
            sceneLoader.onLoaded.connect(function() {
                gameItem.pushScene(sceneLoader.item);
            });
    }

    function pop() {
        return gameItem.popScene();
    }

    function playLevel(level) {
        gameItem.push(loadingScene);
        gameItem.push(levelScenes[level]);
    }


    function playNextLevel() {
        if (Object(levelScenes).hasOwnProperty(Global.settings.currentLevel + 1))
            playLevel(Global.settings.currentLevel + 1);
    }

    function restartLevel() {
        gameItem.push(loadingScene);
        restartLevelRequested();
    }

    function returnToMainMenu() {
        gameItem.push(loadingScene);
        mainMenuRequested();
    }

    Component.onCompleted: Global.gameWindow = gameItem;
}
