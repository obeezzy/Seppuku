import QtQuick 2.9
import Bacon2D 1.0
import Seppuku 1.0
import "../singletons"
import QtMultimedia 5.0
import "../gui"
import "../sprites"

EntityBase {
    id: laserLever
    entityType: "laserLever"

    property string color: "blue"
    property string position: "off"
    property int duration: 0
    property bool mirror: false
    property int laserLink: 0

    readonly property string type: "lever"

    QtObject {
        id: privateProperties

        property bool inRange: false
    }

    width: 40
    height: 40
    bodyType: Body.Static
    sleepingAllowed: false
    z: Utils.zInteractive

    fixtures: Box {
        width: target.width
        height: target.height
        sensor: true
        categories: Utils.kInteractive

        readonly property string type: laserLever.type
        readonly property bool mirror: laserLever.mirror

        onBeginContact: {
            if(other.categories & Utils.kHero)
                privateProperties.inRange = true;
        }

        onEndContact: {
            if(other.categories & Utils.kHero)
                privateProperties.inRange = false;
        }
    }

    Loader {
        id: laserLeverLoader
        anchors.fill: parent
        sourceComponent: {
            switch (laserLever.color + "_switch_" + laserLever.position) {
            case "blue_switch_off":
                blueSwitchOff
                break;
            case "blue_switch_on":
                blueSwitchOn
                break;
            case "green_switch_off":
                greenSwitchOff
                break;
            case "green_switch_on":
                greenSwitchOn
                break;
            case "red_switch_off":
                redSwitchOff
                break;
            case "red_switch_on":
                redSwitchOn
                break;
            case "yellow_switch_off":
                yellowSwitchOff
                break;
            case "yellow_switch_on":
                yellowSwitchOn
                break;
            }
        }

        Component {
            id: blueSwitchOff
            LaserSprite { horizontalMirror: laserLever.mirror; frameX: 140; frameY: 210; frameWidth: 70; frameHeight: 70 }
        }

        Component {
            id: blueSwitchOn
            LaserSprite { horizontalMirror: laserLever.mirror; frameX: 210; frameY: 210; frameWidth: 70; frameHeight: 70 }
        }

        Component {
            id: greenSwitchOff
            LaserSprite { horizontalMirror: laserLever.mirror; frameX: 280; frameY: 210; frameWidth: 70; frameHeight: 70 }
        }

        Component {
            id: greenSwitchOn
            LaserSprite { horizontalMirror: laserLever.mirror; frameX: 0; frameY: 280; frameWidth: 70; frameHeight: 70 }
        }

        Component {
            id: redSwitchOff
            LaserSprite { horizontalMirror: laserLever.mirror; frameX: 70; frameY: 280; frameWidth: 70; frameHeight: 70 }
        }

        Component {
            id: redSwitchOn
            LaserSprite { horizontalMirror: laserLever.mirror; frameX: 140; frameY: 280; frameWidth: 70; frameHeight: 70 }
        }

        Component {
            id: yellowSwitchOff
            LaserSprite { horizontalMirror: laserLever.mirror; frameX: 210; frameY: 280; frameWidth: 70; frameHeight: 70 }
        }

        Component {
            id: yellowSwitchOn
            LaserSprite { horizontalMirror: laserLever.mirror; frameX: 280; frameY: 280; frameWidth: 70; frameHeight: 70 }
        }
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
           running: privateProperties.inRange && !Global.gameWindow.paused
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
        target: hero
//        onUtilized: {
//            if(type == laserLever.type && privateProperties.inRange)
//            {
//                switch(position) {
//                case "on":
//                    position = "off";
//                    timerPie.start();
//                    break;
//                default:
//                    position = "on";
//                    timerPie.reset();
//                    break;
//                }

//                effect.play();
//            }
//        }
    }
}

