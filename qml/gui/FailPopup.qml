import QtQuick 2.9
import Bacon2D 1.0
import QtMultimedia 5.9
import Seppuku 1.0
import "../singletons"

Popup {
    id: failPopup
    objectName: "FailPopup"

    property string cause: "unknown"

    signal resumeFromCheckpointClicked
    signal restartClicked
    signal homeClicked

    FailSlate {
        id: failSlate
        anchors.centerIn: parent
        cause: failPopup.cause

        onResumeFromCheckpointClicked: failPopup.resumeFromCheckpointClicked();
        onRestartClicked: failPopup.restartClicked();
        onHomeClicked: failPopup.homeClicked();
    }

    SequentialAnimation {
        running: true

        ParallelAnimation {
            NumberAnimation { target: failSlate; property: "scale"; to: 1; duration: 300; easing.type: Easing.InOutBack }
            NumberAnimation { target: failSlate; property: "opacity"; to: 1; duration: 300; easing.type: Easing.InOutBack }
        }

        ScriptAction { script: failSound.play(); }
    }

    Audio {
        id: failSound
        volume: Global.settings.bgmVolume
        muted: Global.settings.noSound
        source: Global.paths.sounds + "game_over.wav"
        loops: 1
    }
}

