import QtQuick 2.9
import Bacon2D 1.0
import QtMultimedia 5.9
import Seppuku 1.0
import "../singletons"
import "../sprites"

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

    property alias spriteRotation: laserCannonSpriteLoader.rotation
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

    Loader {
        id: laserLoader
        width: laserCannon.laserWidth
        height: laserCannon.laserHeight
        visible: privateProperties.firing ? 1 : 0
        rotation: {
            switch(laserCannon.direction) {
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
            switch(laserCannon.direction) {
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
            switch(laserCannon.direction) {
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
            switch(laserCannon.direction) {
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

        sourceComponent: {
            switch(laserCannon.laserColor) {
            case "green":
                if(direction == "left" || direction == "right")
                    laserGreenHorizontal
                else
                    laserGreenVertical
                break;
            case "blue":
                if(direction == "left" || direction == "right")
                    laserBlueHorizontal
                else
                    laserBlueVertical
                break;
            case "yellow":
                if(direction == "left" || direction == "right")
                    laserYellowHorizontal
                else
                    laserYellowVertical
                break;
            default:
                if(direction == "left" || direction == "right")
                    laserRedHorizontal
                else
                    laserRedVertical
                break;
            }
        }

        Component {
            id: laserGreenHorizontal
            LaserSprite {
                fillMode: {
                    switch(laserCannon.direction) {
                    case "up":
                    case "down":
                        Bacon2D.TileVertically;
                        break;
                    default:
                        Bacon2D.TileHorizontally;
                    }
                }

                frameX: 70; frameY: 70; frameWidth: 70; frameHeight: 70
            }
        }

        Component {
            id: laserGreenVertical
            LaserSprite {
                fillMode: {
                    switch(laserCannon.direction) {
                    case "up":
                    case "down":
                        Bacon2D.TileVertically;
                        break;
                    default:
                        Bacon2D.TileHorizontally;
                    }
                }

                frameX: 140; frameY: 70; frameWidth: 70; frameHeight: 70
            }
        }

        Component {
            id: laserBlueHorizontal
            LaserSprite {
                fillMode: {
                    switch(laserCannon.direction) {
                    case "up":
                    case "down":
                        Bacon2D.TileVertically;
                        break;
                    default:
                        Bacon2D.TileHorizontally;
                    }
                }
                frameX: 70; frameY: 0; frameWidth: 70; frameHeight: 70
            }
        }

        Component {
            id: laserBlueVertical
            LaserSprite {
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
                frameX: 140; frameY: 0; frameWidth: 70; frameHeight: 70
            }
        }

        Component {
            id: laserYellowHorizontal
            LaserSprite {
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
                frameX: 210; frameY: 350; frameWidth: 70; frameHeight: 70
            }
        }

        Component {
            id: laserYellowVertical
            LaserSprite {
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
                frameX: 280; frameY: 350; frameWidth: 70; frameHeight: 70
            }
        }

        Component {
            id: laserRedHorizontal
            LaserSprite {
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
                frameX: 210; frameY: 140; frameWidth: 70; frameHeight: 70
            }
        }

        Component {
            id: laserRedVertical
            LaserSprite {
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
                frameX: 280; frameY: 140; frameWidth: 70; frameHeight: 70
            }
        }
    }

    RayCast {
        id: laserRay

        readonly property int multiplier: 16
        readonly property int pXDiff: Math.abs(p2.x - p1.x)
        readonly property int pYDiff: Math.abs(p2.y - p1.y)
        property real closestFraction: 1
        property string closestEntity: ""

        property point p1: {
            switch(laserCannon.direction) {
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
            switch(laserCannon.direction) {
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

    Loader {
        id: laserCannonSpriteLoader
        anchors.fill: parent

        sourceComponent: {
            switch(laserCannon.direction) {
            case "up":
                privateProperties.firing ? laserUpShoot : laserUp;
                break;
            case "down":
                privateProperties.firing ? laserDownShoot : laserDown;
                break;
            case "left":
                privateProperties.firing ? laserLeftShoot : laserLeft;
                break;
            default: // right
                privateProperties.firing ? laserRightShoot : laserRight;
                break;
            }
        }

        Component {
            id: laserUpShoot
            LaserSprite { frameX: 70; frameY: 350; frameWidth: 70; frameHeight: 70 }
        }

        Component {
            id: laserUp
            LaserSprite { frameX: 0; frameY: 350; frameWidth: 70; frameHeight: 70 }
        }

        Component {
            id: laserDownShoot
            LaserSprite { frameX: 280; frameY: 0; frameWidth: 70; frameHeight: 70 }
        }

        Component {
            id: laserDown
            LaserSprite { frameX: 210; frameY: 0; frameWidth: 70; frameHeight: 70 }
        }

        Component {
            id: laserLeftShoot
            LaserSprite { frameX: 280; frameY: 70; frameWidth: 70; frameHeight: 70 }
        }

        Component {
            id: laserLeft
            LaserSprite { frameX: 210; frameY: 70; frameWidth: 70; frameHeight: 70 }
        }

        Component {
            id: laserRightShoot
            LaserSprite { frameX: 70; frameY: 210; frameWidth: 70; frameHeight: 70 }
        }

        Component {
            id: laserRight
            LaserSprite { frameX: 0; frameY: 210; frameWidth: 70; frameHeight: 70 }
        }
    }

    Loader {
        id: hitImageLoader
        opacity: privateProperties.firing ? 1 : 0
        visible: opacity > 0
        z: laserLoader.item.z + 1

        Behavior on opacity { NumberAnimation { } }

        x: {
            switch(laserCannon.direction) {
            case "up":
            case "down":
                0
                break;
            case "left":
                -laserLoader.item.width - width / 2;
                break;
            default:
                laserLoader.item.width + width / 2;
            }
        }
        y: {
            switch(laserCannon.direction) {
            case "up":
                -laserLoader.item.height - height / 2;
                break;
            case "down":
                laserLoader.item.height + height / 2;
                break;
            default:
                0
                break;
            }
        }
        width: {
            switch(laserCannon.direction) {
            case "up":
            case "down":
                laserLoader.item.width;
                break;
            default: // left and right
                laserLoader.item.height;
                break;
            }
        }
        height: {
            switch(laserCannon.direction) {
            case "up":
            case "down":
                laserLoader.item.width;
                break;
            default: // left and right
                laserLoader.item.height;
                break;
            }
        }

        sourceComponent: {
            switch(laserCannon.laserColor) {
            case "blue":
                laserBlueBurst
                break;
            case "yellow":
                laserYellowBurst
                break;
            case "green":
                laserGreenBurst
                break;
            default: // red
                laserRedBurst
            }
        }

        Component {
            id: laserBlueBurst
            LaserSprite { frameX: 0; frameY: 0; frameWidth: 70; frameHeight: 70 }
        }

        Component {
            id: laserYellowBurst
            LaserSprite { frameX: 140; frameY: 350; frameWidth: 70; frameHeight: 70 }
        }

        Component {
            id: laserGreenBurst
            LaserSprite { frameX: 0; frameY: 70; frameWidth: 70; frameHeight: 70 }
        }

        Component {
            id: laserRedBurst
            LaserSprite { frameX: 140; frameY: 140; frameWidth: 70; frameHeight: 70 }
        }
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
