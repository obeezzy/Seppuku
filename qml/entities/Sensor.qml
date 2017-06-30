import QtQuick 2.9
import Bacon2D 1.0
import Seppuku 1.0
import "../singletons"

PhysicsEntity {
    id: root
    width: 60
    height: 60
    bodyType: Body.Static
    sleepingAllowed: false

    property int link: 0
    property string design: "wood"
    readonly property string type: "sensor"

    signal triggered

    Behavior on opacity { NumberAnimation {duration: 250 } }

    fixtures: Box {
        width: target.width
        height: target.height
        density: 1
        restitution: 0
        friction: .5
        categories: Global.kGround | Global.kGroundTop

        readonly property string type: root.type

        onBeginContact: {
            if(other.categories & Global.kActor)
            {
                if(other.type === "ground")
                {
                    opacity = .7;
                    root.triggered();
                }
            }
        }

        onEndContact: {
            if(other.categories & Global.kActor)
            {
                if(other.type === "ground")
                {
                    console.log("Actor detected!!!");
                    opacity = 1;
                }
            }
        }
    }

    BorderImage {
        anchors.fill: parent
        source: Global.paths.images + "sensors/3d_" + root.design + ".png"
        border {
            left: 5; top: 5; right: 5; bottom: 5
        }
    }
}

