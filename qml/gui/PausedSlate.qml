import QtQuick 2.9
import QtMultimedia 5.4
import Seppuku 1.0
import "../singletons"

NarrowSlate {
    id: pausedSlate

    signal resumeClicked
    signal restartClicked
    signal optionsClicked
    signal quitClicked

    implicitWidth: 500
    implicitHeight: 500
    title: qsTr("Paused")
    styleColor: "crimson"
    slateWidth: 300

    content: FocusScope {
        Column {
            anchors.top: parent.top
            anchors.topMargin: 2
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 6

            GameButton {
                id: resumeButton
                text: qsTr("Resume")
                focus: true
                width: optionsButton.width
                onClicked: pausedSlate.resumeClicked();

                Keys.onUpPressed: event.accepted = true;
                Keys.onDownPressed: {
                    restartButton.focus = true;
                    effect.play();
                }
            }

            GameButton {
                id: restartButton
                text: qsTr("Restart")
                width: optionsButton.width
                onClicked: pausedSlate.restartClicked();

                Keys.onUpPressed: {
                    resumeButton.focus = true;
                    effect.play();
                }

                Keys.onDownPressed: {
                    optionsButton.focus = true;
                    effect.play();
                }
            }

            GameButton {
                id: optionsButton
                text: qsTr("Options")
                onClicked: pausedSlate.optionsClicked();

                Keys.onUpPressed: {
                    restartButton.focus = true;
                    effect.play();
                }

                Keys.onDownPressed: {
                    quitButton.focus = true;
                    effect.play();
                }
            }

            GameButton {
                id: quitButton
                text: qsTr("Quit")
                width: optionsButton.width
                onClicked: pausedSlate.quitClicked();

                Keys.onUpPressed: {
                    optionsButton.focus = true;
                    effect.play();
                }
                Keys.onDownPressed: event.accepted = true;
            }
        }
    }

    SoundEffect {
        id: effect
        source: Global.paths.sounds + "dry_fire.wav"
        volume: Global.settings.sfxVolume
        muted: Global.settings.noSound
    }
}
