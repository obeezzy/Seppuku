import QtQuick 2.9
import Bacon2D 1.0
import "../singletons"
import "../entities"

Viewport {
    id: heroCamera
    width: Global.gameWindow.width
    height: Global.gameWindow.height
    xOffset: camX > offsetMaxX ? (camX < offsetMinX ? offsetMinX : offsetMaxX) : camX
    yOffset: camY > offsetMaxY ? (camY < offsetMinY ? offsetMinY : offsetMaxY) : camY
    animationDuration: hero.inCameraMomentRange ? 500 : 0

    property Ninja hero: null
    readonly property real offsetMaxX: contentWidth - width
    readonly property real offsetMaxY: contentHeight - height
    readonly property real offsetMinX: 0
    readonly property real offsetMinY: 0
    readonly property real camX: privateProperties.camX
    readonly property real camY: privateProperties.camY

    Binding {
        when: hero.inCameraMomentRange && hero.cameraMomentX > -1
        target: privateProperties
        property: "camX"
        value: hero.cameraMomentX
    }

    Binding {
        when: hero.inCameraMomentRange && hero.cameraMomentY > -1
        target: privateProperties
        property: "camY"
        value: hero.cameraMomentY
    }

    QtObject {
        id: privateProperties

        property real camX: hero.x - heroCamera.width / 2
        property real camY: hero.y - heroCamera.height / 2
    }

    function reset() {
        hero.x += 1;
        hero.x -= 1;
        hero.y += 1;
        hero.y -= 1;
    }
}
