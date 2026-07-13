import QtQuick

Text {
	property real pixelSize: modelItem.scale["P1"]

	font.pixelSize: pixelSize
	font.kerning: false
	//font.preferShaping: false
	font.preferTypoLineMetrics: true
	//font.family: fontInter.font.family
	font.bold: (pixelSize === modelItem.scale["H1"] || pixelSize === modelItem.scale["H2"]) ? true : false
	lineHeightMode: Text.FixedHeight
	lineHeight: if (lineHeightMode === Text.FixedHeight) {
					if (pixelSize === modelItem.scale["H1"]) { return modelItem.scale["H1/Line"]; }
					else if (pixelSize === modelItem.scale["H2"]) { return modelItem.scale["H2/Line"]; }
					else if (pixelSize === modelItem.scale["P1"]) { return modelItem.scale["P1/Line"]; }
					else if (pixelSize === modelItem.scale["C1"]) { return modelItem.scale["C1/Line"]; }
					else { return pixelSize * 1.5; }
				}
				else if (lineHeightMode === Text.ProportionalHeight) { return 1; }
	wrapMode: Text.Wrap
	//color: if (children.some(child => child instanceof MouseArea)) { return modelItem.theme["Text/Link"]; }
	//	   else if (pixelSize === modelItem.scale["C1"]) { return modelItem.theme["Text/Hint"]; }
	//	   else { return modelItem.theme["Text/Standard"]; }
	color: pixelSize === modelItem.scale["C1"] ? modelItem.theme["Text/Hint"] : modelItem.theme["Text/Standard"]
	renderType: Text.NativeRendering
	renderTypeQuality: Text.DefaultRenderTypeQuality
	//horizontalAlignment: Text.AlignHCenter
	verticalAlignment: Text.AlignVCenter
	visible: text !== ""
}
