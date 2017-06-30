import QtQuick 2.9
import QtQuick.Controls 2.2
import "../singletons"

StackView {
    id: slateStack
    implicitWidth: Global.gameWindow.width
    implicitHeight: Global.gameWindow.height
    initialItem: Item {}

    onActiveFocusChanged: if (activeFocus) slateStack.currentItem.forceActiveFocus();
    onCurrentItemChanged: if (activeFocus) slateStack.currentItem.forceActiveFocus();

    property int animationDuration: 600

    pushEnter: Transition {
        ParallelAnimation {
            PropertyAnimation { property: "scale"; from: .2; to: 1; duration: animationDuration; easing.type: Easing.InOutBack }
            PropertyAnimation { property: "opacity"; from: 0; to: 1; duration: animationDuration; easing.type: Easing.InOutBack }
        }
    }

    pushExit: Transition {
        ParallelAnimation {
            PropertyAnimation { property: "scale"; from: 1; to: .2; duration: animationDuration; easing.type: Easing.InOutBack }
            PropertyAnimation { property: "opacity"; from: 1; to: 0; duration: animationDuration; easing.type: Easing.InOutBack }
        }
    }

    popEnter: Transition {
        ParallelAnimation {
            PropertyAnimation { property: "scale"; from: .2; to: 1; duration: animationDuration; easing.type: Easing.InOutBack }
            PropertyAnimation { property: "opacity"; from: 0; to: 1; duration: animationDuration; easing.type: Easing.InOutBack }
        }
    }

    popExit: Transition {
        ParallelAnimation {
            PropertyAnimation { property: "scale"; from: 1; to: .2; duration: animationDuration; easing.type: Easing.InOutBack }
            PropertyAnimation { property: "opacity"; from: 1; to: 0; duration: animationDuration; easing.type: Easing.InOutBack }
        }
    }

    Keys.onPressed: {
        switch(event.key) {
        case Qt.Key_Backspace:
            if (slateStack.depth > 1)
                slateStack.pop();
            break;
        }
    }
}
