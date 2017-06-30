import QtQuick 2.9
import QtMultimedia 5.0
import "../singletons"
import Seppuku 1.0

Item {
    id: root
    width: 30
    height: width

    property int duration: 5000
    property color backgroundColor: "white"
    property color textColor: {
        switch(theme) {
        case "yellow":
            "gold";
            break;
        case "red":
            "red";
            break;
        case "green":
            "green";
            break;
        default:
            "blue";
            break;
        }
    }
    property color color: {
        switch(theme) {
        case "green":
            "lightgreen";
            break;
        case "red":
            "pink";
            break;
        case "yellow":
            "lightslategray";
            break;
        default:
            "lightsteelblue";
            break;
        }
    }
    property string theme: "blue"
    property int pixelSize: 18


    readonly property real chunk: timer.interval / duration * 360
    readonly property int countdown: Math.floor((root.duration - privateProperties.elapsed) / 1000)

    signal timeout

    QtObject {
        id: privateProperties

        property real angle: 0
        property int elapsed: 0
    }

    Rectangle {
        id: backCircle
        anchors.fill: parent
        color: root.backgroundColor
        radius: width / 2

        Timer {
            id: timer
            running: false
            repeat: true
            interval: 20

            onTriggered: {
                if(privateProperties.angle + root.chunk >= 360) {
                    privateProperties.angle = 360;
                    repeat = false;
                    root.timeout();
                    root.reset();
                }
                else {
                    privateProperties.angle += root.chunk;
                    privateProperties.elapsed += timer.interval;
                    canvas.requestPaint();
                }
            }
        }

        Canvas {
            id: canvas
            anchors.fill: parent

            onPaint: {
                var context = canvas.getContext('2d')

                if(privateProperties.angle == 0)
                    context.reset();

                context.save();
                var centerX = Math.floor(canvas.width / 2);
                var centerY = Math.floor(canvas.height / 2);
                var radius = Math.floor(canvas.width / 2);

                var startingAngle = degreesToRadians(-90);
                var arcSize = degreesToRadians(privateProperties.angle);
                var endingAngle = startingAngle + arcSize;

                context.beginPath();
                context.moveTo(centerX, centerY);
                context.arc(centerX, centerY, radius,
                            startingAngle, endingAngle, false);
                context.closePath();

                context.fillStyle = root.color;
                context.fill();

                context.restore();
            }

            function degreesToRadians(degrees) {
                return (degrees * Math.PI)/180;
            }
        }

        Text {
            anchors.centerIn: parent
            color: root.textColor
            width: contentWidth
            height: contentHeight
            text: root.countdown
            font.pixelSize: root.pixelSize
            font.family: Global.defaultFont
            visible: timer.running
        }

        Text {
            anchors.centerIn: parent
            color: root.textColor
            width: contentWidth
            height: contentHeight
            text: Global.icons.fa_clock_o //fa_hourglass_o
            font.pixelSize: root.pixelSize * 1.2
            font.family: Global.iconFont
            visible: !timer.running
        }
    }

    SoundEffect {
        id: effect
        source: Global.paths.sounds + "pickup.wav"
    }

    MouseArea {
        anchors.fill: parent

        onClicked: root.start();
    }

    function reset() {
        timer.stop();
        privateProperties.angle = 0;
        privateProperties.elapsed = 0;
        timer.repeat = true;
        canvas.requestPaint();
    }

    function start() {
        if(root.duration == 0)
            return;

        reset();
        timer.start();
    }
}
