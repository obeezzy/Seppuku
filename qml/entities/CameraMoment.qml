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

    property string lockEdge: "bottom"

    fixtures: Box {
        width: target.width
        height: target.height
        sensor: true
        categories: Utils.kCameraMoment

        readonly property string type: "camera_moment"
        readonly property real cameraMomentX: {
            switch (cameraMoment.lockEdge) {
            default:
                cameraMoment.x;
                break;
            }
        }
        readonly property real cameraMomentY: {
            switch (cameraMoment.lockEdge) {
            case "bottom":
                cameraMoment.y + cameraMoment.height;
                break;
            default:
                -1;
                break;
            }
        }
        readonly property string lockEdge: cameraMoment.lockEdge
    }
}
