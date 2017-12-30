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

    property alias spriteAlias: laserCannonSprite.alias
    property alias spriteRotation: laserCannonSprite.rotation
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

    Sprite {
        id: laser
        width: laserCannon.laserWidth
        height: laserCannon.laserHeight
        source: Global.paths.images + "objectset/lasers.png"
        fillMode: {
            switch(direction) {
            case "up":
            case "down":
                Bacon2D.TileVertically;
                break;
            default:
                Bacon2D.TileHorizontally;
            }
        }
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

        aliases: [
            SpriteAlias {
                name: "laser_green_horizontal"
                frameX: 70; frameY: 70; frameWidth: 70; frameHeight: 70
            },

            SpriteAlias {
                name: "laser_green_vertical"
                frameX: 140; frameY: 70; frameWidth: 70; frameHeight: 70
            },

            SpriteAlias {
                name: "laser_blue_horizontal"
                frameX: 70; frameY: 0; frameWidth: 70; frameHeight: 70
            },

            SpriteAlias {
                name: "laser_blue_vertical"
                frameX: 140; frameY: 0; frameWidth: 70; frameHeight: 70
            },

            SpriteAlias {
                name: "laser_yellow_horizontal"
                frameX: 210; frameY: 350; frameWidth: 70; frameHeight: 70
            },

            SpriteAlias {
                name: "laser_yellow_vertical"
                frameX: 280; frameY: 350; frameWidth: 70; frameHeight: 70
            },

            SpriteAlias {
                name: "laser_red_horizontal"
                frameX: 210; frameY: 140; frameWidth: 70; frameHeight: 70
            },

            SpriteAlias {
                name: "laser_red_vertical"
                frameX: 280; frameY: 140; frameWidth: 70; frameHeight: 70
            }
        ]

        alias: {
            switch(laserColor) {
            case "green":
                if(direction == "left" || direction == "right")
                    "laser_green_horizontal"
                else
                    "laser_green_vertical"
                break;
            case "blue":
                if(direction == "left" || direction == "right")
                    "laser_blue_horizontal"
                else
                    "laser_blue_vertical"
                break;
            case "yellow":
                if(direction == "left" || direction == "right")
                    "laser_yellow_horizontal"
                else
                    "laser_yellow_vertical"
                break;
            default:
                if(direction == "left" || direction == "right")
                    "laser_red_horizontal"
                else
                    "laser_red_vertical"
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

        readonly property int multiplier: 16
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

    Sprite {
        id: laserCannonSprite
        anchors.fill: parent
        source: Global.paths.images + "objectset/lasers.png"
        alias: {
            switch(direction) {
            case "up":
                privateProperties.firing ? "laser_up_shoot" : "laser_up";
                break;
            case "down":
                privateProperties.firing ? "laser_down_shoot" : "laser_down";
                break;
            case "left":
                privateProperties.firing ? "laser_left_shoot" : "laser_left";
                break;
            default: // right
                privateProperties.firing ? "laser_right_shoot" : "laser_right";
                break;
            }
        }
        aliases: [
            SpriteAlias {
                name: "laser_up_shoot"
                frameX: 70; frameY: 350; frameWidth: 70; frameHeight: 70
            },

            SpriteAlias {
                name: "laser_up"
                frameX: 0; frameY: 350; frameWidth: 70; frameHeight: 70
            },

            SpriteAlias {
                name: "laser_down_shoot"
                frameX: 280; frameY: 0; frameWidth: 70; frameHeight: 70
            },

            SpriteAlias {
                name: "laser_down"
                frameX: 210; frameY: 0; frameWidth: 70; frameHeight: 70
            },

            SpriteAlias {
                name: "laser_left_shoot"
                frameX: 280; frameY: 70; frameWidth: 70; frameHeight: 70
            },

            SpriteAlias {
                name: "laser_left"
                frameX: 210; frameY: 70; frameWidth: 70; frameHeight: 70
            },

            SpriteAlias {
                name: "laser_right_shoot"
                frameX: 70; frameY: 210; frameWidth: 70; frameHeight: 70
            },

            SpriteAlias {
                name: "laser_right"
                frameX: 0; frameY: 210; frameWidth: 70; frameHeight: 70
            }
        ]
    }

    Sprite {
        id: hitImage
        opacity: privateProperties.firing ? 1 : 0
        visible: opacity > 0
        source: Global.paths.images + "objectset/lasers.png"
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

        aliases: [
            SpriteAlias {
                name: "laser_blue_burst"
                frameX: 0; frameY: 0; frameWidth: 70; frameHeight: 70
            },

            SpriteAlias {
                name: "laser_yellow_burst"
                frameX: 140; frameY: 350; frameWidth: 70; frameHeight: 70
            },

            SpriteAlias {
                name: "laser_green_burst"
                frameX: 0; frameY: 70; frameWidth: 70; frameHeight: 70
            },

            SpriteAlias {
                name: "laser_red_burst"
                frameX: 140; frameY: 140; frameWidth: 70; frameHeight: 70
            }
        ]

        alias: {
            switch(laserColor) {
            case "blue":
                "laser_blue_burst";
                break;
            case "yellow":
                "laser_yellow_burst";
                break;
            case "green":
                "laser_green_burst";
                break;
            default: // red
                "laser_red_burst";
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
