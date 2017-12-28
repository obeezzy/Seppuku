import QtQuick 2.9
import Bacon2D 1.0
import Seppuku 1.0
import "../singletons"

EntityBase {
    id: cameraMoment
    bodyType: Body.Static
    width: 60
    height: 60
    sleepingAllowed: true
    sender: "camera_moment"
    entityType: "cameraMoment"

    property bool lockedX: true
    property bool lockedY: true
    property bool lockedMinX: false
    property bool lockedMaxX: false
    property bool lockedMinY: false
    property bool lockedMaxY: false

    fixtures: Box {
        width: target.width
        height: target.height
        sensor: true
        categories: Utils.kCameraMoment

        readonly property string type: "camera_moment"
        readonly property var cameraMoment: {
            "x": cameraMoment.lockedX ? cameraMoment.x : -1,
            "y": cameraMoment.lockedY ? cameraMoment.y : -1,
            "min_x": cameraMoment.lockedMinX ? cameraMoment.x : -1,
            "max_x": cameraMoment.lockedMaxX ? cameraMoment.x + cameraMoment.width : -1,
            "min_y": cameraMoment.lockedMinY ? cameraMoment.y : -1,
            "max_y": cameraMoment.lockedMaxY ? cameraMoment.y + cameraMoment.height : -1
        }
    }
}
