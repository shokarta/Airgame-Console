import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../qml/components"

Item {
	id: oauth2Screen
	anchors.fill: parent
	visible: root.oauth2Display

	Rectangle {
		anchors.fill: parent
		color: "black"
		opacity: 0.85
	}

	QRGenerator {
		id: qrObj
		content: loginAPI.deviceTokenJson["user_code"] ? loginAPI.deviceTokenJson["verification_uri"] + "?otc=" + loginAPI.deviceTokenJson["user_code"] : " "
		join: true
	}


	ColumnLayout {
		anchors.centerIn: parent
		width: parent.width * 0.5
		spacing: 20

		CustomText {
			Layout.fillWidth: true
			color: "white"
			pixelSize: modelItem.scale["H2"]
			font.bold: false
			horizontalAlignment: Text.AlignHCenter
			wrapMode: Text.Wrap
			text: loginAPI.deviceTokenJson["message"] || ""
		}

		CustomText {
			Layout.fillWidth: true
			color: "white"
			pixelSize: modelItem.scale["H2"]
			font.bold: false
			horizontalAlignment: Text.AlignHCenter
			wrapMode: Text.Wrap
			text:"Nebo naskenujte kód níže pomocí jíného zařízení"
		}

		Image {
			Layout.preferredWidth: height
			Layout.preferredHeight: oauth2Screen.height / 3
			Layout.alignment: Qt.AlignHCenter
			source: qrObj.svgString !== "" ? ("data:image/svg+xml;utf8," + qrObj.svgString) : ""
		}
	}

	MouseArea {
		anchors.fill: parent
	}
}
