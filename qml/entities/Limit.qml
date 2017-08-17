import QtQuick 2.9
import Bacon2D 1.0
import "../singletons"

Entity {
    id: limit
    entityType: "limit"

    property int limitLink: 0
    property string limitEdge: "bottom"
}
