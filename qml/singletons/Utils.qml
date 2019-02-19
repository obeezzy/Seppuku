pragma Singleton
import QtQuick 2.9
import Bacon2D 1.0

// ----------- Prefixes --------------
// k = Box2D Category
// g = Group index
// z = position on z axis

Item {
    id: utils

    QtObject {
        id: privateProperties
    }

    // const static variables
    readonly property real degToRad: Math.PI / 180

    /************************* UTILITY OBJECTS *******************************************/
    // Ignore collisions
    readonly property int kIntangible: Box.None

    // Hit everything
    readonly property int kAll: Box.All

    // Hit nothing
    readonly property int kNone: Box.None

    // Enemy's main body area
    readonly property int kEnemy: Box.Category1

    // Hero's main body area
    readonly property int kHero: Box.Category2

    /****************** INVENTORIES ***********************/
    readonly property int kCollectible: Box.Category3

    /****************** OBSTACLES ********************/
    readonly property int kObstacle: Box.Category4

    /***************** OBJECTS FOR UNDERCOVER *************/
    readonly property int kCovert: Box.Category5

    // Colliding with ground and walls
    readonly property int kLadder: Box.Category6

    // Colliding with signs
    // NOTE: put under "usables" category
    readonly property int kInteractive: Box.Category7

    // Colliding with pipes
    readonly property int kHoverArea: Box.Category8

    // Colliding with the bottom of the scene
    readonly property int kLava: Box.Category9

    // Colliding with doors
    readonly property int kDoor: Box.Category10

    // Colliding with "camera moments"
    readonly property int kCameraMoment: Box.Category11

    // Rigid bodies
    readonly property int kWall: Box.Category14
    readonly property int kGround: Box.Category15
    readonly property int kGroundTop: Box.Category16



    /************** GROUP INDEXES **********************/
    readonly property int gHeroGroupIndex: 1


    // Z POSITIONS
    readonly property int zHero: 10
    readonly property int zInteractive: zHero - 1
    readonly property int zHeroDisguised: 0
    readonly property int zDisguise: 4
    readonly property int zEnemy: 1
    readonly property int zHUD: 49
    readonly property int zTutor: zHUD
    readonly property int zCollectible: zHero + 1
    readonly property int zCannonBullet: -1
    readonly property int zLaser: 11
    readonly property int zLava: 30
    readonly property int zCamera: 100
    readonly property int zPopup: 101

    /********* END GROUP INDEXES ***************************/

    /**************** FUNCTIONS *******************************/
    function degreesToRadians(degrees) {
        return degrees * Math.PI / 180;
    }

    function radiansToDegrees(radians) {
        return radians * 180 / Math.PI;
    }

    function toTimeString(timeInSeconds) {
        return Qt.formatTime(new Date(timeInSeconds * 1000), "mm:ss");
    }

    function invertPoint(point) {
        return Qt.point(-point.x, -point.y);
    }

    function applyLimit(limit, entity) {
        if (entity !== null && entity.objectId > -1 && Object(entity).hasOwnProperty("limits")) {
            switch (limit.edge) {
            case "top": entity.limits.topY = limit.y; break;
            case "bottom": entity.limits.bottomY = limit.y - entity.height; break;
            case "left": entity.limits.leftX = limit.x; break;
            case "right": entity.limits.rightX = limit.x - entity.width; break;
            }
        }
    }

    /********** END FUNCTIONS **************************************/
}

