import QtQuick 2.9
import "../gui"
import "../singletons"

PlainNarrowSlate {
    id: mainMenuSlate
    signal playRequested
    signal instructionsRequested
    signal optionsRequested
    signal quitRequested

    content: FocusScope {
        Column {
            anchors {
                left: parent.left
                right: parent.right
            }

            spacing: 10
            topPadding: 20

            GameButton {
                id: playButton
                text: "play"
                width: parent.width
                fontFamily: Global.defaultFont
                anchors.horizontalCenter: parent.horizontalCenter
                focus: true
                onClicked: mainMenuSlate.playRequested();

                KeyNavigation.down: instuctionsButton
            }

            GameButton {
                id: instuctionsButton
                text: "instructions"
                fontFamily: Global.defaultFont
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: mainMenuSlate.instructionsRequested();

                KeyNavigation.up: playButton
                KeyNavigation.down: optionsButton
            }

            GameButton {
                id: optionsButton
                text: "options"
                fontFamily: Global.defaultFont
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: mainMenuSlate.optionsRequested();

                KeyNavigation.up: instuctionsButton
                KeyNavigation.down: quitButton
            }

            GameButton {
                id: quitButton
                text: "quit"
                fontFamily: Global.defaultFont
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: mainMenuSlate.quitRequested();

                KeyNavigation.up: optionsButton
            }
        }
    }
}
