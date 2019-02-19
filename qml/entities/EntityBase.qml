import QtQuick 2.9
import Bacon2D 1.0

PhysicsEntity {
    property string sender: ""
    property string type: ""
    property int objectId: -1

    readonly property var hero: scene.hero
    readonly property var tutor: scene.tutor
}
