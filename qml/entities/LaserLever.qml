import QtQuick 2.9
import Bacon2D 1.0
import Seppuku 1.0
import "../singletons"
import QtMultimedia 5.0
import "../gui"

EntityBase {
    id: laserLever
    width: 40
    height: 40
    bodyType: Body.Static
    sleepingAllowed: false
    z: Utils.zInteractive

    property string color: "blue"
    property string position: "off"
    property int duration: 0
    property bool mirror: false

    readonly property string type: "lever"
    readonly property string fileLocation: Global.paths.images + "switches/"
    readonly property string fileName: fileLocation + "laser_switch_" + color + "_" + laserLever.position + ".png"

    QtObject {
        id: privateProperties

        property bool inRange: false
    }

    fixtures: Box {
        width: target.width
        height: target.height
        sensor: true
        categories: Utils.kInteractive

        readonly property string type: laserLever.type
        readonly property bool mirror: laserLever.mirror

        onBeginContact: {
            console.log("Type? ", other.type)
            if(other.categories & Utils.kActor)
                privateProperties.inRange = true;
        }

        onEndContact: {
            if(other.categories & Utils.kActor)
                privateProperties.inRange = false;
        }
    }

    Image {
        anchors.fill: parent
        source: fileName
        mirror: laserLever.mirror
    }

    TimerPie {
        id: timerPie
        visible: laserLever.duration != 0
        anchors.left: parent.right
        anchors.top: parent.top
        duration: laserLever.duration
        theme: laserLever.color

        onTimeout: {
            laserLever.position = "on";
            effect.play();
        }
    }

    Rectangle {
        id: indicator
       color: "transparent"
       border.color: "skyblue"
       border.width: 3
       width: parent.width
       height: width
       visible: privateProperties.inRange ? true : false
       radius: width

       SequentialAnimation on scale {
           loops: Animation.Infinite
           running: privateProperties.inRange && !gameWindow.paused? true : false
           NumberAnimation { from: .1; to: 2; duration: 250 }
           NumberAnimation { from: 2; to: .1; duration: 250 }
       }
    }

    SoundEffect {
        id: effect
        source: Global.paths.sounds + "switch_" + laserLever.position + ".wav"
        volume: Global.settings.sfxVolume
        muted: Global.settings.noSound
    }

    Connections {
        target: actor
        onUtilized: {
            if(type == laserLever.type && privateProperties.inRange)
            {
                switch(position) {
                case "on":
                    position = "off";
                    timerPie.start();
                    break;
                default:
                    position = "on";
                    timerPie.reset();
                    break;
                }

                effect.play();
            }
        }
    }
}

