import QtQuick 2.9
import Bacon2D 1.0
import Seppuku 1.0
import "../singletons"

Rectangle {
    id: tutorText
    width: 500
    height: timedText.height + 10
    z: Utils.zTutor
    color: "#cc0d66ff"
    opacity: timedText.opacity

    QtObject {
        id: privateProperties

        property string text: ""
        property int displayDuration: 0
        property var textList: []
        property var iconMap: {
            "{up_arrow_key}": "<img src='" + Global.paths.images + "input/keyboard/key_arrow_up.png' width='30' height='30'>",
            "{down_arrow_key}": "<img src='" + Global.paths.images + "input/keyboard/key_arrow_down.png' width='30' height='30'>",
            "{left_arrow_key}": "<img src='" + Global.paths.images + "input/keyboard/key_arrow_left.png' width='30' height='30'>",
            "{right_arrow_key}": "<img src='" + Global.paths.images + "input/keyboard/key_arrow_right.png' width='30' height='30'>",
            "{a_button}": "<img src='" + Global.paths.images + "input/keyboard/key_arrow_up.png' width='30' height='30'>",
            "{z_key}": "<img src='" + Global.paths.images + "input/keyboard/key_z.png' width='30' height='30'>"
        }

        property int messageCount: 0

        function displayText(text, duration) {
            if(duration < 0 || duration === undefined)
                duration = 3000;

            privateProperties.text = text;
            privateProperties.displayDuration = duration;
            if (displayAnimation.running)
                displayAnimation.restart();
            else
                displayAnimation.start();
        }

        function switchText() {
            privateProperties.textList.shift();
            if(privateProperties.messageCount > 0)
                privateProperties.messageCount--;

            if(privateProperties.textList.length > 0)
                privateProperties.displayText(textList[0]["text"], textList[0]["duration"]);
        }
    }

    Text {
        id: timedText
        anchors.centerIn: parent
        color: "white"
        font.pixelSize: 20
        font.family: Stylesheet.tutorFontFamily
        text: privateProperties.text
        width: parent.width
        height: contentHeight
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter
        wrapMode: Text.WordWrap

        SequentialAnimation {
            id: displayAnimation

            PropertyAction { target: timedText; property: "scale"; value: 0 }
            PropertyAction { target: timedText; property: "opacity"; value: 0 }
            PropertyAction { target: timedText; property: "rotation"; value: 0 }

            ParallelAnimation {
                NumberAnimation { target: timedText; properties: "scale, opacity"; to: 1; easing.type: Easing.InOutQuad; duration: 500 }
                NumberAnimation { target: timedText; properties: "rotation"; to: 360; easing.type: Easing.InOutQuad; duration: 500 }
            }

            PauseAnimation { duration: privateProperties.displayDuration }

            ParallelAnimation {
                NumberAnimation { target: timedText; properties: "scale, opacity"; to: 0; easing.type: Easing.InOutQuad; duration: 500 }
                NumberAnimation { target: timedText; properties: "rotation"; to: 0; easing.type: Easing.InOutQuad; duration: 500 }
            }

            ScriptAction { script: privateProperties.switchText(); }
        }

        states: State {
            name: "hidden"
            when: !displayAnimation.running

            PropertyChanges {
                target: timedText
                scale: 0
                opacity: 0
                rotation: 0
            }
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

    function queueText(text, duration) {
        if(text.trim() === "")
            return;
        if(duration < 0 || duration === undefined || duration === null)
            duration = 3000;

        privateProperties.textList.push({ text: formatText(text), duration: duration });
        privateProperties.messageCount++;
    }

    function formatText(text) {
        var matches = text.match(/\{(.*?)\}/gi); // Match anything like this -> {example}

        if (matches !== null)
            for (var i = 0; i < matches.length; ++i)
                text = text.replace(matches[i], privateProperties.iconMap[matches[i]]);

        return text;
    }

    function startDisplay() {
        if(privateProperties.textList[0] === undefined)
            return;
        if(privateProperties.textList[0]["text"] === undefined)
            return;
        if (isQueueEmpty())
            return;

        var text = privateProperties.textList[0]["text"];
        var duration = privateProperties.textList[0]["duration"];
        privateProperties.displayText(text, duration);
    }

    function clear() { privateProperties.textList = []; }

    function stopAndClear() {
        displayAnimation.stop();
        clear();
    }

    function isQueueEmpty() { return privateProperties.textList.length == 0; }

    Connections {
        target: Global.gameWindow
        onGameStateChanged: {
            switch(Global.gameWindow.gameState) {
            case Bacon2D.Paused:
            case Bacon2D.Inactive:
            case Bacon2D.Suspended:
                if (displayAnimation.running)
                    displayAnimation.pause();
                break
            default:
                if (displayAnimation.paused)
                    displayAnimation.resume();
                break
            }
        }
    }
}

