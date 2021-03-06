import QtQuick 2.9
import Bacon2D 1.0
import QtMultimedia 5.9
import Seppuku 1.0
import "../../js/Fish.js" as Ai
import "../singletons"

EntityBase {
    id: fish
    entityType: "fish"

    signal selfDestruct

    property int startX: 0
    property int endX: 0
    readonly property int xStep: 4

    // Is this enemy dead
    property bool dead: false

    // Am I striking the hero
    property bool striking: false

    property real healthStatus: 1

    QtObject {
        id: privateProperties

        property bool facingLeft: false
        readonly property bool facingRight: !facingLeft
    }

    width: 40
    height: 55
    updateInterval: Ai.updateInterval
    bodyType: fish.dead || fish.striking ? Body.Dynamic : Body.Static
    sleepingAllowed: false
    fixedRotation: true
    z: Math.max(Utils.zLava, Utils.zEnemy) + 1

    sender: "fish"

    fixtures: [
        Box {
            id: mainBody
            friction: .1
            density: .2
            restitution: .5
            width: target.width
            height: target.height
            categories: Utils.kEnemy
            collidesWith: {
                if(hero !== null && (hero.wearingDisguise || hero.dead))
                    Utils.kGround | Utils.kWall | Utils.kLava
                else
                    Utils.kGround | Utils.kHero | Utils.kWall | Utils.kLava
            }

            readonly property string type: "main_body"
            readonly property bool dead: fish.dead
            readonly property string sender: fish.sender
            readonly property real damage: 1

            onBeginContact: {
                if(fish.dead)
                    return;

                if((other.categories & Utils.kLava) && other.type === "fish_depth") {
                    fish.striking = false;
                    console.log("Stop striking!");
                }
            }
        }
    ]

    AnimatedSprite {
        id: sprite
        spriteSheet: SpriteSheet {
            source: Global.paths.images + "pests/fish_swim.png"
            horizontalFrameCount: 2
        }
//      source: Global.paths.images + "pests/fish_dead.png"
        horizontalMirror: privateProperties.facingRight
        animation: "swim"
        anchors.horizontalCenter: parent.horizontalCenter

        animations: [
            SpriteAnimation {
                name: "swim"
                duration: 500
                loops: Animation.Infinite
            },

            SpriteAnimation {
                name: "dead"
                duration: 500
                loops: Animation.Infinite
            }
        ]
    }

    behavior: ScriptBehavior {
        script: {
            if(Ai.getTicks() >= Ai.getWaitDelay())
            {
                //fish.strike();
                Ai.resetTicks();
            }

            if(privateProperties.facingLeft)
            {
                if(fish.x > fish.startX)
                    fish.swimLeft();
                else
                    privateProperties.facingLeft = false;
            }
            else {
                if(fish.x < fish.endX)
                    fish.swimRight();
                else
                    privateProperties.facingLeft = true;
            }

            Ai.tick();
        }
    }

    function swimRight() {
        privateProperties.facingLeft = false;
        fish.x += fish.xStep;
    }

    function swimLeft() {
        privateProperties.facingLeft = true;
        fish.x -= fish.xStep;
    }

    function strike() {
        console.log("Fish: Striking...");
        fish.striking = true;
        fish.applyLinearImpulse(Qt.point(0, 10), fish.getWorldCenter());
    }
}



