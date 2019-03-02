import QtQuick 2.9
import Bacon2D 1.0

Entity {
    id: limits

    property real topY: 0
    property real bottomY: 0
    property real leftX: 0
    property real rightX: 0


    function asString() {
        return "(topY=" + topY + ", bottomY=" + bottomY + ", leftX=" + leftX + ", rightX=" + rightX + ")";
    }
}
