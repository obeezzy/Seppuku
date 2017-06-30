import QtQuick 2.9
import Bacon2D 1.0
import QtMultimedia 5.9
import Seppuku 1.0
import "../singletons"

Popup {
    id: statsPopup
    objectName: "StatsPopup"

    property int totalCoins: 50
    property int stars: 3
    property int elapsedSeconds: 400
    property int tasksCompleted: 3
    property int totalTasks: 15

    signal nextLevelClicked
    signal restartClicked
    signal achievementsClicked
    signal homeClicked

    content: StatsSlate {
        id: statsSlate
        totalCoins: statsPopup.totalCoins
        stars: statsPopup.stars
        elapsedSeconds: statsPopup.elapsedSeconds
        tasksCompleted: statsPopup.tasksCompleted
        totalTasks: statsPopup.totalTasks

        onNextLevelClicked: statsPopup.nextLevelClicked();
        onRestartClicked: statsPopup.restartClicked();
        onAchievementsClicked: statsPopup.achievementsClicked();
        onHomeClicked: statsPopup.homeClicked();

        SequentialAnimation {
            running: true

            PropertyAction { target: statsSlate; property: "opacity"; value: 0 }
            PropertyAction { target: statsSlate; property: "scale"; value: .2 }

            ParallelAnimation {
                NumberAnimation { target: statsSlate; property: "scale"; to: 1; duration: 300; easing.type: Easing.InOutBack }
                NumberAnimation { target: statsSlate; property: "opacity"; to: 1; duration: 300; easing.type: Easing.InOutBack }
            }

            ScriptAction { script: successSound.play(); }
        }
    }

    Audio {
        id: successSound
        volume: Global.settings.bgmVolume
        muted: Global.settings.noSound
        source: Global.paths.sounds + "success.wav"
        loops: 1
    }
}

