import QtQuick 2.9
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0
import Seppuku 1.0
import "../singletons"

Slider {
    id: gameSlider
    value: .5
    width: 120
    height: handle.height
    stepSize: .05

    handle: Image {
        x: gameSlider.leftPadding + gameSlider.visualPosition * (gameSlider.availableWidth - width)
        y: gameSlider.topPadding + gameSlider.availableHeight / 2 - height / 2
        width: 36
        sourceSize: Qt.size(width, height)
        fillMode: Image.PreserveAspectFit

        source: {
            if(gameSlider.pressed)
                Global.paths.images + "buttons/_click_button.png";
            else if(gameSlider.hovered)
                Global.paths.images + "buttons/_hover_button.png";
            else
                Global.paths.images + "buttons/_normal_button.png";
        }

        Text {
            id: handleText
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -2
            width: contentWidth
            height: contentHeight

            color: "white"
            text: Global.icons.fa_angle_left + Global.icons.fa_angle_right
            font.family: Global.iconFont
            font.bold: true
            font.pixelSize: 34

            style: Text.Outline;
            styleColor: {
                if(!gameSlider.enabled)
                    "#828282";
                else if(gameSlider.pressed)
                    "#e5233a";
                else if(gameSlider.hovered || gameSlider.activeFocus)
                    "#6dde01";
                else
                    "#009bff";
            }

            SequentialAnimation on color {
                running: false
                loops: Animation.Infinite

                ColorAnimation { to: Qt.lighter("gray"); duration: 500 }
                ColorAnimation { to: "white"; duration: 500 }

                onRunningChanged: handleText.color = "white";
            }
        }
    }

    background: Item {
        implicitWidth: gameSlider.width
        implicitHeight: gameSlider.height

        Rectangle {
            id: grooveBar
            anchors.verticalCenter: parent.verticalCenter
            visible: false // to make the mask show
            width: parent.width
            height: 12
            color: "#EFB469"
        }

        Rectangle {
            id: mask
            anchors.verticalCenter: parent.verticalCenter
            width: grooveBar.width
            height: grooveBar.height

            color: "black"
            radius: 5
            clip: true
            visible: false // to make the mask show
        }

        OpacityMask {
            id: grooveBarMask
            anchors.verticalCenter: parent.verticalCenter
            width: mask.width
            height: mask.height
            source: grooveBar
            maskSource: mask
        }
    }

    Keys.onLeftPressed: gameSlider.decrease();
    Keys.onRightPressed: gameSlider.increase();
}
