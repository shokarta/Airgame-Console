import QtQuick
//import Qt5Compat.GraphicalEffects	// Qt5
import QtQuick.Effects				// Qt6


// Qt5
//Image {
//	id: objRoot
//	property color color
//	smooth: false
//	asynchronous: true

//	layer {
//		enabled: true
//		effect: ColorOverlay {
//			color: objRoot.color
//		}
//	}
//}

// Qt6
Item {
	id: objRoot
	width: sourceImage.width
	height: sourceImage.height

	property color color: "transparent"
	property size sourceSize: undefined
	property int fillMode: undefined
	property bool asynchronous: true
	property string source: ""

	Image {
		id: sourceImage
		anchors.fill: objRoot.sourceSize === undefined ? objRoot : undefined
		source: objRoot.source
		sourceSize: objRoot.sourceSize
		//width: objRoot.width
		//height: objRoot.height
		fillMode: objRoot.fillMode
		visible: false
	}

	MultiEffect {
		source: sourceImage
		anchors.fill: sourceImage
		colorization: 1.0
		colorizationColor: objRoot.color
	}
}
