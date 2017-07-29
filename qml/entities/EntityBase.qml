import QtQuick 2.9
import Bacon2D 1.0

PhysicsEntity {
    id: entityBase

    readonly property var actor: scene.actor
    readonly property var tutor: scene.tutor
    property string sender: ""
    property string type: ""
}
