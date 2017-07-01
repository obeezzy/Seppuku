import QtQuick 2.9
import Seppuku 1.0
import QtMultimedia 5.9
import "../singletons"

Image {
    id: gameShortButton
    width: 48
    fillMode: Image.PreserveAspectFit
    mipmap: true

    source: {
        if(!gameShortButton.enabled)
            Global.paths.images + "buttons/_locked_button.png";
        else if(area.pressed)
            Global.paths.images + "buttons/_click_button.png";
        else if(area.containsMouse)
            Global.paths.images + "buttons/_hover_button.png";
        else
            Global.paths.images + "buttons/_normal_button.png";
    }

    property alias text: buttonText.text
    property alias fontFamily: buttonText.font.family
    property bool currentFocus: false
    signal clicked

    Text {
        id: buttonText
        width: contentWidth
        height: contentHeight
        anchors.centerIn: parent

        text: ""
        color: "white"

        font.family: Stylesheet.defaultFontFamily
        font.pixelSize: 36

        style: Text.Outline;
        styleColor: {
            if(!gameShortButton.enabled)
                "#828282";
            else if(area.pressed)
                "#e5233a";
            else if(area.containsMouse || gameShortButton.activeFocus)
                "#6dde01";
            else
                "#009bff";
        }

        SequentialAnimation on color {
            running: currentFocus
            loops: Animation.Infinite

            ColorAnimation { to: Qt.lighter("gray"); duration: 500 }
            ColorAnimation { to: "white"; duration: 500 }

            onRunningChanged: buttonText.color = "white"
        }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        enabled: gameShortButton.enabled
        onClicked: gameShortButton.clicked();
    }

    Keys.onReturnPressed: gameShortButton.clicked();
}

