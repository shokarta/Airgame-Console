import QtQuick
import QtQuick.Layouts

RowLayout {
	id: objRoot

	Layout.fillWidth: true

	spacing: modelItem.scale["SPACING"]
	visible: text === "" ? false : true

	property string text: ""
	property string icon: ""

	property real textSize: modelItem.scale["H2"]
	property color color: modelItem.theme["Text/Standard"]

	ColorImage {
		id: headerIcon
		Layout.alignment: Qt.AlignVCenter
		sourceSize.height: headerText.lineHeight * 0.8
		fillMode: Image.PreserveAspectFit
		asynchronous: true
		source: objRoot.icon
		visible: source === "" ? false : true
	}

	CustomText {
		id: headerText
		Layout.fillWidth: true
		Layout.alignment: Qt.AlignVCenter
		elide: Text.ElideRight; maximumLineCount: 1
		color: objRoot.color
		pixelSize: objRoot.textSize
		text: objRoot.text
	}
}
