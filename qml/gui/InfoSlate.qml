import QtQuick 2.9
import Seppuku 1.0
import "../singletons"

WideSlate {
    id: infoSlate
    width: 480

    title: qsTr("Hint")
    styleColor: "red" //"#F0C961"
    property string text: "Info text goes here"

    content: Item {
        Text {
            id: infoText
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                bottom: dismissText.top
                topMargin: 7
            }

            font {
                family: Stylesheet.hintFontFamily
                pixelSize: 21
            }
            color: "white"
            text: infoSlate.text
            wrapMode: Text.WordWrap
            style: Text.Outline;
            //styleColor: "#F0C961"
            styleColor: "crimson"
            verticalAlignment: Qt.AlignVCenter
            horizontalAlignment: Qt.AlignHCenter
        }

        Text {
            id: dismissText
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }

            font {
                family: Stylesheet.casualFontFamily
                pixelSize: 16
                bold: true
            }

            color: "crimson"
            horizontalAlignment: Qt.AlignRight
            text: qsTr("Press \"Z\" to dismiss.")
        }
    }
}

