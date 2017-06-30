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
                topMargin: 7
            }

            font {
                family: Global.hintFont
                pixelSize: 21
            }
            color: "white"
            text: infoSlate.text
            wrapMode: Text.WordWrap
            style: Text.Outline;
            styleColor: "#F0C961"
        }
    }
}

