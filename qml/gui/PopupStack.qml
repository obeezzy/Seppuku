import QtQuick 2.9
import QtQuick.Controls 2.2

StackView {
    id: popupStack

    readonly property string currentObjectName: currentItem !== undefined  && currentItem !== null ? currentItem.objectName : ""

    enabled: visible
    visible: depth != 0

    pushEnter: null
    pushExit: null
    replaceEnter: null
    replaceExit: null
    popEnter: null
    popExit: null

    Connections {
        target: popupStack.currentItem
        onDismissed: popupStack.clear();
    }

    Keys.onEscapePressed: {
        switch (popupStack.currentObjectName) {
        case "PausePopup":
        case "InfoPopup":
            popupStack.clear();
            break;
        }
    }
}
