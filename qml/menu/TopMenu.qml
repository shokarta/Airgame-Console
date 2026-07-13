import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQml.Models
import "../../qml/components"

Rectangle {
	id: objRoot
	anchors.top: parent.top
	anchors.left: parent.left
	anchors.right: parent.right
	height: parent.height * 0.07
	gradient: 	Gradient {
		orientation: Gradient.Vertical
		GradientStop { position: 0.0; color: modelItem.theme["Background/Gradient/Stop1"] }
		GradientStop { position: 0.8; color: modelItem.theme["Background/Gradient/Stop2"] }
		GradientStop { position: 1.0; color: modelItem.theme["Background/Gradient/Stop3"] }
	}

	property string hasFocus: ""
	property string hasHover: ""

	onHasFocusChanged: {
		if (hasFocus !== "searchField") { searchField.focus = false; }

		if (!hasFocus.startsWith("categoryField")) { categoryField.categorymenuExpanded = false; }

		if (hasFocus === "") {}
		else if (hasFocus === "searchField") { searchField.focus = true; }
		else if (hasFocus === "categoryField") { categoryField.focus = true; }
		else if (hasFocus.startsWith("categoryFieldExpanded_")) {}
		else { console.log("unexpected focus:", hasFocus); }
	}


	property string masterFocus: view.hasFocus
	onMasterFocusChanged: if (masterFocus !== "topMenu") { hasFocus = ""; hasHover = ""; categoryField.categorymenuExpanded = false; }

	property alias queryString: searchField


	function twoDigits(num) {
		return num.toString().padStart(2, "0");
	}

	//Behavior on width {	NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

	MouseArea {
		anchors.fill: parent
		enabled: masterFocus === "topMenu" ? false : true
		//z: view.hasFocus === "topMenu" ? topLayout.z - 1 : topLayout.z + 1
		//onClicked: if (view.hasFocus !== "topMenu") { view.hasFocus = "topMenu"; }
		//		   else { objRoot.hasFocus = ""; }
		onClicked: view.hasFocus = "topMenu"
	}

	Keys.priority: Keys.BeforeItem
	Keys.onPressed: (event) => {
						// Avoid repeats if you want single-step D-Pad behavior
						//if (event.isAutoRepeat) { return; }		// in this grid its desirable

						switch (event.key) {
							case Qt.Key_Left:
								//console.log("LEFT");        // D-Pad Left

								if (objRoot.hasFocus === "") {
									objRoot.hasFocus = "searchField";
									event.accepted = true;
								}
								else if (objRoot.hasFocus === "searchField") {
									// do nothing, we are already at very left
									event.accepted = false;
								}
								else {
									// we are anywhere else, so we wish to step on searchField
									objRoot.hasFocus = "searchField";
									event.accepted = true;
								}
							break;

							case Qt.Key_Right:
								//console.log("RIGHT");       // D-Pad Right

								if (objRoot.hasFocus === "") {
									objRoot.hasFocus = "categoryField";
									event.accepted = true;
								}
								else if (objRoot.hasFocus === "searchField") {
									objRoot.hasFocus = "categoryField";
									event.accepted = true;
								}
								else {
									// do nothing, we are already at very right
									event.accepted = false;
								}
							break;

							case Qt.Key_Up:
								//console.log("UP");          // D-Pad Up

								if (objRoot.hasFocus.startsWith("categoryFieldExpanded_")) {
									if (objRoot.hasFocus === "categoryFieldExpanded_00") {
										// first item of categoryFieldExpanded_xx, close categoryFieldExpanded and go to categoryField
										categoryField.categorymenuExpanded = false;
										objRoot.hasFocus = "categoryField";
										event.accepted = true;
									}
									else {
										var currentIndex = Number(objRoot.hasFocus.split("_")[1]);
										objRoot.hasFocus = "categoryFieldExpanded_" + objRoot.twoDigits(currentIndex-1);
										event.accepted = true;
									}
								}
								else {
									// do nothing
								}
							break;

							case Qt.Key_Down:
								//console.log("DOWN");        // D-Pad Down

								if (objRoot.hasFocus.startsWith("categoryFieldExpanded_")) {
									var currentIndex = Number(objRoot.hasFocus.split("_")[1]);
									if (currentIndex < modelItem.categoryList.count-1) {
										objRoot.hasFocus = "categoryFieldExpanded_" + objRoot.twoDigits(currentIndex+1);
										event.accepted = true;
									}
									else {
										// last item of categoryFieldExpanded_xx, therefore do nothing (or close categoryFieldExpanded and go to mainMenu?)
										event.accepted = false;
									}
								}
								else {
									objRoot.hasFocus = "";
									//topMenu.focus = false;
									//mainMenu.focus = true;
									view.hasFocus = "mainMenu";
									if (mainMenu.children[0].children[0].itemAtColSelected === undefined) { mainMenu.children[0].children[0].itemAtColSelected = 0; }
									if (mainMenu.children[0].children[0].itemAtRowSelected === undefined) { mainMenu.children[0].children[0].itemAtRowSelected = 0; }
									event.accepted = true;
								}
							break;

							// Confirm/OK (Android DPAD_CENTER maps to Qt.Key_Select)
							case Qt.Key_Select:
							case Qt.Key_Return:
							case Qt.Key_Enter:
								//console.log("CONFIRM / OK");

								if (objRoot.hasFocus.startsWith("categoryFieldExpanded_")) {
									var currentIndex = Number(objRoot.hasFocus.split("_")[1]);
									modelItem.categoryList.setProperty(currentIndex, "selected", !modelItem.categoryList.get(currentIndex).selected);
									modelItem.categoryList.provideSelectedCategories();
									modelItem.filteredGameList.refreshAsync();
									event.accepted = true;
								}
								else if (objRoot.hasFocus === "categoryField") {
									categoryField.categorymenuExpanded = !categoryField.categorymenuExpanded;
									if (modelItem.categoryList.count > 0) { objRoot.hasFocus = "categoryFieldExpanded_00"; }
									event.accepted = true;
								}
								else if (objRoot.hasFocus === "searchField") {
									objRoot.hasFocus = "";
									event.accepted = true;
								}
								else {
									// do nothing
									event.accepted = false;
								}
							break;

							// Android Back (remote back button & phone back key)
							case Qt.Key_Back:
							case Qt.Key_Escape:
								//console.log("BACK");
								// If you do NOT accept, Android will close the Activity.

								if (objRoot.hasFocus.startsWith("categoryFieldExpanded_")) {
									objRoot.hasFocus = "categoryField";
									categoryField.categorymenuExpanded = false;
									event.accepted = true;
								}
								else {
									// do nothing
									event.accepted = false;
								}
							break;

							default:
								// let others handle it
							break;
						}
					}

	// Line
	Rectangle {
		anchors.bottom: parent.bottom
		anchors.left: parent.left
		anchors.right: parent.right
		height: modelItem.scale["LINE"]
		color: modelItem.theme["Outline/Main"]
	}


	// Total game amount
	CustomText {
		anchors.verticalCenter: parent.verticalCenter
		anchors.left: parent.left;			anchors.leftMargin: leftMenu.focusInactiveWidth + parent.height * 0.2
		pixelSize: modelItem.scale["C1"]
		color: modelItem.theme["Text/Standard"]
		text: "TOTAL: " + mainMenu.children[0].children[0].count
	}


	RowLayout {
		id: topLayout
		anchors.top: parent.top;			anchors.topMargin: parent.height * 0.05
		anchors.left: parent.left;			anchors.leftMargin: leftMenu.focusActiveWidth + parent.height * 0.2
		anchors.right: parent.right;		anchors.rightMargin: parent.height * 0.2
		anchors.bottom: parent.bottom;		anchors.bottomMargin: parent.height * 0.05
		spacing: 0

		property real fontPixelSize: parent.height * 0.35

		// SEARCH FIELD
		TextField {
			id: searchField
			Layout.preferredWidth: parent.width * 0.4
			Layout.preferredHeight: parent.height * 0.8
			Layout.alignment: Qt.AlignVCenter

			horizontalAlignment: TextField.AlignLeft
			verticalAlignment: TextField.AlignVCenter

			font.pixelSize: topLayout.fontPixelSize
			leftPadding: button_search_rect.width
			color: categoryField.buttonLoaded ? "white" : "gray"	//modelItem.theme["Text/Hint"]

			enabled: searchField.buttonLoaded
			hoverEnabled: true	// view.hasFocus === "topMenu"

			onFocusChanged: if (focus) {
								if (view.hasFocus !== "topMenu") { view.hasFocus = "topMenu"; }
								objRoot.hasFocus = "searchField";
							}

			onHoveredChanged: if (hovered) { objRoot.hasHover = "searchField"; }
							  else { objRoot.hasHover = ""; }

			property bool buttonLoaded: modelItem.fullGameList.titleListSimpleFinished

			background: Rectangle {
				color: modelItem.theme["Background/Form/Inactive"]
				radius: modelItem.scale["RADIUS"]
				border.color: modelItem.theme["Outline/Form/Inactive"]
				border.width: modelItem.scale["BORDER"]
			}
			placeholderText: text || focus ? "" : "Seach game by name"
			placeholderTextColor: modelItem.theme["Text/Hint"]
			text: modelItem.filteredGameList.queryString
			onTextChanged: {
				mainMenu.children[0].children[0].resetView();
				modelItem.filteredGameList.queryString = searchField.text;
				modelItem.filteredGameList.refreshAsync();
			}
			inputMethodHints: Qt.ImhNoPredictiveText

			Rectangle {
				anchors.centerIn: parent
				width: parent.width + modelItem.scale["PADDING"]
				height: parent.height + modelItem.scale["PADDING"]
				radius: modelItem.scale["RADIUS"]*1.5
				color: "transparent"
				border.width: modelItem.scale["LINE"]
				border.color: "white"
				visible: objRoot.hasHover === "searchField" || objRoot.hasFocus === "searchField"
			}

			// RETURN key handler - does replace
			Keys.onPressed: event => { if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) { objRoot.hasFocus = ""; } }

			// SEARCH ICON
			Item {
				id: button_search_rect
				anchors.top: parent.top
				anchors.left: parent.left
				anchors.bottom: parent.bottom
				width: height

				ColorImage {
					id: button_search_image
					anchors.centerIn: parent
					sourceSize.height: parent.height * 0.5
					fillMode: Image.PreserveAspectFit
					asynchronous: true
					source: "../../resources/images/icon_search.svg"
					color: searchField.buttonLoaded ? "white" : "gray"	//modelItem.theme["Text/Hint"]
				}
				MouseArea {
					anchors.fill: parent
					onClicked: searchField.focus = !searchField.focus
				}
			}
		}


		// Extra Space
		Item {
			Layout.fillWidth: true
			Layout.fillHeight: true
		}


		// SORT FIELD
		Rectangle {
visible: false	// TODO
			id: sortField
			Layout.preferredWidth: parent.width * 0.2
			Layout.preferredHeight: parent.height * 0.8
			Layout.alignment: Qt.AlignVCenter

			color: modelItem.theme["Background/Form/Inactive"]
			radius: modelItem.scale["RADIUS"]
			border.color: if (sortField.focus) { return modelItem.theme["Outline/Form/Active"]; }
						  else { return modelItem.theme["Outline/Form/Inactive"]; }
			border.width: modelItem.scale["BORDER"]

			property bool sortFieldExpanded: false

			Rectangle {
				anchors.centerIn: parent
				width: parent.width + modelItem.scale["PADDING"]
				height: parent.height + modelItem.scale["PADDING"]
				radius: modelItem.scale["RADIUS"]*1.5
				color: "transparent"
				border.width: modelItem.scale["LINE"]
				border.color: "white"
				visible: objRoot.hasHover === "sortField" || objRoot.hasFocus === "sortField"
			}

			CustomText {
				anchors.left: parent.left; anchors.leftMargin: parent.height / 2
				anchors.verticalCenter: parent.verticalCenter
				verticalAlignment: Text.AlignBottom
				pixelSize: topLayout.fontPixelSize
				color: "white"
				text: "Sort by"
			}
			CustomText {
				anchors.right: parent.right; anchors.rightMargin: parent.height / 2
				anchors.verticalCenter: parent.verticalCenter
				verticalAlignment: Text.AlignBottom
				pixelSize: topLayout.fontPixelSize
				color: "white"
				text: sortField.sortFieldExpanded ? "▼" : "▲"
			}

			MouseArea {
				anchors.fill: parent
				enabled: true
				hoverEnabled: true
				onEntered: objRoot.hasHover = "sortField"
				onExited: objRoot.hasHover = ""
				onClicked: {
					if (view.hasFocus !== "topMenu") { view.hasFocus = "topMenu"; }

					sortField.sortFieldExpanded = !sortField.sortFieldExpanded;

					if (sortField.sortFieldExpanded) {
						if (modelItem.sortFieldList.count > 0) { objRoot.hasFocus = "sortFieldExpanded_00"; }
					}
				}
			}

			// Expanded Menu
			Rectangle {
				id: sortFieldExpanded
				anchors.top: parent.bottom
				anchors.left: parent.left
				anchors.right: parent.right
				radius: modelItem.scale["RADIUS"]
				border.color: if (sortField.focus) { return modelItem.theme["Outline/Form/Active"]; }
							  else { return modelItem.theme["Outline/Form/Inactive"]; }
				border.width: modelItem.scale["BORDER"]

				height: sortFieldColumnLayout.height		//modelItem.sortFieldList.count * rowHeight
				color: modelItem.theme["Background/Form/Inactive"]
				visible: sortField.sortFieldExpanded

				property real rowHeightRatio: 0.85

				ColumnLayout {
					id: sortFieldColumnLayout
					anchors.top: parent.top
					anchors.left: parent.left
					anchors.right: parent.right
					spacing: 0

					Repeater {
						model: modelItem.sortFieldList

						Rectangle {
							Layout.fillWidth: true
							Layout.preferredHeight: sortField.height * sortFieldExpanded.rowHeightRatio
							color: if (index >= 0) {
									   if (objRoot.hasFocus === "sortFieldExpanded_" + ("0" + index).slice(-2)) { return modelItem.theme["Background/Form/Active"]; }
									   else if (boxArea.containsMouse === true) { return modelItem.theme["Background/Form/Active"]; }
									   else { return modelItem.theme["Background/Form/Inactive"]; }
								   }
								   else { return "transparent"; }

							property bool selected: index >=0 ? modelItem.sortFieldList.get(index).code === modelItem.filteredGameList.sortingField : false

							Rectangle {
								id: indicator
								anchors.left: parent.left;		anchors.leftMargin: height / 2
								anchors.verticalCenter: parent.verticalCenter
								width: sortField.height * sortFieldExpanded.rowHeightRatio * 0.5
								height: sortField.height * sortFieldExpanded.rowHeightRatio * 0.5
								color: "transparent"		// modelItem.theme["Background/Form/Inactive"]
								border.color: parent.selected ? modelItem.theme["Text/Link"] : modelItem.theme["Text/Hint"]
								border.width: modelItem.scale["BORDER"]
								radius: height / 2

								Rectangle {
									anchors.centerIn: parent
									width: height
									height: parent.height * 0.6
									color: modelItem.theme["Text/Link"]
									visible: parent.parent.selected
									radius: height / 2
								}
							}
							CustomText {
								anchors.left: indicator.right;		anchors.leftMargin: parent.height / 3
								anchors.right: parent.right;		anchors.rightMargin: parent.height / 3
								anchors.verticalCenter: parent.verticalCenter
								pixelSize: topLayout.fontPixelSize * sortFieldExpanded.rowHeightRatio
								elide: Text.ElideRight; maximumLineCount: 1
								color: modelItem.theme["Text/Standard"]
								text: index >=0 ? modelItem.sortFieldList.get(index).name : ""
							}

							MouseArea {
								id: boxArea
								anchors.fill: parent
								hoverEnabled: true
								onContainsMouseChanged: {
									if (containsMouse) {
										console.log("sortFieldExpanded_" + ("0" + index).slice(-2))
									}
								}
								onClicked: {

								}
							}
						}
					}
				}
			}
		}


		// Extra Space
		Item {
			Layout.fillWidth: true
			Layout.fillHeight: true
		}


		// CATEGORIES
		Rectangle {
			id: categoryField
			Layout.preferredWidth: parent.width * 0.35
			Layout.preferredHeight: parent.height * 0.8
			Layout.alignment: Qt.AlignVCenter

			color: modelItem.theme["Background/Form/Inactive"]
			radius: modelItem.scale["RADIUS"]
			border.color: if (categoryField.focus) { return modelItem.theme["Outline/Form/Active"]; }
						  else { return modelItem.theme["Outline/Form/Inactive"]; }
			border.width: modelItem.scale["BORDER"]

			property bool categorymenuExpanded: false
			// onCategorymenuExpandedChanged: if (categoryFieldExpanded) {
			// 								   if (modelItem.categoryList.count > 0) { objRoot.hasFocus = "categoryFieldExpanded_00"; }
			// 							   }

			property bool buttonLoaded: modelItem.fullGameList.titleListSimpleFinished

			Rectangle {
				anchors.centerIn: parent
				width: parent.width + modelItem.scale["PADDING"]
				height: parent.height + modelItem.scale["PADDING"]
				radius: modelItem.scale["RADIUS"]*1.5
				color: "transparent"
				border.width: modelItem.scale["LINE"]
				border.color: "white"
				visible: objRoot.hasHover === "categoryField" || objRoot.hasFocus === "categoryField"
			}

			CustomText {
				anchors.left: parent.left; anchors.leftMargin: parent.height / 2
				anchors.verticalCenter: parent.verticalCenter
				verticalAlignment: Text.AlignBottom
				pixelSize: topLayout.fontPixelSize
				color: categoryField.buttonLoaded ? "white" : "gray"	//modelItem.theme["Text/Hint"]
				text: "Game Genres"
			}
			CustomText {
				anchors.right: parent.right; anchors.rightMargin: parent.height / 2
				anchors.verticalCenter: parent.verticalCenter
				verticalAlignment: Text.AlignBottom
				pixelSize: topLayout.fontPixelSize
				color: categoryField.buttonLoaded ? "white" : "gray"	//modelItem.theme["Text/Hint"]
				text: categoryField.categorymenuExpanded ? "▼" : "▲"
			}

			MouseArea {
				anchors.fill: parent
				enabled: categoryField.buttonLoaded
				hoverEnabled: categoryField.buttonLoaded
				onEntered: objRoot.hasHover = "categoryField"
				onExited: objRoot.hasHover = ""
				onClicked: {
					if (view.hasFocus !== "topMenu") { view.hasFocus = "topMenu"; }

					categoryField.categorymenuExpanded = !categoryField.categorymenuExpanded;

					if (categoryField.categorymenuExpanded) {
						if (modelItem.categoryList.count > 0) { objRoot.hasFocus = "categoryFieldExpanded_00"; }
					}
				}
			}

			// Expanded Menu
			Rectangle {
				id: categoryFieldExpanded
				anchors.top: parent.bottom
				anchors.left: parent.left
				anchors.right: parent.right
				radius: modelItem.scale["RADIUS"]
				border.color: if (categoryField.focus) { return modelItem.theme["Outline/Form/Active"]; }
							  else { return modelItem.theme["Outline/Form/Inactive"]; }
				border.width: modelItem.scale["BORDER"]

				height: categoryColumnLayout.height		//modelItem.categoryList.count * rowHeight
				color: modelItem.theme["Background/Form/Inactive"]
				visible: categoryField.categorymenuExpanded

				property real rowHeightRatio: 0.85

				ColumnLayout {
					id: categoryColumnLayout
					anchors.top: parent.top
					anchors.left: parent.left
					anchors.right: parent.right
					spacing: 0

					Repeater {
						model: modelItem.categoryList

						Rectangle {
							Layout.fillWidth: true
							Layout.preferredHeight: categoryField.height * categoryFieldExpanded.rowHeightRatio
							color: if (index >= 0) {
									   if (objRoot.hasFocus === "categoryFieldExpanded_" + ("0" + index).slice(-2)) { return modelItem.theme["Background/Form/Active"]; }
									   else if (box.hovered === true) { return modelItem.theme["Background/Form/Active"]; }
									   else { return modelItem.theme["Background/Form/Inactive"]; }
								   }
								   else { return "transparent"; }

							CheckBox {
								id: box
								anchors.top: parent.top
								anchors.left: parent.left;			anchors.leftMargin: categoryField.height/2
								anchors.right: parent.right;		anchors.rightMargin: categoryField.height/2
								anchors.bottom: parent.bottom
								spacing: parent.height / 3
								padding: 0

								checked: index >=0 ? modelItem.categoryList.get(index).selected : false

								enabled: index >=0 ? modelItem.categoryList.get(index).available : false
								hoverEnabled: index >=0 ? modelItem.categoryList.get(index).available : false

								onToggled: {
									objRoot.hasFocus = "categoryFieldExpanded_" + ("0" + index).slice(-2);
									modelItem.categoryList.setProperty(index, "selected", checked);
									modelItem.categoryList.provideSelectedCategories();
									modelItem.filteredGameList.refreshAsync();
								}

								text: index >=0 ? modelItem.categoryList.get(index).categoryNameLocalized : ""

								indicator: Rectangle {
									anchors.verticalCenter: parent.verticalCenter
									width: categoryField.height * categoryFieldExpanded.rowHeightRatio * 0.5
									height: categoryField.height * categoryFieldExpanded.rowHeightRatio * 0.5
									color: "transparent"		// modelItem.theme["Background/Form/Inactive"]
									border.color: box.checked ? modelItem.theme["Text/Link"] : modelItem.theme["Text/Hint"]
									border.width: modelItem.scale["BORDER"]

									Cross {
										height: parent.height * 0.8
										color: modelItem.theme["Text/Link"]
										visible: box.checked
									}
								}
								contentItem: CustomText {
									text: box.text
									anchors.verticalCenter: parent.verticalCenter
									pixelSize: topLayout.fontPixelSize * categoryFieldExpanded.rowHeightRatio
									elide: Text.ElideRight; maximumLineCount: 1
									color: if (index >=0) {
											   if (modelItem.categoryList.get(index).available) { return modelItem.theme["Text/Standard"]; }
											   else { return modelItem.theme["Text/Hint"]; }
										   }
										   else { return modelItem.theme["Text/Hint"]; }
									leftPadding: box.indicator.width + box.spacing
								}
							}
						}
					}
				}
			}
		}
	}
}
