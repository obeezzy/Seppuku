import QtQuick 2.9
import Bacon2D 1.0
import Seppuku 1.0
import "../singletons"

EntityBase {
    id: movingPlatform
    height: 36
    bodyType: Body.Kinematic
    fixedRotation: true
    sleepingAllowed: false
    linearVelocity: moving ? (reversing ? reverseVelocity : startVelocity) : Qt.point(0, 0)
    linearDamping: 10

    readonly property string fileLocation: Global.paths.images + "tiles/winter/"

    property point reversePoint: Qt.point(x, y)
    property point startPoint: Qt.point(x, y)
    property point startVelocity: Qt.point(0, 0)
    property point reverseVelocity: Qt.point(0, 0)
    property bool moving: false
    property bool reversing: false
    property bool upDirection: startPoint.y > reversePoint.y

    fixtures: Box {
        width: target.width
        height: target.height

        restitution: 0
        friction: .9
        density: 1
        categories: Global.kGround | Global.kGroundTop
    }

    Row {
        anchors.top: parent.top
        anchors.bottom: parent.bottom

        Image {
            id: firstImage
            width: parent.parent.width / 4
            source: fileLocation + "14.png"
            fillMode: Image.PreserveAspectFit
        }

        Image {
            width: parent.parent.width * .5
            height: firstImage.height
            fillMode: Image.TileHorizontally
            source: fileLocation + "15.png"
        }

        Image {
            width: parent.parent.width / 4
            source: fileLocation + "16.png"
            fillMode: Image.PreserveAspectFit
        }
    }

    onXChanged: {
//        if(linearVelocity.x > 0 && !movingPlatform.reversing) {
//            if(x > startPoint.x && y < startPoint.y)
//                linearVelocity.x = 0
//            else if(x > startPoint.x && y > startPoint.y)
//                linearVelocity.x = reversePoint.x
//        }
//        else if(linearVelocity.x < 0) {
//            if(x < startPoint.x && y > startPoint.y)
//                linearVelocity.x = 0
//            else if(x < startPoint.x && y < startPoint.y)
//                linearVelocity.x = reversePoint.x
//        }
    }

    onYChanged: {
        if(!reversing && upDirection && y < reversePoint.y)
            reversing = true;
        else if(reversing && upDirection && y > startPoint.y)
            reversing = false;
    }
}

