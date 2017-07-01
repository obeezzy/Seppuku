import QtQuick 2.9
import Bacon2D 1.0
import Seppuku 1.0
import "../singletons"

EntityBase {
    id: pipe
    bodyType: Body.Static
    width: 120
    height: 120
    sleepingAllowed: false

    property int windHeight: height * 2

    QtObject {
        id: privateProperties
        property bool actorPresent: false
    }

    fixtures: [
        Box {
            width: target.width
            height: target.height
            friction: .8
            density: .8
            restitution: .01
            categories: Utils.kGround
        },

        Box {
            width: target.width
            height: 1
            sensor: true
            categories: Utils.kGroundTop
        },

        Box {
            y: -windHeight
            width: target.width
            height: windHeight
            sensor: true
            categories: Utils.kHoverArea
            collidesWith: Utils.kActor

            onBeginContact: {
                if(other.categories & Utils.kActor) {
                    privateProperties.actorPresent = true;
                }
            }

            onEndContact: {
                if(other.categories & Utils.kActor) {
                    privateProperties.actorPresent = false;
                }
            }
        }
    ]

    Image {
        id: pipeImage
        anchors.fill: parent
        source: Global.paths.images + "objects/pipe.png"
    }

    Rectangle {
        id: wind
        anchors.bottom: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: windHeight
        color: Qt.rgba(255, 255, 255, .1)
    }

    Rectangle {
        id: indicator
        visible: !privateProperties.actorPresent
        color: "transparent"
        //border.color: "#004bfc"
        border.color: "white"
        border.width: 2
        radius: width
        width: 48
        height: width
        anchors.horizontalCenter: pipeImage.horizontalCenter
        anchors.bottom: pipeImage.top
        anchors.bottomMargin: 18

        readonly property int animDuration: 1000
        SequentialAnimation on opacity {
            running: indicator.visible
            loops: Animation.Infinite

            NumberAnimation { to: 0; duration: indicator.animDuration }
            NumberAnimation { to: 1; duration: indicator.animDuration }

            onRunningChanged: if(!running) indicator.opacity = 0;
        }


        Image {
            anchors.centerIn: parent
            source: Global.paths.images + "signs/hover.png"
        }
    }
}
