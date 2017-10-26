import QtQuick 2.9
import Bacon2D 1.0
import QtGraphicalEffects 1.0
import Seppuku 1.0
import "../singletons"
import "../gui"
import "../entities"

Item {
    id: headsUpDisplay
    width: 100
    height: 66
    z: 1

    readonly property Scene scene: parent
    readonly property Ninja hero: parent.hero

    // Hero properties
    readonly property real healthStatus: hero.healthStatus
    readonly property bool hurting: hero.actionState == "hurting"
    readonly property int totalCoins: hero.totalCoinsCollected
    readonly property int totalKunai: hero.totalKunaiCollected
    readonly property int totalBlueKeysCollected: hero.totalBlueKeysCollected
    readonly property int totalYellowKeysCollected: hero.totalYellowKeysCollected
    readonly property int totalRedKeysCollected: hero.totalRedKeysCollected
    readonly property int totalGreenKeysCollected: hero.totalGreenKeysCollected

    property int elapsedSeconds: 0
    property string elapsedTimeString: "00:00"

    Image {
        id: headImage
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: 10
        source: hurting || (healthStatus == 0) ? (hero.filePrefix + "dead_head.png") : (hero.filePrefix + "head.png")
        width: 70
        fillMode: Image.PreserveAspectFit
    }

    HealthBar {
        id: healthBar
        anchors.left: headImage.right
        anchors.leftMargin: 7
        anchors.verticalCenter: headImage.verticalCenter
        width: 180
        height: 6
        radius: 5

        healthStatus: headsUpDisplay.healthStatus
        transform: Translate { id: healthBarTransform }
    }


    Row {
        id: collectedItemsRow
        spacing: 7
        anchors.left: headImage.right
        anchors.top: healthBar.bottom
        anchors.leftMargin: 7
        anchors.topMargin: 7
        anchors.bottom: headImage.bottom
        z: parent.z - 1
        transform: Translate { id: collectedItemsTransform }

        function resetTransform() { transform = null; }

        Item {
            id: coinDisplay
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: contentRow.width

            Row {
                id: contentRow
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                spacing: 5

                Image {
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    source: Global.paths.images + "collectibles/coin_icon.png"
                }

                Text {
                    text: totalCoins
                    color: "white"
                    font.pixelSize: 20
                    font.family: "Copper Black"
                    style: Text.Outline
                    styleColor: "black"
                    width: contentWidth
                    height: contentHeight
                    verticalAlignment: Qt.AlignVCenter
                    horizontalAlignment: Qt.AlignHCenter
                }
            }
        }

        Item {
            id: kunaiDisplay
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: kunaiRow.width

            Row {
                id: kunaiRow
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                spacing: 2

                Image {
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: 40
                    fillMode: Image.PreserveAspectFit
                    source: Global.paths.images + "hud/kunai.png"
                }

                Text {
                    text: totalKunai
                    color: "white"
                    font.pixelSize: 20
                    font.family: "Copper Black"
                    style: Text.Outline
                    styleColor: "black"
                    width: contentWidth
                    height: contentHeight
                    verticalAlignment: Qt.AlignVCenter
                    horizontalAlignment: Qt.AlignHCenter
                }
            }
        }

        Item {
            id: spacer
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 3
        }

        Item {
            id: redKeyDisplay
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: redKeyRow.width
            visible: totalRedKeysCollected > 0

            Row {
                id: redKeyRow
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                spacing: 2

                Image {
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: height
                    source: Global.paths.images + "hud/hud_keyRed.png"

                    opacity: totalRedKeysCollected > 0 ? 1 : 0
                    scale: totalRedKeysCollected > 0 ? 1 : 4

                    Behavior on opacity { NumberAnimation {duration: 500 } }
                    Behavior on scale { NumberAnimation {duration: 500 } }
                }
            }
        }
    }

    GameIconButton {
        id: pauseButton
        anchors.left: headImage.left
        anchors.topMargin: 10
        anchors.top: headImage.bottom
        transform: Translate { id: pauseButtonTransform }

        text: Stylesheet.icons.fa_pause
        font.pixelSize: 24
    }

    Item {
        id: levelTimerDisplay
        anchors.right: parent.right
        anchors.topMargin: 10
        anchors.rightMargin: 18
        anchors.top: parent.top
        width: levelTimerRow.width
        transform: Translate { id: levelTimerDisplayTransform }

        Timer {
            id: levelTimer
            interval: 1000
            repeat: true
            running: !scene.gameOver

            onTriggered: {
                if(gameWindow.paused)
                    return;

                headsUpDisplay.elapsedTimeString = Utils.toTimeString(headsUpDisplay.elapsedSeconds++);
            }
        }

        Row {
            id: levelTimerRow
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            spacing: 5

            Image {
                id: clockImage
                anchors.top: parent.top
                height: 48
                fillMode: Image.PreserveAspectFit
                source: Global.paths.images + "hud/clock.png"
            }

            Text {
                text: headsUpDisplay.elapsedTimeString
                color: "white"
                font.pixelSize: 20
                font.family: "Copper Black"
                style: Text.Outline
                styleColor: "black"
                width: contentWidth
                height: contentHeight
                verticalAlignment: Qt.AlignVCenter
                horizontalAlignment: Qt.AlignHCenter
                anchors.verticalCenter: clockImage.verticalCenter
            }
        }
    }

    SequentialAnimation {
        id: startupAnimation
        running: true

        PropertyAction { target: headImage; property: "scale"; value: 0 }
        PropertyAction { target: healthBarTransform; property: "x"; value: -healthBar.width }
        PropertyAction { target: levelTimerDisplayTransform; property: "x"; value: levelTimerDisplay.width + anchors.rightMargin + 60 }
        PropertyAction { target: healthBar; property: "opacity"; value: 0 }
        PropertyAction { target: collectedItemsTransform; property: "x"; value: -collectedItemsRow.width }
        PropertyAction { target: collectedItemsRow; property: "opacity"; value: 0 }
        PropertyAction { target: pauseButtonTransform; property: "x"; value: -pauseButton.width - 36 }

        PauseAnimation { duration: 1000 }
        NumberAnimation { target: headImage; property: "scale"; to: 1; easing.type: Easing.OutBack; duration: 500 }

        ParallelAnimation {
            NumberAnimation { target: healthBarTransform; property: "x"; to: 0; easing.type: "OutBack"; duration: 500 }
            NumberAnimation { target: healthBar; property: "opacity"; to: 1; easing.type: "OutBack"; duration: 500 }
            NumberAnimation { target: collectedItemsTransform; property: "x"; to: 0; easing.type: "OutBack"; duration: 700 }
            NumberAnimation { target: collectedItemsRow; property: "opacity"; to: 1; duration: 700 }
        }

        ParallelAnimation {
            NumberAnimation { target: pauseButtonTransform; property: "x"; to: 0; easing.type: "OutBack"; duration: 250 }
            NumberAnimation { target: levelTimerDisplayTransform; property: "x"; to: 0;easing.type: "OutBack"; duration: 250 }
        }

        ScriptAction { script: collectedItemsRow.resetTransform(); }
    }

    function stopTimer() { levelTimer.stop(); }
}

