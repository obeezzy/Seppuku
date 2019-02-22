import QtQuick 2.9
import Bacon2D 1.0
import "../common"
import "../singletons"

LaserCannon {
    id: movingLaserCannon

    property LeverSwitch motionSwitch: null
    property point motionVelocity: Qt.point(0, 5)
    readonly property bool moving: movingLaserCannon.linearVelocity != Qt.point(0, 0)
    readonly property bool canMove: canMoveVertically || canMoveHorizontally
    readonly property bool canMoveHorizontally: limits.leftX != 0 && limits.rightX != 0
    readonly property bool canMoveVertically: limits.topY != 0 && limits.bottomY != 0
    property var limits: limits

    bodyType: Body.Kinematic
    updateInterval: 60

    // Rotate image accordingly, since laserUpShoot.png is used when direction is "left" or "right"
    spriteRotation: movingLaserCannon.direction === "left" ? -90 : (movingLaserCannon.direction === "right" ? 90 : 0)

    QtObject {
        id: privateProperties

        property bool firing: (laserLever != null && laserLever.position == "on") || ceaseInterval == 0
        readonly property bool topLimitReached: movingLaserCannon.y <= movingLaserCannon.limits.topY
        readonly property bool bottomLimitReached: movingLaserCannon.y >= movingLaserCannon.limits.bottomY
        readonly property bool leftLimitReached: movingLaserCannon.x <= movingLaserCannon.limits.leftX
        readonly property bool rightLimitReached: movingLaserCannon.x >= movingLaserCannon.limits.rightX
        property point lastLinearVelocity: movingLaserCannon.motionVelocity
        property real maxFraction: 1

        function switchMovement() {
            if (movingLaserCannon.canMoveVertically && motionSwitch == null || (movingLaserCannon.canMoveVertically && movingLaserCannon.motionSwitch.position == "right")) {
                if (topLimitReached)
                    movingLaserCannon.linearVelocity = movingLaserCannon.motionVelocity;
                else if (bottomLimitReached)
                    movingLaserCannon.linearVelocity = Utils.invertPoint(movingLaserCannon.motionVelocity);

                lastLinearVelocity = movingLaserCannon.linearVelocity;
            } else if (movingLaserCannon.canMoveHorizontally && motionSwitch == null || (movingLaserCannon.canMoveHorizontally && movingLaserCannon.motionSwitch.position == "right")) {
                if (leftLimitReached)
                    movingLaserCannon.linearVelocity = movingLaserCannon.motionVelocity;
                else if (rightLimitReached)
                    movingLaserCannon.linearVelocity = Utils.invertPoint(movingLaserCannon.motionVelocity);

                lastLinearVelocity = movingLaserCannon.linearVelocity;
            }
        }
    }

    Limits { id: limits }

    Connections {
        target: movingLaserCannon.motionSwitch
        onNewPosition: {
            if (position == "right")
                movingLaserCannon.startMovement();
            else
                movingLaserCannon.stopMovement();
        }
    }

    behavior: ScriptBehavior { script: privateProperties.switchMovement(); }

    function startMovement() {
        if (movingLaserCannon.canMove && !movingLaserCannon.moving)
            movingLaserCannon.linearVelocity = privateProperties.lastLinearVelocity;
    }

    function stopMovement() { movingLaserCannon.linearVelocity = Qt.point(0, 0); }
}
