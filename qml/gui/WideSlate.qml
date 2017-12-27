import QtQuick 2.9
import Seppuku 1.0
import "../singletons"

FocusScope {
    id: wideSlate

    property alias title: titleText.text
    property alias styleColor: titleText.styleColor
    property alias pixelSize: titleText.font.pixelSize
    property real slateWidth: 500
    property Component content: null

    Image {
        anchors.centerIn: parent
        source: Global.paths.images + "menus/wide_slate.png"
        fillMode: Image.PreserveAspectFit
        width: wideSlate.slateWidth
        //sourceSize: Qt.size(width, height)

        Text {
            id: titleText
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                topMargin: 30
            }
            font.pixelSize: 30
            color: "white"
            text: "options";
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            wrapMode: Text.WordWrap
            style: Text.Outline;
            font {
                pixelSize: 30
                family: Stylesheet.defaultFontFamily
                capitalization: Font.AllLowercase
            }
            styleColor: "red"
        }

        Loader {
            anchors {
                top: titleText.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                topMargin: 60
                bottomMargin: 60
                leftMargin: 30
                rightMargin: 50
            }

            sourceComponent: wideSlate.content
            onLoaded: item.forceActiveFocus();
        }
    }
}

