import QtQuick 2.9
import Bacon2D 1.0
import QtMultimedia 5.9
import Seppuku 1.0
import QtGamepad 1.0
import "../singletons"
import "../common"
import "../gui"

SceneBase {
    id: mainMenuScene

    signal closeRequested
    signal levelSelected(int level)

    onActiveFocusChanged: if (activeFocus) stackView.forceActiveFocus();

    enterAnimation: NumberAnimation {
        target: mainMenuScene
        property: "y"
        from: -mainMenuScene.height
        to: 0
        duration: 1500
        easing.type: Easing.OutBounce
    }
    exitAnimation: NumberAnimation {
        target: mainMenuScene
        property: "y"
        from: 0
        to: -mainMenuScene.height
        duration: 800
        easing.type: Easing.InOutCirc
    }

    DynamicBackground { anchors.fill: parent }

    Rectangle { anchors.fill: parent; color: "#8057007f" } // Overlay

    Row {
        id: titleRow
        anchors.top: parent.top
        anchors.topMargin: 15
        anchors.horizontalCenter: parent.horizontalCenter

        Image {
            source: Global.paths.images + "misc/seppuku_white.png"
            fillMode: Image.PreserveAspectFit
            width: 60
        }

        Text {
            id: titleText

            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            width: contentWidth
            height: contentHeight

            text: "Seppuku"
            color: "white"

            font.family: Stylesheet.defaultFontFamily
            font.pixelSize: 53

            style: Text.Outline
            styleColor: "#57007f"
        }
    }

    SlateStack {
        id: stackView
        anchors {
            top: titleRow.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }

        initialItem: MainMenuSlate {
            onPlayRequested: stackView.push(levelSelectSlate);
            onOptionsRequested: stackView.push(optionsSlate);
            onQuitRequested: stackView.push(closingSlate);
        }

        Component {
            id: closingSlate

             QuestionSlate {
                 text: qsTr("Are you sure you want to quit?")
                 onYesClicked: mainMenuScene.closeRequested();
                 onNoClicked: stackView.pop();
            }
        }

        Component {
            id: optionsSlate

            OptionsSlate { onDoneClicked: stackView.pop(); }
        }

        Component {
            id: levelSelectSlate

            LevelSelectSlate {
                onLevelSelected: mainMenuScene.levelSelected(level);
                onHomeClicked: stackView.pop();
            }
        }

        Keys.onPressed: {
            switch(event.key) {
            case Qt.Key_Back:
            case Qt.Key_Backspace:
                stackView.pop();
                break;
            }
        }
    }

    readonly property var playlist: [
        "launch_music1.mp3",
        "launch_music2.mp3",
        "launch_music3.mp3"
    ]

    Audio {
        id: bgm
        volume: Global.settings.bgmVolume
        autoPlay: true
        muted: Global.settings.noSound
        source: getRandomSource();

        function getRandomSource() { return Global.paths.music + mainMenuScene.playlist[Math.floor(Math.random() * mainMenuScene.playlist.length)]; }
    }

    Connections {
        target: Global.gameWindow

        onGameStateChanged: {
            if(!mainMenuScene.running)
                return;

            switch(Global.gameWindow.gameState) {
            case Bacon2D.Paused:
            case Bacon2D.Inactive:
            case Bacon2D.Suspended:
                bgm.pause();
                break
            default:
                bgm.play();
                break
            }
        }
    }

    GamepadKeyNavigation {
        id: gamepadKeyNavigation
        gamepad: Global.gamepad
        active: true
        buttonAKey: Qt.Key_Return
        buttonStartKey: Qt.Key_Escape
        buttonBKey: Global.isMobile ? Qt.Key_Back : Qt.Key_Backspace
    }

    onRunningChanged: {
        if(mainMenuScene.running)
            bgm.play();
        else
            bgm.pause();
    }
}

