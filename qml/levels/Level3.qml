import QtQuick 2.9
import Bacon2D 1.0
import Seppuku 1.0
import "../singletons"
import "../levels"

LevelBase {
    id: level3
    source: Global.paths.levels + "3.tmx"
    level: 3
    levelTitle: "Trial level..."

    function displayInstructions() {
        tutor.clearAll();
        tutor.queueText(qsTr("Level Three: Do The Robot"), 3000);
        tutor.queueText(qsTr("In this level, you would meet one of your greatest foes, the ROBOT."), 5000);
        tutor.startDisplay();
    }
}
