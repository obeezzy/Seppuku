import QtQuick 2.9
import QtMultimedia 5.4
import Seppuku 1.0
import "../singletons"

FocusScope {
    id: narrowSlate

    property real slateWidth: 30
    property alias title: titleText.text
    property alias styleColor: titleText.styleColor
    property alias pixelSize: titleText.font.pixelSize
    property Component content: null

    Image {
        anchors.centerIn: parent
        source: Global.paths.images + "menus/small_slate.png"
        mipmap: true
        width: narrowSlate.slateWidth
        fillMode: Image.PreserveAspectFit

        Text {
            id: titleText
            anchors.top: parent.top
            anchors.topMargin: 15
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            width: contentWidth
            height: contentHeight

            text: qsTr("Normal")
            color: "white"

            font {
                family: Stylesheet.defaultFontFamily
                pixelSize: 40
                capitalization: Font.AllLowercase
            }

            style: Text.Outline
            styleColor: "#009bff"
        }

        Loader {
            anchors {
                top: titleText.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                topMargin: 30
            }
            sourceComponent: narrowSlate.content
            onLoaded: item.forceActiveFocus();
        }
    }
}
