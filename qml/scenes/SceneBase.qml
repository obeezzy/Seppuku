import QtQuick 2.7
import Bacon2D 1.0
import "../singletons"

Scene {
    physics: false
    implicitWidth: Global.gameWindow.width
    implicitHeight: Global.gameWindow.height

    signal mainMenuRequested

    property string name: ""
}
