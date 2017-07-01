import QtQuick 2.9
import Seppuku 1.0
import "../singletons"

Image {
    id: gameButton
    width: buttonText.width + 48
    height: buttonText.height + 6

    source: {
        if(!gameButton.enabled)
            Global.paths.images + "buttons/locked_button.png";
        else if(area.pressed)
            Global.paths.images + "buttons/click_button.png";
        else if(area.containsMouse)
            Global.paths.images + "buttons/hover_button.png";
        else
            Global.paths.images + "buttons/normal_button.png";
    }

    property alias text: buttonText.text
    property alias font: buttonText.font
    signal clicked

    Text {
        id: buttonText
        width: contentWidth
        height: contentHeight
        anchors.centerIn: parent

        text: "normal"
        color: "white"

        font {
            family: Stylesheet.defaultFontFamily
            pixelSize: 36
            capitalization: Font.AllLowercase
        }

        style: Text.Outline;
        styleColor: {
            if(!gameButton.enabled)
                "#828282";
            else if(area.pressed)
                "#e5233a";
            else if(area.containsMouse || gameButton.activeFocus)
                "#6dde01";
            else
                "#009bff";
        }

        SequentialAnimation on color {
            running: false
            loops: Animation.Infinite

            ColorAnimation { to: Qt.lighter("gray"); duration: 500 }
            ColorAnimation { to: "white"; duration: 500 }

            onRunningChanged: buttonText.color = "white";
        }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        enabled: gameButton.enabled
        onClicked: gameButton.clicked();
    }

    Keys.onReturnPressed: gameButton.clicked();
}

