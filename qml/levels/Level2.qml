import QtQuick 2.9
import Bacon2D 1.0
import Seppuku 1.0
import "../singletons"
import "../levels"

LevelBase {
    id: scene
    source: Global.paths.levels + "2.tmx"
    level: 2
    levelTitle: "Robots..."

    function displayInstructions() {
        tutor.clearAll()
        tutor.queueText("Level Two: Do The Robot", 3000)
        tutor.queueText("In this level, you would meet one of your greatest foes, the ROBOT.", 5000)
        tutor.startDisplay()
    }
}
