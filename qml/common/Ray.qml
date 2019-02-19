import QtQuick 2.9
import Bacon2D 1.0
import "../singletons"

Item {
    id: ray

    property point p1: Qt.point(-1, -1)
    property point p2: Qt.point(-1, -1)
    property int castInterval: 100
    property int multiplier: 16
    property Scene scene: null
    property real closestFraction: 1
    property string closestEntity: ""
    property alias maxFraction: rayCast.maxFraction

    readonly property int pXDiff: Math.abs(p2.x - p1.x)
    readonly property int pYDiff: Math.abs(p2.y - p1.y)

    signal fixtureReported(Fixture fixture, point point, point normal, real fraction)
    signal aboutToCast
    signal castingDone

    RayCast {
        id: rayCast

        onFixtureReported: ray.fixtureReported(fixture, point, normal, fraction);

        function cast() {
            if (ray.scene) {
                ray.aboutToCast();

                closestFraction = 1;
                closestEntity = "";
                ray.scene.rayCast(this, p1, p2);

                ray.castingDone();
            }
        }
    }

    Timer {
        id: rayTimer
        running: !Global.gameWindow.paused && ray.enabled
        repeat: true
        interval: ray.castInterval
        onTriggered: rayCast.cast();
    }
}
