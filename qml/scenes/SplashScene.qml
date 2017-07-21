import QtQuick 2.9
import Bacon2D 1.0
import Seppuku 1.0
import "../singletons"
import QtQuick.Controls 2.1

SceneBase {
    id: root

    signal timeout

    Rectangle { anchors.fill: parent }

    StackView {
        id: stackView
        anchors.fill: parent

        initialItem: Item {
            Image {
                id: geckoLogo
                anchors.centerIn: parent
                source: Global.paths.images + "misc/gecko.png"
            }

            Text {
                anchors.horizontalCenter: geckoLogo.horizontalCenter
                anchors.top: geckoLogo.bottom
                anchors.topMargin: 6
                text: qsTr("...making life easier!")
                font.pixelSize: 12
                font.family: Stylesheet.splashFontFamily
                horizontalAlignment: Qt.AlignHCenter
                font.italic: true
            }
        }

        Component {
            id: frameworkPage

            Item {
                Text {
                    anchors{
                        bottom: row.top
                        bottomMargin: 20
                        horizontalCenter: row.horizontalCenter
                    }
                    text: qsTr("Made with")
                    font.pixelSize: 12
                    font.family: Stylesheet.splashFontFamily
                    horizontalAlignment: Qt.AlignHCenter
                    font.italic: true
                }

                Row {
                    id: row
                    anchors.centerIn: parent
                    spacing: 100

                    Image {
                        id: qtLogo
                        anchors.verticalCenter: parent.verticalCenter
                        width: 200
                        fillMode: Image.PreserveAspectFit
                        source: Global.paths.images + "misc/qt.png"
                    }

                    Image {
                        id: bacon2dLogo
                        anchors.verticalCenter: parent.verticalCenter
                        width: 200
                        fillMode: Image.PreserveAspectFit
                        source: Global.paths.images + "misc/bacon2d.png"
                    }
                }
            }
        }

        pushEnter: Transition {
            PauseAnimation { duration: 750 }
            NumberAnimation { property: "opacity"; from: 0; to: 1; easing.type: Easing.OutQuart; duration: 750 }
        }

        pushExit: Transition {
            NumberAnimation { property: "opacity"; from: 1; to: 0; easing.type: Easing.OutQuart; duration: 750 }
            PauseAnimation { duration: 750 }
        }

        Timer {
            id: pushTimer
            running: true
            repeat: false
            interval: startupTimer.interval / 2

            onTriggered: stackView.push(frameworkPage);
        }
    }

    // startup timer
    Timer {
        id: startupTimer
        running: true
        repeat: false
        interval: 5000

        onTriggered: root.timeout();
    }
}
