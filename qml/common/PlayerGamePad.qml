import QtQuick 2.9
import QtGamepad 1.0
import Seppuku 1.0
import "../singletons"
import "../entities"

Item {
    width: 0
    height: 0

    readonly property Ninja actor: parent.actor
    readonly property alias connected: gamePad.connected

    signal pauseRequested(bool paused)

    Gamepad {
        id: gamePad
        deviceId: 0

        onButtonAChanged: {
            if(buttonA && axisLeftY > .8 && axisLeftX >= -.5 && axisLeftX <= .5)
                actor.slide();
            if(buttonA) {
                if(actor.isInHoverArea())
                    actor.hover(buttonA);
                else
                    actor.jump();
            }
            else if(actor.isInHoverArea())
                    actor.stopHovering();
        }

        onButtonXChanged: {
            if(buttonX)
                actor.attack();
        }

        onButtonBChanged: {
            if(buttonB)
                actor.throwKunai();
        }

        onButtonYChanged: {
            if(buttonY) {
                if(!actor.inDisguiseRange)
                    actor.use();
                else
                    actor.toggleDisguise();
            }
        }

        onAxisLeftXChanged: {
            //console.log("Axis left x:", axisLeftX)

            if(axisLeftX > .8)
                actor.moveRight();
            else if(axisLeftX < -.8)
                actor.moveLeft();
            else {
                if(actor.facingLeft)
                    actor.stopMovingLeft();
                else if(actor.facingRight)
                    actor.stopMovingRight();
            }
        }

        onAxisLeftYChanged: {
            //console.log("Axis left y:", axisLeftY)

            if(axisLeftY < -.8) {
                actor.climbUp();
            }
            else if(axisLeftY > .8)
                actor.climbDown();
            else {
                if(actor.facingDown)
                    actor.stopClimbingDown();
                else if(actor.facingUp)
                    actor.stopClimbingUp();
            }
        }

        onButtonStartChanged: {
            if(buttonStart) {
                gameWindow.togglePause();
                pauseRequested(gameWindow.paused);
            }
        }
    }
}

