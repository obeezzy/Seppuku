import QtQuick 2.9
import QtMultimedia 5.9
import Seppuku 1.0
import "../singletons"

FocusScope {
    id: statsSlate
    implicitWidth: 500
    implicitHeight: 500

    property int totalCoins: 0
    property int elapsedSeconds: 0
    property int tasksCompleted: 0
    property int totalTasks: 0
    property int stars: 0

    signal nextLevelClicked
    signal restartClicked
    signal achievementsClicked
    signal homeClicked

    Image {
        anchors.centerIn: parent
        source: Global.paths.images + "menus/stats_slate.png"
        width: 320
        fillMode: Image.PreserveAspectFit
        smooth: true

        Text {
            x: parent.width * .2
            y: parent.height * .03
            width: parent.width * .6
            height: width * .21
            font.pixelSize: 30
            color: "white"
            text: "level complete";
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            wrapMode: Text.WordWrap
            style: Text.Outline;
            font.family: Stylesheet.defaultFontFamily
            styleColor: "red"
        }

        Image {
            id: firstStar
            source: Global.paths.images + "menus/small_star.png"
            x: parent.width * .1
            y: parent.height * .24
            width: parent.width * .24
            height: width
            visible: stars > 0 ? true : false
        }

        Image {
            id: secondStar
            source: Global.paths.images + "menus/big_star.png"
            x: parent.width * .325
            y: parent.height * .153
            width: parent.width * .31
            height: width * 1.05
            visible: stars > 1 ? true : false
        }

        Image {
            id: thirdStar
            source: Global.paths.images + "menus/small_star.png"
            x: parent.width * .625
            y: parent.height * .235
            width: parent.width * .24
            height: width
            visible: stars > 2 ? true : false
        }

        Text {
            x: parent.width * .11
            y: parent.height * .47
            width: parent.width * .25
            height: width * .5
            font.pixelSize: 29
            color: "white"
            text: "coins";
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            wrapMode: Text.WordWrap
            style: Text.Outline
            font.family: Stylesheet.defaultFontFamily
            styleColor: "#f0c961"
        }

        Text {
            id: totalCoinValueText
            x: parent.width * .56
            y: parent.height * .47
            width: parent.width * .25
            height: width * .5
            font.pixelSize: 29
            color: "white"
            text: "0";
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            wrapMode: Text.WordWrap
            style: Text.Outline
            font.family: Stylesheet.defaultFontFamily
            styleColor: "#f0c961"
        }

        Text {
            x: parent.width * .11
            y: parent.height * .62
            width: parent.width * .25
            height: width * .5
            font.pixelSize: 22
            color: "white"
            text: "tasks completed";
            horizontalAlignment: Qt.AlignLeft
            verticalAlignment: Qt.AlignVCenter
            wrapMode: Text.WordWrap
            style: Text.Outline
            font.family: Stylesheet.defaultFontFamily
            styleColor: "#f0c961"
        }

        Text {
            id: totalTaskValueText
            x: parent.width * .59
            y: parent.height * .62
            width: parent.width * .25
            height: width * .5
            font.pixelSize: 29
            color: "white"
            text: tasksCompleted + " / " + totalTasks;
            horizontalAlignment: Qt.AlignLeft
            verticalAlignment: Qt.AlignVCenter
            wrapMode: Text.WordWrap
            style: Text.Outline
            font.family: Stylesheet.defaultFontFamily
            styleColor: "#f0c961"
        }

        Text {
            x: parent.width * .17
            y: parent.height * .76
            width: parent.width * .25
            height: width * .5
            font.pixelSize: 29
            color: "white"
            text: "time";
            horizontalAlignment: Qt.AlignLeft
            verticalAlignment: Qt.AlignVCenter
            wrapMode: Text.WordWrap
            style: Text.Outline
            font.family: Stylesheet.defaultFontFamily
            styleColor: "#f0c961"
        }

        Text {
            id: totalTimeValueText
            x: parent.width * .58
            y: parent.height * .76
            width: parent.width * .25
            height: width * .5
            font.pixelSize: 29
            color: "white"
            text: Utils.toTimeString(elapsedSeconds)
            horizontalAlignment: Qt.AlignLeft
            verticalAlignment: Qt.AlignVCenter
            wrapMode: Text.WordWrap
            style: Text.Outline
            font.family: Stylesheet.defaultFontFamily
            styleColor: "#f0c961"
        }

        Timer {
            id: coinTotalTimer
            repeat: true
            running: true
            interval: 50

            property int count: 0
            onTriggered: {
                if(count <= totalCoins)
                    totalCoinValueText.text = count++;
                else
                    repeat = false;
            }
        }

        Timer {
            id: taskTotalTimer
            repeat: true
            running: true
            interval: 50

            property int count: 0
            onTriggered: {
                if(count < tasksCompleted) {
                    count++;
                    totalTaskValueText.text = count + " / " + totalTasks;
                }
                else
                    repeat = false;
            }
        }

        Timer {
            id: timeTotalTimer
            repeat: true
            running: true
            interval: 50

            property int count: 0
            onTriggered: {
                if(count <= elapsedSeconds)
                    totalTimeValueText.text = Utils.toTimeString(count++);
                else
                    repeat = false;
            }
        }

        Row {
            id: buttonRow
            anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
            }

            spacing: 12
            transform: Translate { id: buttonRowTranslate }

            GameIconButton {
                id: nextLevelButton
                text: Stylesheet.icons.fa_play
                visible: Global.nextLevelAvailable
                focus: Global.nextLevelAvailable

                onClicked: statsSlate.nextLevelClicked();

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
                text: Stylesheet.icons.fa_repeat
                focus: !Global.nextLevelAvailable

                onClicked: statsSlate.restartClicked();

                Keys.onUpPressed: event.accepted = true;
                Keys.onDownPressed: event.accepted = true;

                Keys.onLeftPressed: {
                    if (nextLevelButton.visible) {
                        nextLevelButton.focus = true;
                        effect.play();
                    }
                }

                Keys.onRightPressed: {
                    achievementsButton.focus = true;
                    effect.play();
                }
            }

            GameIconButton {
                id: achievementsButton
                text: Stylesheet.icons.fa_trophy

                onClicked: statsSlate.achievementsClicked();

                Keys.onUpPressed: event.accepted = true;
                Keys.onDownPressed: event.accepted = true;

                Keys.onLeftPressed: {
                    restartButton.focus = true;
                    effect.play();
                }

                Keys.onRightPressed: {
                    quitButton.focus = true;
                    effect.play();
                }
            }

            GameIconButton {
                id: quitButton
                text: Stylesheet.icons.fa_home

                onClicked: statsSlate.homeClicked();

                Keys.onUpPressed: event.accepted = true;
                Keys.onDownPressed: event.accepted = true;

                Keys.onLeftPressed: {
                    achievementsButton.focus = true;
                    effect.play();
                }

                Keys.onRightPressed: event.accepted = true;
            }
        }

        SequentialAnimation {
            running: true

            PropertyAction { target: firstStar; property: "scale"; value: 0 }
            PropertyAction { target: secondStar; property: "scale"; value: 0 }
            PropertyAction { target: thirdStar; property: "scale"; value: 0 }
            PropertyAction { target: buttonRow; property: "enabled"; value: false }
            PropertyAction { target: buttonRow; property: "opacity"; value: 0 }
            PropertyAction { target: buttonRowTranslate; property: "y"; value: 18 }

            PauseAnimation { duration: 2000 }
            NumberAnimation { target: firstStar; property: "scale"; to: 1; easing.type: "OutBack"; easing.overshoot: 1.5; duration: 200 }
            NumberAnimation { target: secondStar; property: "scale"; to: 1; easing.type: "OutBack"; easing.overshoot: 1.5; duration: 200 }
            NumberAnimation { target: thirdStar; property: "scale"; to: 1; easing.type: "OutBack"; easing.overshoot: 1.5; duration: 200 }

            PauseAnimation { duration: 2000 }

            ParallelAnimation {
                NumberAnimation { target: buttonRow; property: "opacity"; to: 1; duration: 500 }
                NumberAnimation { target: buttonRowTranslate; property: "y"; to: 0; duration: 300 }
            }

            PropertyAction { target: buttonRow; property: "enabled"; value: true }
        }

        SoundEffect {
            id: effect
            source: Global.paths.sounds + "dry_fire.wav"
            volume: Global.settings.sfxVolume
            muted: Global.settings.noSound
        }
    }
}

