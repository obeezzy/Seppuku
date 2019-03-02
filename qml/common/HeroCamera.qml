import QtQuick 2.9
import Bacon2D 1.0
import "../singletons"
import "../entities"

Viewport {
    id: heroCamera

    property Ninja hero: entityManager.findEntity("ninja")
    readonly property real defaultOffsetMaxX: contentWidth - width
    readonly property real defaultOffsetMaxY: contentHeight - height
    readonly property real defaultOffsetMinX: 0
    readonly property real defaultOffsetMinY: 0
    readonly property real defaultCamX: hero ? hero.x - heroCamera.width / 2 : 0
    readonly property real defaultCamY: hero ? hero.y - heroCamera.height / 2 : 0

    readonly property real offsetMaxX: privateProperties.offsetMaxX
    readonly property real offsetMaxY: privateProperties.offsetMaxY
    readonly property real offsetMinX: privateProperties.offsetMinX
    readonly property real offsetMinY: privateProperties.offsetMinY
    readonly property real camX: privateProperties.camX
    readonly property real camY: privateProperties.camY

    readonly property bool heroAtCenter: xOffset == defaultCamX && yOffset == defaultCamY

    EntityManager { id: entityManager }

    width: Global.gameWindow.width
    height: Global.gameWindow.height
    xOffset: camX > offsetMaxX ? offsetMaxX : (camX < offsetMinX ? offsetMinX : camX)
    yOffset: camY > offsetMaxY ? (camY < offsetMinY ? offsetMinY : offsetMaxY) : camY
    animationDuration: 0

    QtObject {
        id: privateProperties

        property real offsetMinX: heroCamera.defaultOffsetMinX
        property real offsetMaxX: heroCamera.defaultOffsetMaxX
        property real offsetMinY: heroCamera.defaultOffsetMinY
        property real offsetMaxY: heroCamera.defaultOffsetMaxY
        property real camX: heroCamera.defaultCamX
        property real camY: heroCamera.defaultCamY
    }

    states: State {
        name: "fixed"
        when: hero && hero.inCameraMomentRange

        PropertyChanges {
            target: privateProperties
            camX: hero && hero.cameraMoment != null && hero.cameraMoment["x"] > -1 ? hero.cameraMoment["x"] : heroCamera.defaultCamX
            camY: hero && hero.cameraMoment != null && hero.cameraMoment["y"] > -1 ? hero.cameraMoment["y"] : heroCamera.defaultCamY
            offsetMinX: hero && hero.cameraMoment != null && hero.cameraMoment["min_x"] > -1 ? hero.cameraMoment["min_x"] : heroCamera.defaultOffsetMinX
            offsetMaxX: hero && hero.cameraMoment != null && hero.cameraMoment["max_x"] > -1 ? hero.cameraMoment["max_x"] : heroCamera.defaultOffsetMaxX
            offsetMinY: hero && hero.cameraMoment != null && hero.cameraMoment["min_y"] > -1 ? hero.cameraMoment["min_y"] : heroCamera.defaultOffsetMinY
            offsetMaxY: hero && hero.cameraMoment != null && hero.cameraMoment["max_y"] > -1 ? hero.cameraMoment["max_y"] : heroCamera.defaultOffsetMaxY
        }
    }

    //Behavior on xOffset { id: xOffsetBehavior; enabled: hero.inCameraMomentRange; SmoothedAnimation { velocity: 200; duration: 500 } }
    //Behavior on yOffset { id: yOffsetBehavior; enabled: hero.inCameraMomentRange; SmoothedAnimation { velocity: 200; duration: 500 } }

//    Connections {
//        target: hero
//        onInCameraMomentRangeChanged: {
//            if (hero.inCameraMomentRange) {
//                xOffsetBehavior.enabled = true;
//                yOffsetBehavior.enabled = true;
//                heroCamera.state = "fixed";
//            } else {
//                heroCamera.onHeroAtCenterChanged.connect(function() {
//                    if (heroCamera.heroAtCenter) {
//                        xOffsetBehavior.enabled = false;
//                        yOffsetBehavior.enabled = false;
//                    }
//                });
//                heroCamera.state = "";
//            }
//        }
//    }

    function reset() {
        if (hero) {
            hero.x += 1;
            hero.x -= 1;
            hero.y += 1;
            hero.y -= 1;
        }
    }
}
