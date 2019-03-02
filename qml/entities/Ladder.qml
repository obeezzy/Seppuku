import QtQuick 2.12
import Bacon2D 1.0
import "../singletons"

EntityBase {
    entityType: "ladder"

    fixtures: Box {
        sensor: true
        categories: Utils.kLadder
    }
}
