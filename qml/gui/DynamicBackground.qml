import QtQuick 2.7
import Bacon2D 1.0
import Seppuku 1.0
import Qt.labs.folderlistmodel 2.1
import "../singletons"

Item {
    id: dynamicBackground
    clip: true

    FolderListModel {
        id: folderModel
        folder: Global.paths.images + "backgrounds/main_menu/"
        nameFilters: ["*.jpg"]
    }

    Image {
        id: backImage
        width: parent.width
        height: parent.height
        source: getRandomBackground();
    }

    Image {
        id: frontImage
        width: parent.width
        height: parent.height
        source: getRandomBackground();
    }

    Connections {
        target: Global.gameWindow

        onGameStateChanged: {
            switch(Global.gameWindow.gameState) {
            case Bacon2D.Paused:
            case Bacon2D.Inactive:
            case Bacon2D.Suspended:
                opacityAnimation.pause();
                xAnimation.pause();
                break
            default:
                opacityAnimation.resume();
                xAnimation.resume();
                break
            }
        }
    }

    SequentialAnimation {
        id: opacityAnimation
        running: true

        PropertyAction { target: backImage; property: "opacity"; value: 0 }
        PropertyAction { target: backImage; property: "scale"; value: 1.5 }
        PropertyAction { target: frontImage; property: "scale"; value: 1.5 }

        PauseAnimation { duration: 10000 }

        SequentialAnimation {
            loops: Animation.Infinite

            PauseAnimation { duration: 8000 }

            ParallelAnimation {
                NumberAnimation { target: frontImage; property: "opacity"; to: 0; duration: 3000 }
                NumberAnimation { target: backImage; property: "opacity"; to: 1; duration: 3000 }
            }

            PropertyAction { target: frontImage; property: "source"; value: Global.paths.images + getRandomBackground(); }
            ScriptAction {
                script: {
                    xAnimation.stop();
                    frontImage.x = 0;
                    frontImage.source = getRandomBackground();
                    xAnimation.start();
                }
            }

            PauseAnimation { duration: 8000 }

            ParallelAnimation {
                NumberAnimation { target: backImage; property: "opacity"; to: 0; duration: 3000 }
                NumberAnimation { target: frontImage; property: "opacity"; to: 1; duration: 3000 }
            }

            PropertyAction { target: backImage; property: "source"; value: Global.paths.images + getRandomBackground(); }
            ScriptAction {
                script: {
                    xAnimation.stop();
                    backImage.x = 0;
                    backImage.source = getRandomBackground();
                    xAnimation.start();
                }
            }
        }
    }

    ParallelAnimation {
        id: xAnimation
        running: true
        loops: Animation.Infinite

        NumberAnimation { target: frontImage; property: "x"; to: calculateFinalX(frontImage); duration: 200000 }
        NumberAnimation { target: backImage; property: "x"; to: -calculateFinalX(backImage); duration: 200000 }
    }

    function calculateFinalX(item) { return item.width + item.width / item.scale; }

    function getRandomBackground() {
        var source = folderModel.get(Math.floor(Math.random() * folderModel.count), "filePath");
        return (source !== undefined ? source : "");
    }
}

