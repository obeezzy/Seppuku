import QtQuick 2.9
import Seppuku 1.0
import "../singletons"
import "../gui"
import "../entities"

Item {
    visible: Seppuku.isMobile
    width: 210
    height: 210

    property Ninja hero: parent.hero
    property bool animationRunning: false
    property int scrollDuration: 250

    Behavior on x { enabled: animationRunning; NumberAnimation {duration: scrollDuration }}
    Behavior on y { enabled: animationRunning; NumberAnimation {duration: scrollDuration } }

    VirtualJoystick {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.leftMargin: 6
        anchors.bottomMargin: 6
        width: 180
        height: width

        onJoystickMoved: {
            // console.log("Joystick -> (", x, ", ", y)
            if(x < 0)
                hero.moveLeft();
            else if(x > 0)
                hero.moveRight();
            else {
                if(hero.facingLeft)
                    hero.stopMovingLeft();
                else if(hero.facingRight)
                    hero.stopMovingRight();
            }
        }
    }

    ButtonPad {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.rightMargin: 6
        anchors.bottomMargin: 6
        width: 210

        onJumpTriggered: hero.jump();
        onSlideTriggered: hero.slide();
        onThrowTriggered: hero.throwKunai();
        onAttackTriggered: hero.attack();
        onToggleDisguiseTriggered: hero.toggleDisguise();
    }
}

