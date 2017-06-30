import QtQuick 2.9
import Bacon2D 1.0
import QtMultimedia 5.9
import Seppuku 1.0
import "../singletons"

EntityBase {
    id: laserCannon
    bodyType: Body.Static
    width: 98
    height: 37
    z: Global.zLaser
    sender: "laser_cannon"

    fixtures: Box {
        width: laserCannon.width
        height: laserCannon.height
        density: .5
        categories: Global.kGround | Global.kGroundTop
    }

    readonly property int laserWidth: (direction == "left" || direction == "right") ? sensorRay1.pXDiff : laserCannon.width
    readonly property int laserHeight: (direction == "up" || direction == "down") ? sensorRay1.pYDiff : laserCannon.height
    readonly property int rayMargin: 4
    readonly property string laserFileLocation: ""
    readonly property string fileName: ""

    property string direction: "right";
    property string laserColor: "red"
    property bool __firing: lever != null && lever.position == "on"
    property int fireInterval: 2000
    property int ceaseInterval: 1000
    property int startupDelay: 100
    property LaserLever lever: null

    QtObject {
        id: privateProperties

        property bool firing: lever != null && lever.position == "on"
    }

    Image {
        id: laser
        width: laserCannon.laserWidth
        height: laserCannon.laserHeight
        fillMode: {
            switch(direction) {
            case "up":
            case "down":
                Image.TileVertically;
                break;
            default:
                Image.TileHorizontally;
            }
        }
        smooth: true
        visible: privateProperties.firing ? 1 : 0
        rotation: {
            switch(direction) {
            case "left":
            case "up":
                180;
                break;
            default: // right and down
                0;
                break;
            }
        }
        transformOrigin: {
            switch(direction) {
            case "left":
                Item.Left
                break;
            case "up":
                Item.Top
                break;
            default: // right
                Item.Center;
            }
        }
        x: {
            switch(direction) {
            case "left":
                4;
                break;
            case "right":
                laserCannon.width - 4 // margin of error
                break;
            default: // up and down
                0;
            }
        }
        y: {
            switch(direction) {
            case "up":
                4;
                break;
            case "down":
                laserCannon.height - 4 // margin of error
                break;
            default: // left and right
                0;
            }
        }

        source: {
            switch(laserColor) {
            case "green":
                if(direction == "left" || direction == "right")
                    Global.paths.images + "machines/laserGreenHorizontal.png";
                else
                    Global.paths.images + "machines/laserGreenVertical.png";
                break;
            case "blue":
                if(direction == "left" || direction == "right")
                    Global.paths.images + "machines/laserBlueHorizontal.png";
                else
                    Global.paths.images + "machines/laserBlueVertical.png";
                break;
            case "yellow":
                if(direction == "left" || direction == "right")
                    Global.paths.images + "machines/laserYellowHorizontal.png";
                else
                    Global.paths.images + "machines/laserYellowVertical.png";
                break;
            default:
                if(direction == "left" || direction == "right")
                    Global.paths.images + "machines/laserRedHorizontal.png";
                else
                    Global.paths.images + "machines/laserRedVertical.png";
                break;
            }
        }

//        Rectangle {
//            id: laserBorder
//            anchors.fill: parent
//            color: "transparent"
//            border.width: 3
//            border.color: "lightsteelblue"
//        }
    }

    RayCast {
        id: sensorRay1
        property point p1: {
            switch(direction) {
            case "up":
                Qt.point(laserCannon.x + laserCannon.width / 2 - rayMargin, laserCannon.y);
                break;
            case "down":
                Qt.point(laserCannon.x + laserCannon.width / 2 - rayMargin, laserCannon.y + laserCannon.height);
                break;
            case "left":
                Qt.point(laserCannon.x, laserCannon.y + laserCannon.height / 2 - rayMargin);
                break;
            default: // right
                Qt.point(laserCannon.x + laserCannon.width, laserCannon.y + laserCannon.height / 2 - rayMargin);
                break;
            }
        }
        property point p2: {
            switch(direction) {
            case "up":
                Qt.point(p1.x, laserCannon.y - laserCannon.height * multiplier);
                break;
            case "down":
                Qt.point(p1.x, laserCannon.y + laserCannon.height * multiplier);
                break;
            case "left":
                Qt.point(laserCannon.x - laserCannon.width * multiplier, p1.y);
                break;
            default: // right
                Qt.point(laserCannon.x + laserCannon.width + laserCannon.width * multiplier, p1.y);
                break;
            }
        }

        readonly property int multiplier: 8
        readonly property int pXDiff: Math.abs(p2.x - p1.x)
        readonly property int pYDiff: Math.abs(p2.y - p1.y)

        onFixtureReported: {
            if (fixture.categories & Global.kActor && fixture.type === "main_body") {
                if(!actor.dead)
                    actor.stun(laserCannon.sender);
            }
            else if(fixture.categories & Global.kGround) {
                switch(direction) {
                case "up":
                case "down":
                    p2.y = point.y;
                    break;
                default:
                    if(fixture.x === undefined)
                        p2.x = point.x - 6;
                    else
                        p2.x = fixture.x + point.x - 6;
                    break;
                }
            }
        }

        function cast() {
            scene.rayCast(this, p1, p2);
        }
    }

    RayCast {
        id: sensorRay2
        property point p1: {
            switch(direction) {
            case "up":
                Qt.point(laserCannon.x + laserCannon.width / 2 - rayMargin, laserCannon.y);
                break;
            case "down":
                Qt.point(laserCannon.x + laserCannon.width / 2 + rayMargin, laserCannon.y + laserCannon.height);
                break;
            case "left":
                Qt.point(laserCannon.x, laserCannon.y + laserCannon.height / 2 + rayMargin);
                break;
            default: // right
                Qt.point(laserCannon.x + laserCannon.width, laserCannon.y + laserCannon.height / 2 + rayMargin);
                break;
            }
        }
        property point p2: {
            switch(direction) {
            case "up":
                Qt.point(p1.x, laserCannon.y - laserCannon.height * multiplier);
                break;
            case "down":
                Qt.point(p1.x, laserCannon.y + laserCannon.height * multiplier)
                break;
            case "left":
                Qt.point(laserCannon.x - laserCannon.width * multiplier, p1.y);
                break;
            default:
                Qt.point(laserCannon.x + laserCannon.width + laserCannon.width * multiplier, p1.y);
                break;
            }
        }

        readonly property int multiplier: 6
        readonly property int pXDiff: Math.abs(p2.x - p1.x)
        readonly property int pYDiff: Math.abs(p2.y - p1.y)

        onFixtureReported: {
            if (fixture.categories & Global.kActor && fixture.type === "main_body") {
                if(!actor.dead)
                    actor.stun(laserCannon.sender);
            }
            else if(fixture.categories & Global.kGround) {
//                switch(direction) {
//                case "up":
//                case "down":
//                    break;
//                default:
//                    p2.x = fixture.x + point.x - 6;
//                    break;
//                }
            }
        }

        function cast() {
            scene.rayCast(this, p1, p2);
//            console.log("p1=", p1);
//            console.log("p2=", p2);
        }
    }

    Timer {
        id: rayTimer
        running: !Global.gameWindow.paused
        repeat: true
        interval: 50

        onTriggered: {
            if(privateProperties.firing)
            {
                sensorRay1.cast();
                sensorRay2.cast();
            }
        }
    }

    Timer {
        id: startupDelayTimer
        running: laserCannon.lever == null
        repeat: false
        interval: startupDelay

        onTriggered: {
            fireTimer.start();
            privateProperties.firing = true;
        }
    }

    Timer {
        id: fireTimer
        running: false
        repeat: false
        interval: fireInterval

        onTriggered: {
            privateProperties.firing = false;
            ceaseTimer.start();
        }
    }

    Timer {
        id: ceaseTimer
        running: false
        repeat: false
        interval: ceaseInterval

        onTriggered: {
            privateProperties.firing = true;
            fireTimer.start();
        }
    }

    Image {
        id: image
        anchors.fill: parent
        source: {
            switch(direction) {
            case "up":
                privateProperties.firing ? (Global.paths.images + "machines/laserUpShoot.png") : (Global.paths.images + "machines/laserUp.png");
                break;
            case "down":
                privateProperties.firing ? (Global.paths.images + "machines/laserDownShoot.png") : (Global.paths.images + "machines/laserDown.png");
                break;
            case "left":
                privateProperties.firing ? (Global.paths.images + "machines/laserLeftShoot.png") : (Global.paths.images + "machines/laserLeft.png");
                break;
            default: // right
                privateProperties.firing ? (Global.paths.images + "machines/laserRightShoot.png") : (Global.paths.images + "machines/laserRight.png");
                break;
            }
        }
    }

    Image {
        id: hitImage
        opacity: privateProperties.firing ? 1 : 0
        z: laser.z + 1
        x: {
            switch(direction) {
            case "up":
            case "down":
                0
                break;
            case "left":
                -laser.width - width / 2;
                break;
            default:
                laser.width + width / 2;
            }
        }
        y: {
            switch(direction) {
            case "up":
                -laser.height - height / 2;
                break;
            case "down":
                laser.height + height / 2;
                break;
            default:
                0
                break;
            }
        }
        width: {
            switch(direction) {
            case "up":
            case "down":
                laser.width;
                break;
            default: // left and right
                laser.height;
                break;
            }
        }
        height: {
            switch(direction) {
            case "up":
            case "down":
                laser.width;
                break;
            default: // left and right
                laser.height;
                break;
            }
        }

        source: {
            switch(laserColor) {
            case "blue":
                Global.paths.images + "machines/laserBlueBurst.png";
                break;
            case "yellow":
                Global.paths.images + "machines/laserYellowBurst.png";
                break;
            case "green":
                Global.paths.images + "machines/laserGreenBurst.png";
                break;
            default: // red
                Global.paths.images + "machines/laserRedBurst.png";
            }
        }

//        Rectangle {
//            id: hitBorder
//            anchors.fill: parent
//            color: "transparent"
//            border.width: 3
//            border.color: "lightsteelblue"
//        }

        Behavior on opacity { NumberAnimation { } }
    }

    SoundEffect {
        id: shotSound
        source: Global.paths.sounds + "laser_sound.wav"
        muted: Global.settings.noSound
        volume: 0
    }

    Connections {
        target: lever

        onPositionChanged: privateProperties.firing = lever.position == "on";
    }
}
