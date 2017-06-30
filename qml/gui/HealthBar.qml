import QtQuick 2.9
import QtGraphicalEffects 1.0
import "../singletons"
import Seppuku 1.0

Item {
    id: root
    width: 180
    height: 6

    property alias radius: healthBar.radius

    property real healthStatus: 1

    // Health bar
    Rectangle {
        id: healthBar
        anchors.fill: parent
        border.color: "white"
        border.width: 3

        width: root.width
        height: root.height
        color: "transparent"
        radius: 5
        visible: false // to make the mask show

        Rectangle {
            id: availableHealthIndicator
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: healthStatus * parent.width
            color: "#4cff00"

            Behavior on width { PropertyAnimation { duration: 500 } }
        }
        Rectangle {
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.left: availableHealthIndicator.right
            color: "#d9003f"
        }
    }

    Rectangle {
        id: mask
        x: healthBar.x
        y: healthBar.y
        width: healthBar.width
        height: healthBar.height
        color: "black"
        radius: healthBar.radius
        clip: true
        visible: false // to make the mask show
        opacity: healthBarMask.opacity
    }

    OpacityMask {
        id: healthBarMask
        anchors.fill: mask
        source: healthBar
        maskSource: mask
        opacity: root.opacity
        z: parent.z - 1

        //transform: root.transform
        /*Translate {
            id: healthBarTransform
            x: -healthBar.width
            y: 0
        }*/
    }
}

