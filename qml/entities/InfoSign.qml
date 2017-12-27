import QtQuick 2.9
import Bacon2D 1.0
import Seppuku 1.0
import "../singletons"
import "../gui"

EntityBase {
    id: infoSign
    bodyType: Body.Static
    width: 60
    height: 60
    sleepingAllowed: false

    property bool inRange: false
    property bool messageVisible: false
    property variant infoBox: null
    property string hintText: ""
    property bool balloonVisible: false

    property var tutorTextArray: []
    property var tutorDurationArray: []

    signal messageDisplayed(bool showing)
    signal infoRequested(var properties)

    fixtures: Box {
        width: target.width
        height: target.height
        categories: Utils.kInteractive
        collidesWith: Utils.kHero
        sensor: true

        readonly property string type: "info_sign"

        onBeginContact: {
            switch(other.categories) {
            case Utils.kHero:
                if(other.type === "main_body") {
                    //console.log("InfoSign: within range")
                    inRange = true;
                }
                break;
            }
        }

        onEndContact: {
            switch(other.categories) {
            case Utils.kHero:
                if(other.type === "main_body") {
                    //console.log("InfoSign: out of range")
                    inRange = false;
                }
                break;
            }
        }
    }

    Image {
        anchors.fill: parent
        source: Global.paths.images + "objects/info_sign.png"
    }

    Rectangle {
       color: "transparent"
       border.color: "skyblue"
       border.width: 3
       width: parent.width
       height: width
       visible: inRange
       radius: width

       SequentialAnimation on scale {
           loops: Animation.Infinite
           running: inRange && !Global.gameWindow.paused
           NumberAnimation { from: .1; to: 2; duration: 250 }
           NumberAnimation { from: 2; to: .1; duration: 250 }
       }
    }

    Loader {
        active: infoSign.balloonVisible
        anchors {
            bottom: parent.top
            horizontalCenter: parent.horizontalCenter
            bottomMargin: 10
        }

        sourceComponent: HelperBalloon { text: qsTr("Press \"Z\" to view message when in range.") }
    }

    Connections {
        target: infoSign.hero

        onInfoRequested: {
            if(!infoSign.messageVisible && infoSign.inRange) {
                if(Global.gameWindow.paused)
                    return;

                Global.gameWindow.pause();
                var properties = {};
                properties.text = infoSign.hintText;
                properties.messageVisible = true;

                infoSign.infoRequested(properties);

                if(infoSign.inRange)
                    infoSign.messageDisplayed(infoSign.messageVisible);
            }
        }
    }

    Connections {
        target: Global.gameWindow
        onGameStateChanged: {
            if (Global.gameWindow.gameState === Bacon2D.Running && infoSign.inRange) {
                infoSign.messageVisible = false;

                if(infoSign.inRange)
                    infoSign.messageDisplayed(infoSign.messageVisible);
            }
        }
    }

    onMessageDisplayed: if(!showing) tutorPlayer();

    function tutorPlayer() {
        tutor.clear();

        for(var i = 0; i < tutorTextArray.length; ++i) {
            var text = tutorTextArray[i];
            var duration = tutorDurationArray[i];

            tutor.queueText(text, duration);
        }
    }
}
