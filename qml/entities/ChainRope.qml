import QtQuick 2.9
import Bacon2D 1.0
import Seppuku 1.0
import "../singletons"

Item {
    id: chainRope
    width: 100
    height: 62

    property Item entityA
    property Item entityB
    property point localAnchorA: Qt.point(entityA.width / 2, entityA.height);
    property point localAnchorB: Qt.point(entityB.width / 2, 0)
    readonly property Scene scene: parent

    property real linkDensity: 1
    property int length: 3

    EntityManager { id: entityManager; parentScene: chainRope.scene }

    Component {
        id: linkComponent

        PhysicsEntity {
            id: ball
            width: 12
            height: 12
            bodyType: Body.Dynamic

            property color color: "#EFEFEF"

            fixtures: Box {
                width: target.width
                height: target.height
                density: linkDensity
                restitution: 0
                friction: 1
                categories: Utils.kObstacle
                collidesWith: Utils.kActor

                readonly property string type: "rope"

                onBeginContact: {
                    if(other.categories & Utils.kActor) {
                        if(other.type === "kunai") {
                            //console.log("Rope: Hit by kunai!")
                            entityManager.removeEntity(chainRope.entityId);
                        }
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

        RevoluteJoint {
            localAnchorA: Qt.point(10,10) // the point in body A around which it will rotate; anchor from the center
            localAnchorB: Qt.point(10,10) // the point in body B around which it will rotate; anchor from the center
            collideConnected: false
            referenceAngle: 0 // an angle between bodies considered to be zero for the joint angle
            enableLimit: false // whether the joint limits will be active
            lowerAngle: 0 // angle for the lower limit
            upperAngle: 0 // angle for the upper limit
            enableMotor: false // whether the joint motor will be active
            motorSpeed: 0 // the target speed of the joint motor
            maxMotorTorque: 1 // the maximum allowable torque the motor can use
        }
    }

    Component.onCompleted: {
        var prev = entityA;

        var newLink;
        for(var i = 0; i < chainRope.length; ++i)
        {
            newLink = linkComponent.createObject(scene);
            newLink.color = "#ae703e";
            newLink.x = entityA.x + entityA.width / 2;
            newLink.y = entityA.y + entityA.height + newLink.height * i;
            newLink.linearVelocity = Qt.point(0, 0);

            var newJoint = jointComponent.createObject(scene);

            if(i === 0)
                newJoint.localAnchorA = chainRope.localAnchorA;
            else
                newJoint.localAnchorA = Qt.point(prev.width / 2, prev.height);

            newJoint.localAnchorB = Qt.point(newLink.width / 2, 0);

            newJoint.bodyA = prev.body;
            newJoint.bodyB = newLink.body;
            prev = newLink;
        }

        newJoint = jointComponent.createObject(scene);
        newJoint.localAnchorB = chainRope.localAnchorB;
        newJoint.bodyA = prev.body;
        newJoint.bodyB = entityB.body;
    }
}

