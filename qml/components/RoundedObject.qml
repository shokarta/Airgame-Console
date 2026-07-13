import QtQuick
import Qt5Compat.GraphicalEffects		// Qt5
//import QtQuick.Effects				// Qt6

OpacityMask {		// Qt5
	id: opacityMask

	property alias radius: maskRect.radius
	property bool showLine: false
	property bool showŚelected: false
	property bool forceRadius: false
	property color color: "white"

	maskSource: Rectangle {
		id: maskRect
		width: opacityMask.width
		height: opacityMask.height
		radius: opacityMask.forceRadius ? opacityMask.radius : width / 2
		color: "white"
	}

	Rectangle {
		id: lineRect
		anchors.centerIn: parent
		width: opacityMask.width
		height: opacityMask.height
		color: "transparent"
		radius: opacityMask.radius
		border.width: modelItem.scale["BORDER"]
		border.color: "grey"
		visible: showLine
	}

	Rectangle {
		id: selectedRect
		anchors.centerIn: parent
		width: opacityMask.width + modelItem.scale["PADDING"]
		height: opacityMask.height + modelItem.scale["PADDING"]
		color: "transparent"
		radius: opacityMask.forceRadius ? opacityMask.radius : width / 2
		border.width: modelItem.scale["LINE"]
		border.color: opacityMask.color
		visible: showŚelected
	}
}

// Qt6
//MultiEffect {
//	width: img.width
//	height: img.height
//	maskEnabled: true
//	maskSource: Rectangle {
//		width: img.width
//		height: img.height
//		radius: 20 // Adjust for desired roundness
//	}

// 	// Critical for smooth edges in Qt 6
// 	maskThresholdMin: 0.5
// 	maskSpreadAtMin: 1.0
//}
