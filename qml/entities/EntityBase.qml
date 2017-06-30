import QtQuick 2.9
import Bacon2D 1.0

PhysicsEntity {
    id: entityBase

    readonly property Scene scene: parent
    readonly property var actor: parent.actor
    readonly property var tutor: parent.tutor
    property string sender: ""
    property string type: ""
}
