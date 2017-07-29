import QtQuick 2.9
import Seppuku 1.0
import QtMultimedia 5.9
import "../singletons"

WideSlate {
    id: levelSelectSlate
    slateWidth: 540

    title: qsTr("Level Select")

    signal levelSelected(int level)
    signal homeClicked

    content: FocusScope {
        Grid {
            id: levelGrid
            anchors{
                top: parent.top
                horizontalCenter: parent.horizontalCenter
            }
            rowSpacing: 12
            columnSpacing: 12
            columns: 8

            property int currentIndex: 0

            onActiveFocusChanged: if (activeFocus) levelGrid.children[currentIndex].forceActiveFocus();

            Repeater {
                model: 10
                GameShortButton {
                    focus: levelGrid.currentIndex == index
                    text: index + 1
                    enabled: index < Global.settings.levelCount
                    onClicked: levelSelectSlate.levelSelected(index + 1);
                }
            }

            Keys.onRightPressed: {
                if ((levelGrid.currentIndex + 1 < levelGrid.children.length) && levelGrid.children[levelGrid.currentIndex + 1].enabled) {
                    levelGrid.currentIndex++;
                    effect.play();
                }
            }

            Keys.onLeftPressed: {
                if (levelGrid.currentIndex > 0 && levelGrid.children[levelGrid.currentIndex - 1].enabled) {
                    levelGrid.currentIndex--;
                    effect.play();
                }
            }

            Keys.onDownPressed: {
                homeButton.focus = true;
                effect.play();
            }
        }

        GameIconButton {
            id: homeButton
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
            }

            text: Stylesheet.icons.fa_home
            onClicked: levelSelectSlate.homeClicked();

            Keys.onUpPressed: {
                levelGrid.focus = true;
                effect.play();
            }
        }

        SoundEffect {
            id: effect
            source: Global.paths.sounds + "dry_fire.wav"
            volume: Global.settings.sfxVolume
            muted: Global.settings.noSound
        }
    }
}

