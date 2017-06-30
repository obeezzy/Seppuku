import QtQuick 2.9
import Bacon2D 1.0
import Seppuku 1.0
import "../singletons"

EntityBase {
    id: snowman
    bodyType: Body.Static
    width: 60
    height: 60
    sleepingAllowed: false

    property bool inRange: false
    property bool worn: false
    property int initialY: null
    property alias bounds: bounds
    readonly property int xOffset: actor.x - 12
    z: Global.zDisguise
    type: "snowman"

    Item {
        id: bounds
        y: 0
        height: 0
    }

    readonly property bool withinBounds: {
        if(bounds.x == 0 && bounds.width == 0)
            true;
        else
            (snowman.xOffset > bounds.x && ((snowman.xOffset + width) < (bounds.x + bounds.width)));
    }

    fixtures: Box {
        width: target.width
        height: target.height
        friction: .1
        density: .1
        restitution: .3
        categories: Global.kCovert
        collidesWith: Global.kActor
        sensor: true

        readonly property string type: snowman.type

        onBeginContact: {
            switch(other.categories) {
            case Global.kActor:
                if(other.type === "main_body") {
                    //console.log("Snowman: within range");
                    inRange = true;
                }
                break;
            }
        }

        onEndContact: {
            switch(other.categories) {
            case Global.kActor:
                if(other.type === "main_body") {
                    //console.log("Snowman: out of range");
                    inRange = false;
                }
                break;
            }
        }
    }

    Image {
        anchors.fill: parent
        source: Global.paths.images + "objects/snowman.png"
    }

    Rectangle {
        id: indicator
       color: "transparent"
       border.color: "skyblue"
       border.width: 3
       width: parent.width
       height: width
       visible: inRange && !worn ? true : false
       radius: width

       SequentialAnimation on scale {
           loops: Animation.Infinite
           running: inRange && !worn && !gameWindow.paused ? true : false
           NumberAnimation { from: .1; to: 2; duration: 250 }
           NumberAnimation { from: 2; to: .1; duration: 250 }
       }
    }

    Connections {
        target: actor
        onDisguised: {
            if(!inRange)
                return;

            wearDisguise(putOn);
        }

        onYChanged: {
            wearDisguise(false);
        }
    }

    Binding {
        when: worn && withinBounds
        target: snowman
        value: snowman.xOffset
        property: "x"
    }

//    Binding {
//        when: worn
//        target: snowman
//        value: actor.y - 12
//        property: "y"
//    }

    // Animation when actor is stationary
    PropertyAnimation on y {
        loops: 1
        running: !actor.running && worn
        to: snowman.initialY
        duration: 250
    }

    // Animation when actor is moving
    PropertyAnimation on y {
        loops: 1
        running: actor.running && worn
        to: actor.y - 18
        duration: 100
    }

    onWornChanged: {
        if(!worn)
            y = initialY;
    }

   onWithinBoundsChanged: {
        if(!snowman.withinBounds) {
            snowman.wearDisguise(false);
        }
    }

    function wearDisguise(putOn) {
        worn = putOn;
        if(worn)
           snowman.z = actor.z + 1;
        else
           snowman.z = 0;

        if(actor.wearingDisguise !== putOn)
            actor.toggleDisguise();
    }

    Component.onCompleted: {
        // Helps to remove the bindings. Without this, the snowman returns shortly to its
        // initial position (i.e. the position it was in when picked)
        // when dropped, then returns to the dropped position.
        x = x;
        y = y;
        initialY = y;
    }
}
