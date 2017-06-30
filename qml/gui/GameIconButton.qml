import QtQuick 2.9
import Seppuku 1.0
import "../singletons"

Image {
    id: gameIconButton
    width: 48
    fillMode: Image.PreserveAspectFit
    mipmap: true
    smooth: true

    property string iconName: ""

    source: {
        if(!gameIconButton.enabled)
            Global.paths.images + "buttons/" + iconName + "_locked_button.png";
        else if(area.pressed)
            Global.paths.images + "buttons/" + iconName + "_click_button.png";
        else if(area.containsMouse)
            Global.paths.images + "buttons/" + iconName + "_hover_button.png";
        else
            Global.paths.images + "buttons/" + iconName + "_normal_button.png";
    }

    property alias text: buttonText.text
    property alias pixelSize: buttonText.font.pixelSize
    property bool currentFocus: false
    signal clicked

    Text {
        id: buttonText
        width: contentWidth
        height: contentHeight
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -2
        visible: iconName == ""

        text: Global.icons.fa_android
        color: "white"

        font.family: Global.iconFont
        font.pixelSize: 38

        style: Text.Outline;
        styleColor: {
            if(!gameIconButton.enabled)
                "#828282";
            else if(area.pressed)
                "#e5233a";
            else if(area.containsMouse || gameIconButton.activeFocus)
                "#6dde01";
            else
                "#009bff";
        }

        SequentialAnimation on color {
            running: currentFocus
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
        enabled: gameIconButton.enabled
        onClicked: gameIconButton.clicked();
    }

    Keys.onReturnPressed: gameIconButton.clicked();
}

