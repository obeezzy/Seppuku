import QtQuick 2.9
import QtGamepad 1.0
import Seppuku 1.0
import "../singletons"
import "../entities"

Item {
//    readonly property Ninja hero: parent.hero
//    readonly property alias connected: gamePad1.connected

//    signal pauseRequested(bool paused)

//    Gamepad {
//        id: gamePad1
////        deviceId: 0

//        onButtonAChanged: {
//            if(buttonA && axisLeftY > .8 && axisLeftX >= -.5 && axisLeftX <= .5)
//                hero.slide();
//            if(buttonA) {
//                if(hero.inHoverArea)
//                    hero.hover(buttonA);
//                else
//                    hero.jump();
//            }
//            else if(hero.inHoverArea())
//                    hero.stopHovering();
//        }

//        onButtonXChanged: {
//            if(buttonX)
//                hero.attack();
//        }

//        onButtonBChanged: {
//            if(buttonB)
//                hero.throwKunai();
//        }

//        onButtonYChanged: {
//            if(buttonY) {
//                if(!hero.inDisguiseRange)
//                    hero.use();
//                else
//                    hero.toggleDisguise();
//            }
//        }

//        onAxisLeftXChanged: {
//            //console.log("Axis left x:", axisLeftX)

//            if(axisLeftX > .8)
//                hero.moveRight();
//            else if(axisLeftX < -.8)
//                hero.moveLeft();
//            else {
//                if(hero.facingLeft)
//                    hero.stopMovingLeft();
//                else if(hero.facingRight)
//                    hero.stopMovingRight();
//            }
//        }

//        onAxisLeftYChanged: {
//            //console.log("Axis left y:", axisLeftY)

//            if(axisLeftY < -.8) {
//                hero.climbUp();
//            }
//            else if(axisLeftY > .8)
//                hero.climbDown();
//            else {
//                if(hero.facingDown)
//                    hero.stopClimbingDown();
//                else if(hero.facingUp)
//                    hero.stopClimbingUp();
//            }
//        }

////        onButtonStartChanged: {
////            if(buttonStart) {
////                gameWindow.togglePause();
////                pauseRequested(gameWindow.paused);
////            }
////        }
//    }

//    Connections {
//        target: GamepadManager
//        onGamepadConnected: gamePad1.deviceId = deviceId;
//    }

//    GamepadKeyNavigation {
//        id: gamepadKeyNavigation
//        gamepad: gamePad1
//        active: true
//        buttonStartKey: Qt.Key_Escape
//    }
}

