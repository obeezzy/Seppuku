import QtQuick 2.9
import Bacon2D 1.0
import Seppuku 1.0
import "../singletons"

Item {
    id: rope
    property PhysicsEntity entityA
    property PhysicsEntity entityB
    property point localAnchorA: Qt.point(entityA.width / 2, entityA.height);
    property point localAnchorB: Qt.point(entityB.width / 2, 0)
    readonly property int maxLength: 12
    readonly property Scene scene: parent

    property real linkDensity: 1

    EntityManager { id: entityManager }

    Component {
        id: linkComponent
        PhysicsEntity {
            id: ball
            width: 12
            height: 12
            bodyType: Body.Dynamic

            property color color: "#EFEFEF"

            fixtures: Circle {
                radius: ball.width / 2
                density: linkDensity
                restitution: 0
                friction: 1
                categories: Utils.kObstacle
                collidesWith: Utils.kHero

                readonly property string type: "rope"

                onBeginContact: {
                    switch(other.categories) {
                    case Utils.kHero:
                        if(other.type === "kunai") {
                            //console.log("Rope: Hit by kunai!")
                            entityManager.destroyEntity(ball.entityId);
                        }
                        break
                    }
                }
            }

            Rectangle {
                radius: parent.width / 2
                border.color: parent.color
                color: parent.color
                width: parent.width
                height: parent.height
                smooth: true
            }
        }
    }

    Component {
        id: jointComponent
        RopeJoint {
            localAnchorA: Qt.point(10,10)
            localAnchorB: Qt.point(10,10)
            maxLength: rope.maxLength
            collideConnected: false

        }
    }

    Component {
        id: dJointComponent

        DistanceJoint {
            id: joint
            frequencyHz: 5
            dampingRatio: 1
            collideConnected: false
//            bodyA: ball.body
//            bodyB: square.body
        }
    }

    Component.onCompleted: {
        var prev = entityA;

        var newLink;
        for(var i = 0; i < 120; i += 12)
        {
            newLink = linkComponent.createObject(scene);
            newLink.color = "#ae703e";
            newLink.x = entityA.x + rope.localAnchorA.x //+ 90;
            newLink.y = entityA.y + entityA.height + i;
            newLink.linearVelocity = Qt.point(0, 0);
            var newJoint = jointComponent.createObject(scene);

            if(i === 0)
                newJoint.localAnchorA = rope.localAnchorA;

            newJoint.bodyA = prev.body;
            newJoint.bodyB = newLink.body;
            prev = newLink;
        }

        newJoint = jointComponent.createObject(scene);
        newJoint.localAnchorB = rope.localAnchorB;
        newJoint.bodyA = prev.body;
        newJoint.bodyB = entityB.body;
    }
}
