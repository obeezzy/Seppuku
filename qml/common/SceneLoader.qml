import QtQuick 2.9

Loader {
    id: sceneLoader
    active: false
    asynchronous: true

    Connections {
        target: item
        onVisibleChanged: if (!sceneLoader.item.visible) sceneLoader.active = false;
    }
}
