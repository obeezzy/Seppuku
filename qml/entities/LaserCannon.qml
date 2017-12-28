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
    z: Utils.zLaser
    sender: "laser_cannon"
    entityType: "laserCannon"

    fixtures: Box {
        width: target.width
        height: target.height
        density: .5
        categories: Utils.kGround | Utils.kGroundTop
    }

    readonly property int laserWidth: (direction == "left" || direction == "right") ? laserRay.pXDiff * privateProperties.maxFraction : laserCannon.width
    readonly property int laserHeight: (direction == "up" || direction == "down") ? laserRay.pYDiff * privateProperties.maxFraction: laserCannon.height
    readonly property int rayMargin: 4
    readonly property bool firing: privateProperties.firing

    property alias imageSource: laserCannonImage.source
    property alias imageRotation: laserCannonImage.rotation
    property string direction: "right";
    property string laserColor: "red"
    property int fireInterval: 2000
    property int ceaseInterval: 1000
    property int startupDelay: 100
    property LaserLever laserLever: null

    QtObject {
        id: privateProperties

        property bool firing: (laserLever != null && laserLever.position == "on") || ceaseInterval == 0
        property real maxFraction: 1
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
        id: laserRay

        readonly property int multiplier: 6
        readonly property int pXDiff: Math.abs(p2.x - p1.x)
        readonly property int pYDiff: Math.abs(p2.y - p1.y)
        property real closestFraction: 1
        property string closestEntity: ""

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

        onFixtureReported: {
            if((fixture.categories & Utils.kGround) && fixture.type !== "one_way_platform") {
                if (closestFraction > fraction) {
                    closestFraction = fraction;
                    closestEntity = "ground";
                }

                laserRay.maxFraction = fraction;
                privateProperties.maxFraction = Math.abs(fraction);
            } else if ((fixture.categories & Utils.kHero) && fixture.type === "main_body") {
                if (closestFraction > fraction) {
                    closestFraction = fraction;
                    closestEntity = "hero";
                }

                laserRay.maxFraction = fraction;
                privateProperties.maxFraction = Math.abs(fraction);
            }
        }

        function cast() {
            // If hero is detected first by the laser, then stun hero.
            if(closestEntity === "hero" && !hero.dead)
                hero.stun(laserCannon.sender);

            closestFraction = 1;
            closestEntity = "";
            scene.rayCast(this, p1, p2); }
    }

    Timer {
        id: laserRayTimer
        running: !Global.gameWindow.paused
        repeat: true
        interval: 50

        onTriggered: {
            if(privateProperties.firing)
                laserRay.cast();
        }
    }

    PausableTimer {
        id: fireTimer
        running: !Global.gameWindow.paused && laserCannon.laserLever == null && laserCannon.ceaseInterval != 0
        interval: laserCannon.startupDelay
        onTriggered: {
            if (privateProperties.firing)
                interval = laserCannon.ceaseInterval;
            else
                interval = laserCannon.fireInterval;

            privateProperties.firing = !privateProperties.firing;
            start();
        }
    }

    Image {
        id: laserCannonImage
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
        visible: opacity > 0
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
        target: laserLever
        onPositionChanged: privateProperties.firing = laserLever.position == "on";
    }
}
