import QtQuick 2.9
import QtMultimedia 5.9
import Seppuku 1.0
import "../singletons"

NarrowSlate {
    id: failSlate
    slateWidth: 312
    title: qsTr("Level Failed")
    styleColor: "red"

    QtObject {
        id: privateProperties

        readonly property var messages: {
            "bullet": ["Shot down boy!"],
            "crystal": ["Have aN ICE day!"],
            "ice_box": ["Headache!!!", "Lights out!"],
            "laser_cannon": ["Fried!", "You're \"fired\"!", "Would you like some fries with that cooked turkey?"],
            "robot": ["Stabs of the enemy!"],
            "sea": ["Stay out the water, student!", "Ninjas don't swim!", "Drink me!", "Quench your thirst!"],
            "unknown": ["Unhandled case!"]
        }

        readonly property string failureTease: messages[cause][Math.floor(Math.random() * messages[cause].length)].toString();
    }

    property string cause: "unknown"
    signal resumeFromCheckpointClicked
    signal restartClicked
    signal homeClicked

    content: FocusScope {
        Image {
            id: failImage
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            height: 90
            sourceSize.height: height
            fillMode: Image.PreserveAspectFit
            source: Global.paths.images + "fails/" + cause + ".png"
        }

        Text {
            anchors.top: failImage.bottom
            anchors.topMargin: 10
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            font.pixelSize: 21
            color: "white"
            text: privateProperties.failureTease
            wrapMode: Text.WordWrap
            style: Text.Outline;
            font.family: Stylesheet.hintFontFamily
            styleColor: "crimson" //Qt.darker("#F0C961", 1.25)
            verticalAlignment: Qt.AlignVCenter
            horizontalAlignment: Qt.AlignHCenter
        }

        Row {
            id: buttonRow
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
            }
            spacing: 12
            transform: Translate { id: buttonRowTranslate }

            GameIconButton {
                id: resumeFromCheckpointButton
                focus: visible
                visible: Global.checkpointAvailable
                text: Stylesheet.icons.fa_flag
                onClicked: failSlate.resumeFromCheckpointClicked();

                Keys.onUpPressed: event.accepted = true;
                Keys.onDownPressed: event.accepted = true;
                Keys.onLeftPressed: event.accepted = true;
                Keys.onRightPressed: {
                    restartButton.focus = true;
                    effect.play();
                }
            }

            GameIconButton {
                id: restartButton
                focus: !resumeFromCheckpointButton.visible
                text: Stylesheet.icons.fa_repeat
                onClicked: failSlate.restartClicked();

                Keys.onUpPressed: event.accepted = true;
                Keys.onDownPressed: event.accepted = true;
                Keys.onLeftPressed: {
                    if (resumeFromCheckpointButton.visible) {
                        resumeFromCheckpointButton.focus = true;
                        effect.play();
                    } else {
                        event.accepted = true;
                    }
                }

                Keys.onRightPressed: {
                    quitButton.focus = true;
                    effect.play();
                }
            }

            GameIconButton {
                id: quitButton
                text: Stylesheet.icons.fa_home
                onClicked: failSlate.homeClicked();

                Keys.onUpPressed: event.accepted = true;
                Keys.onDownPressed: event.accepted = true;
                Keys.onRightPressed: event.accepted = true;
                Keys.onLeftPressed: {
                    restartButton.focus = true;
                    effect.play();
                }
            }
        }

        SequentialAnimation {
            running: true

            PropertyAction { target: failImage; property: "scale"; value: 0 }
            PauseAnimation { duration: 1000 }
            ParallelAnimation {
                PropertyAnimation { target: failImage; property: "scale"; to: 1; easing.type: Easing.InOutBack; duration: 700 }
                PropertyAnimation { target: failImage; property: "rotation"; to: 360 * 4; duration: 600 }
            }
        }

        SequentialAnimation {
            running: true

            PropertyAction { target: buttonRow; property: "opacity"; value: 0 }
            PropertyAction { target: buttonRowTranslate; property: "y"; value: buttonRow.height / 2 }
            PauseAnimation { duration: 2000 }
            ParallelAnimation {
                NumberAnimation { target: buttonRow; property: "opacity"; to: 1; duration: 500 }
                NumberAnimation { target: buttonRowTranslate; property: "y"; to: 0; duration: 300 }
            }
        }

        SoundEffect {
            id: effect
            source: Global.paths.sounds + "dry_fire.wav"
            volume: Global.settings.sfxVolume
            muted: Global.settings.noSound
        }
    }
}
