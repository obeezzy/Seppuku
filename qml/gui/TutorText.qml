import QtQuick 2.9
import Bacon2D 1.0
import Seppuku 1.0
import "../singletons"

Rectangle {
    id: tutorText
    width: 500
    height: bText.height + 10
    color: "#cc0d66ff"
    opacity: bText.opacity

    QtObject {
        id: privateProperties

        property string text: ""
        property int displayDuration: 0
        property var textList: []
        property bool paused: false
        property int messageCount: 0

        function pause() {
            paused = true;
            //timer.stop()
        }

        function resume() {
            paused = false;
            //timer.start()
        }

        function setText(text, duration) {
            if(duration < 0 || duration === undefined)
                duration = 3000;

            if(bText.state == "HIDE_TEXT") {
                privateProperties.text = text;
                privateProperties.displayDuration = duration;
                bText.state = "DISPLAY_TEXT";
                timer.start();
            }
            else {
                privateProperties.text = text;
                privateProperties.displayDuration = duration;
                timer.start();
            }
        }

        function switchText() {
            privateProperties.textList.shift();
            if(privateProperties.messageCount > 0)
                privateProperties.messageCount--;

            if(privateProperties.textList.length > 0) {
                privateProperties.text = privateProperties.textList[0]["text"];
                privateProperties.displayDuration = privateProperties.textList[0]["duration"];
                bText.state = "DISPLAY_TEXT";
                timer.start();
            }
        }
    }

    Text {
        id: bText
        anchors.centerIn: parent
        color: "white"
        font.pixelSize: 20
        font.family: Stylesheet.tutorFontFamily
        text: privateProperties.text
        width: parent.width
        height: contentHeight
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter
        state: "HIDE_TEXT"
        wrapMode: Text.WordWrap

        states: [
            State {
                name: "DISPLAY_TEXT"
                PropertyChanges {
                    target: bText
                    scale: 1
                    opacity: 1
                    rotation: 360
                }
            },

            State {
                name: "HIDE_TEXT"
                PropertyChanges {
                    target: bText
                    scale: 0
                    opacity: 0
                    rotation: 0
                }
            }
        ]

        transitions: [
            Transition {
                enabled: true

                NumberAnimation {
                    properties: "scale, opacity, rotation"
                    easing.type: Easing.InOutQuad
                    duration: 500
                }
            }
        ]


        // When the text is fully hidden . . .
        onScaleChanged: {
            if(scale != 0)
                return;

            privateProperties.switchText();
        }
    }

    Row {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 3
        spacing: 4

        Image {
            id: mailImage
            source: Global.paths.images + "misc/mail.png"
        }

        Text {
            id: msgsLeftText
            width: contentWidth
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            verticalAlignment: Qt.AlignVCenter
            text: privateProperties.messageCount - 1
            font.family: Stylesheet.defaultFontFamily
            font.bold: true
            font.pixelSize: 13
            color: "white"
        }
    }

    Timer {
        id: timer
        interval: privateProperties.displayDuration
        repeat: false
        running: false

        onTriggered: {
            if(tutorText.__paused) {
                repeat = true
                running = true
            }
            else {
                repeat = false
                bText.state = "HIDE_TEXT"
            }
        }
    }

    function queueText(text, duration) {
        if(text.trim() === "")
            return;
        if(duration < 0 || duration === undefined || duration == null)
            duration = 3000;

        privateProperties.textList.push({text: text, duration: duration})
        privateProperties.messageCount++
    }

    function startDisplay() {
        if(privateProperties.textList[0] === undefined)
            return;
        if(privateProperties.textList[0]["text"] === undefined)
            return;

        var text = privateProperties.textList[0]["text"];
        var duration = privateProperties.textList[0]["duration"];
        privateProperties.setText(text, duration)
    }

    function clearAll() {
        privateProperties.textList = []
    }

    Connections {
        target: Global.gameWindow

        onGameStateChanged: {
            switch(Global.gameWindow.gameState) {
            case Bacon2D.Suspended:
            case Bacon2D.Paused:
                privateProperties.pause();
                break;
            case Bacon2D.Running:
                privateProperties.resume();
                break;
            }
        }
    }
}

