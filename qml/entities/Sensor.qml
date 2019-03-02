import QtQuick 2.9
import Bacon2D 1.0
import Seppuku 1.0
import "../singletons"

EntityBase {
    id: sensor
    entityType: "sensor"

    property int link: 0
    property string design: "wood"
    readonly property string type: "sensor"

    signal triggered

    width: 60
    height: 60
    bodyType: Body.Static
    sleepingAllowed: false

    Behavior on opacity { NumberAnimation {duration: 250 } }

    fixtures: Box {
        width: target.width
        height: target.height
        density: 1
        restitution: 0
        friction: .5
        categories: Utils.kGround | Utils.kGroundTop

        readonly property string type: sensor.type

        onBeginContact: {
            if(other.categories & Utils.kHero)
            {
                if(other.type === "ground")
                {
                    opacity = .7;
                    sensor.triggered();
                }
            }
        }

        onEndContact: {
            if(other.categories & Utils.kHero)
            {
                if(other.type === "ground")
                {
                    console.log("Hero detected!!!");
                    opacity = 1;
                }
            }
        }
    }

    BorderImage {
        anchors.fill: parent
        source: Global.paths.images + "sensors/3d_" + sensor.design + ".png"
        border {
            left: 5; top: 5; right: 5; bottom: 5
        }
    }
}

