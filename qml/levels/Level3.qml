import QtQuick 2.9
import Bacon2D 1.0
import Seppuku 1.0
import "../singletons"
import "../levels"

LevelBase {
    id: scene
    //debug: true
    source: Global.paths.levels + "3.tmx"
    level: 3
    levelTitle: "Trial level..."
    background: Rectangle { color: "lightsteelblue"; Rectangle { anchors.centerIn: parent; color: "red"; width: 500; height: 500 } }

    function displayInstructions() {
        tutor.clearAll();
        tutor.queueText(qsTr("Level Three: Do The Robot"), 3000);
        tutor.queueText(qsTr("In this level, you would meet one of your greatest foes, the ROBOT."), 5000);
        tutor.startDisplay();
    }
}
