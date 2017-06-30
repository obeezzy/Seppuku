import QtQuick 2.0
import Seppuku 1.0
import "../singletons"

PlainNarrowSlate {
    id: questionSlate

    property string text: ""
    signal yesClicked
    signal noClicked

    content: FocusScope {
        Column {
            anchors {
                left: parent.left
                right: parent.right
            }

            spacing: 50

            Text {
                id: questionText
                width: parent.width
                height: contentHeight

                text: questionSlate.text
                color: "white"
                wrapMode: Text.WordWrap

                font.family: Global.defaultFont
                font.pixelSize: 21
            }

            Column {
                width: parent.width
                spacing: 12

                GameButton {
                    id: closingYesButton
                    text: qsTr("yes")
                    fontFamily: Global.defaultFont
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: questionSlate.yesClicked();

                    KeyNavigation.down: closingNoButton
                }

                GameButton {
                    id: closingNoButton
                    text: qsTr("no")
                    focus: true
                    fontFamily: Global.defaultFont
                    width: closingYesButton.width
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: questionSlate.noClicked();

                    KeyNavigation.up: closingYesButton
                }
            }
        }
    }
}
