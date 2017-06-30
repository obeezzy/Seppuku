import QtQuick 2.9
import Bacon2D 1.0
import Seppuku 1.0
import "../singletons"
import "../levels"

LevelBase {
    id: scene
    //debug: true
    source: Global.paths.levels + "1.tmx"
    level: 1
    levelTitle: "Tutorial"

    function displayInstructions() {
        tutor.clearAll()
        tutor.queueText("Level One: Here We Go", 3000)
        tutor.queueText("Follow these instructions to survive!", 3000)
        tutor.startDisplay()
    }
}
