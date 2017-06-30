import QtQuick 2.9
import Seppuku 1.0
import QtMultimedia 5.9
import "../singletons"

WideSlate {
    id: optionsSlate
    slateWidth: 540

    signal doneClicked

    content: FocusScope {
        Column {
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: parent.top
                topMargin: 10
            }

            Row {
                spacing: 40

                GameLabel {
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("BGM volume")
                }

                GameSlider {
                    id: bgmSlider
                    anchors.verticalCenter: parent.verticalCenter
                    focus: true
                    value: Global.settings.bgmVolume

                    Keys.onDownPressed: {
                        sfxSlider.focus = true;
                        effect.play();
                    }
                }
            }

            Row {
                spacing: 40

                GameLabel {
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("SFX volume")
                }

                GameSlider {
                    id: sfxSlider
                    anchors.verticalCenter: parent.verticalCenter
                    value: Global.settings.sfxVolume

                    Keys.onUpPressed: {
                        bgmSlider.focus = true;
                        effect.play();
                    }

                    Keys.onDownPressed: {
                        doneButton.focus = true;
                        effect.play();
                    }
                }
            }
        }

        GameIconButton {
            id: doneButton
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            text: Global.icons.fa_check
            onClicked: optionsSlate.doneClicked();

            Keys.onUpPressed: {
                sfxSlider.focus = true;
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

