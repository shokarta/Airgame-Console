import QtQuick
import QtQuick.Controls
import "../../qml/components"
//import MyFboItem

Rectangle {
	id: gamePlayer
	anchors.fill: parent
	color: "yellow"
	visible: root.gamePlayerVisible
	onVisibleChanged: console.log("GamePlayer visible:", visible)


	//MyFboItem {
	//	id: fboItem
	//	objectName: "fboItem"

	//	width: parent.width
	//	height: parent.height

	//	anchors.fill: parent
	//}
}
