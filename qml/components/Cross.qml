import QtQuick
import QtQuick.Layouts

ColorImage {
	property bool isInLayout: parent && parent.toString().includes("Layout")
	property bool isAnchored: !isInLayout

	Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
	anchors.centerIn: isAnchored ? parent : undefined

	Layout.preferredWidth: height
	width: height

	Layout.preferredHeight: parent.height / 2.5
	height: parent.height / 2.5

	sourceSize.height: height

	fillMode: Image.PreserveAspectFit
	asynchronous: true
	source: "../../resources/images/icon_close.svg"
	color: modelItem.theme["Text/Standard"]
}
