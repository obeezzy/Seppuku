import QtQuick 2.9
import Seppuku 1.0
import "../singletons"

Item {
    width: labelText.width
    height: labelText.height

    property alias text: labelText.text
    property alias styleColor: labelText.styleColor

    Text {
        id: labelText
        anchors.centerIn: parent
        width: contentWidth
        height: contentHeight
        color: "white"
        text: "label";
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter
        wrapMode: Text.WordWrap
        style: Text.Outline
        font {
            pixelSize: 34
            capitalization: Font.AllLowercase
            family: Stylesheet.defaultFontFamily
        }
        styleColor: Qt.darker("#F3D792", 1.2)
    }
}

