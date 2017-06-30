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
    readonly property Ninja actor: parent.actor
    readonly property string fileLocation: actor.fileLocation

    // Actor properties
    readonly property real healthStatus: actor.healthStatus
    readonly property bool hurting: actor.hurting
    readonly property int totalCoins: actor.totalCoinsCollected
    readonly property int totalKunai: actor.totalKunaiCollected
    readonly property int totalBlueKeysCollected: actor.totalBlueKeysCollected
    readonly property int totalYellowKeysCollected: actor.totalYellowKeysCollected
    readonly property int totalRedKeysCollected: actor.totalRedKeysCollected
    readonly property int totalGreenKeysCollected: actor.totalGreenKeysCollected

    property int elapsedSeconds: 0
    property string elapsedTimeString: "00:00"

    Image {
        id: headImage
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: 10
        source: hurting || (healthStatus == 0) ? (fileLocation + "dead_head.png") : (fileLocation + "head.png")
        scale: 0
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

        opacity: 0
        transform: Translate {
            id: healthBarTransform
            x: -healthBar.width
            y: 0
        }
    }


    Row {
        id: collectedItemsRow
        spacing: 7
        anchors.left: headImage.right
        anchors.top: healthBar.bottom
        anchors.leftMargin: 7
        anchors.topMargin: 7
        anchors.bottom: headImage.bottom
        opacity: 0
        z: parent.z - 1
        transform: Translate {
            id: collectedItemsTransform
            x: -collectedItemsRow.width
            y: 0
        }

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
                    width: height
                    source: Global.paths.images + "collectibles/kunai.png"
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
        transform: Translate {
            id: pauseButtonTransform
            x: -pauseButton.width - 36
            y: 0
        }

        text: Global.icons.fa_pause
        pixelSize: 24
    }

    Item {
        id: levelTimerDisplay
        anchors.right: parent.right
        anchors.topMargin: 10
        anchors.rightMargin: 18
        anchors.top: parent.top
        width: levelTimerRow.width
        transform: Translate {
            id: levelTimerDisplayTransform
            x: levelTimerDisplay.width + anchors.rightMargin + 60
            y: 0
        }

        Timer {
            id: levelTimer
            interval: 1000
            repeat: true
            running: !scene.gameOver

            onTriggered: {
                if(gameWindow.paused)
                    return;

                headsUpDisplay.elapsedTimeString = Global.toTimeString(headsUpDisplay.elapsedSeconds++);
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

        PauseAnimation { duration: 1000 }

        NumberAnimation {
            target: headImage
            property: "scale"
            to: 1
            easing.type: "OutBack"
            duration: 500
        }

        ParallelAnimation {
            NumberAnimation {
                target: healthBarTransform
                property: "x"
                to: 0
                easing.type: "OutBack"
                duration: 500
            }

            NumberAnimation {
                target: healthBar
                property: "opacity"
                to: 1
                easing.type: "OutBack"
                duration: 500
            }

            NumberAnimation {
                target: collectedItemsTransform
                property: "x"
                to: 0
                easing.type: "OutBack"
                duration: 700
            }

            NumberAnimation {
                target: collectedItemsRow
                property: "opacity"
                to: 1
                duration: 700
            }
        }

        ParallelAnimation {
            NumberAnimation {
                target: pauseButtonTransform
                property: "x"
                to: 0
                easing.type: "OutBack"
                duration: 250
            }

            NumberAnimation {
                target: levelTimerDisplayTransform
                property: "x"
                to: 0
                easing.type: "OutBack"
                duration: 250
            }
        }

        ScriptAction { script: collectedItemsRow.resetTransform() }
    }

    function stopTimer() {
        levelTimer.stop();
    }
}

