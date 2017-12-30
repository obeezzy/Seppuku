TEMPLATE = app

QT += qml quick gamepad

SOURCES += src/main.cpp \
    src/seppuku.cpp

#RESOURCES += qml.qrc

RC_ICONS = seppuku.ico

CONFIG += c++11

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

DISTFILES += \
    qml/main.qml \
    qml/entities/Ninja.qml \
    qml/entities/Snowman.qml \
    qml/gui/HeadsUpDisplay.qml \
    qml/gui/VirtualJoystick.qml \
    qml/entities/Coin.qml \
    qml/gui/TutorText.qml \
    qml/entities/WinterTree1.qml \
    qml/entities/WinterTree2.qml \
    qml/entities/Kunai.qml \
    qml/entities/Sea.qml \
    qml/entities/Robot.qml \
    qml/entities/Crystal.qml \
    qml/entities/IceBox.qml \
    qml/entities/WarningSign.qml \
    qml/entities/Cannon.qml \
    qml/entities/KunaiCollectible.qml \
    qml/entities/Rope.qml \
    js/RobotAi.js \
    qml/entities/Bullet.qml \
    qml/gui/ButtonPad.qml \
    qml/common/PlayerGamePad.qml \
    qml/gui/PlayerVirtualPad.qml \
    qml/entities/InfoSign.qml \
    qml/entities/Pipe.qml \
    qml/gui/InfoSlate.qml \
    qml/gui/PausedSlate.qml \
    qml/scenes/SplashScene.qml \
    qml/scenes/LoadingScene.qml \
    qml/entities/CheckpointSign.qml \
    qml/entities/FinishSign.qml \
    qml/entities/LaserCannon.qml \
    qml/entities/NearFinishSign.qml \
    qml/gui/StatsSlate.qml \
    qml/gui/FailSlate.qml \
    qml/entities/ChainRope.qml \
    qml/entities/Key.qml \
    qml/entities/Gem.qml \
    qml/entities/MovingPlatform.qml \
    qml/entities/WoodenDoor.qml \
    qml/entities/DoorLock.qml \
    qml/entities/Sensor.qml \
    qml/singletons/Global.qml \
    qml/common/MemoryCard.qml \
    qml/gui/OptionsSlate.qml \
    qml/gui/WideSlate.qml \
    qml/gui/NarrowSlate.qml \
    qml/gui/GameButton.qml \
    qml/gui/GameSlider.qml \
    qml/gui/GameLabel.qml \
    qml/gui/GameIconButton.qml \
    qml/gui/HealthBar.qml \
    qml/gui/SlateStack.qml \
    qml/gui/DynamicBackground.qml \
    qml/gui/LevelSelectSlate.qml \
    qml/gui/InstructionsSlate.qml \
    qml/gui/PlainNarrowSlate.qml \
    qml/gui/GameShortButton.qml \
    qml/gui/Popup.qml \
    qml/gui/FailPopup.qml \
    qml/gui/InfoPopup.qml \
    qml/gui/PausePopup.qml \
    qml/gui/StatsPopup.qml \
    qml/entities/LaserLever.qml \
    js/Fish.js \
    js/Robot.js \
    qml/levels/LevelBase.qml \
    qml/scenes/SceneBase.qml \
    qml/scenes/MainMenuScene.qml \
    qml/gui/TimerPie.qml \
    qml/entities/Fish.qml \
    qml/levels/Level1.qml \
    qml/levels/Level2.qml \
    qml/levels/Level3.qml \
    qml/entities/Explosive.qml \
    qml/common/GameItem.qml \
    qml/common/SceneLoader.qml \
    qml/gui/MainMenuSlate.qml \
    qml/gui/PopupStack.qml \
    qml/gui/QuestionSlate.qml \
    qml/entities/EntityBase.qml \
    qml/singletons/Stylesheet.qml \
    qml/singletons/Utils.qml \
    qml/entities/OneWayPlatform.qml \
    qml/entities/LeverSwitch.qml \
    qml/common/HeroCamera.qml \
    qml/entities/CameraMoment.qml \
    qml/entities/Limit.qml \
    qml/gui/HelperBalloon.qml \
    qml/entities/MovingLaserCannon.qml

HEADERS += \
    src/seppuku.h

macx {
    QMAKE_MAC_SDK = macosx10.9
}

android {
    QT += androidextras
#    OTHER_FILES += platform-specific/android/AndroidManifest.xml
#    ANDROID_PACKAGE_SOURCE_DIR = $$PWD/platform-specific/android
}
