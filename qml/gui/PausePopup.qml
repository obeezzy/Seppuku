import QtQuick 2.9
import Bacon2D 1.0
import Seppuku 1.0
import "../singletons"

Popup {
    id: pausePopup
    objectName: "PausePopup"

    signal resumeClicked
    signal restartClicked
    signal quitClicked

    content: SlateStack {
        id: stackView
        initialItem: PausedSlate {
            onResumeClicked: pausePopup.resumeClicked();
            onRestartClicked: stackView.push(restartSlate);
            onOptionsClicked: stackView.push(optionsSlate);
            onQuitClicked: stackView.push(closingSlate);
        }

        Component {
            id: optionsSlate

            OptionsSlate { onDoneClicked: stackView.pop(); }
        }

        Component {
            id: restartSlate

            QuestionSlate {
                text: qsTr("Are you sure you want to restart this level?")
                onYesClicked: pausePopup.restartClicked();
                onNoClicked: stackView.pop();
            }
        }

        Component {
            id: closingSlate

            QuestionSlate {
                text: qsTr("Are you sure you want to quit?")
                onYesClicked: pausePopup.quitClicked();
                onNoClicked: stackView.pop();
            }
        }

        Keys.onLeftPressed: event.accepted = true;
        Keys.onRightPressed: event.accepted = true;
    }
}

