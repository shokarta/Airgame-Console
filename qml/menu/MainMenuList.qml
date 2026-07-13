import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../qml/components"

Item {
	id: masterItem
	onFocusChanged: if (focus) { gridMenu.focus = true; }

	GridView {
		id: gridMenu
		cacheBuffer: root.height
		//reuseItems: false

		anchors.fill: parent
			anchors.topMargin: topMenu.height + margin
			anchors.leftMargin: leftMenu.focusInactiveWidth + margin
			anchors.rightMargin: margin
			anchors.bottomMargin: margin


		keyNavigationEnabled: false
		interactive: gridMenu.focus
		boundsBehavior: Flickable.StopAtBounds
		flickableDirection: Flickable.VerticalFlick

		property real spacing: modelItem.scale["PADDING"]
		property real margin: modelItem.scale["PADDING"]

		property int columns: 5
		cellWidth: width / columns
		cellHeight: settingsData.displayPosters ? cellWidth * 1.5 : cellWidth



		property int lastTriggeredPage: -1
		onContentYChanged: {
			const currentPage = Math.floor(contentY / height)
			if (currentPage > lastTriggeredPage) {
				lastTriggeredPage = currentPage
				console.log(lastTriggeredPage);
			}
		}



		model: modelItem.filteredGameList

		layoutDirection: Qt.LeftToRight
		delegate: gridContent
		//snapMode: GridView.SnapOneRow	// GridView.SnapToRow
		highlightRangeMode: GridView.StrictlyEnforceRange

		property var itemAtRowSelected: undefined
			onItemAtRowSelectedChanged: Qt.callLater(moveView)
		property var itemAtColSelected: undefined
			onItemAtColSelectedChanged: Qt.callLater(moveView)

		property var itemAtRowHovered: undefined
		property var itemAtColHovered: undefined


		function moveView() {
			var index = (gridMenu.itemAtRowSelected * gridMenu.columns) + gridMenu.itemAtColSelected;
			gridMenu.positionViewAtIndex(index, GridView.Contain);
		}

		function resetView() {
			gridMenu.itemAtRowSelected = undefined;
			gridMenu.itemAtColSelected = undefined;
			gridMenu.positionViewAtBeginning();
		}

		function getStoreId() {
			var idx = gridMenu.itemAtRowSelected * gridMenu.columns + gridMenu.itemAtColSelected;
			return gridMenu.itemAtIndex(idx).storeId;
		}

		function getDetail(storeId) {
			view.hasFocus = "mainMenuDetail"
			mainMenu.changeMainMenu("mainMenuDetail");
			mainMenu.children[1].children[0].storeId = storeId;
			mainMenu.setFocus();
		}

		Timer {
			id: waitingTimer
			repeat: true
			running: false
			interval: 250
			triggeredOnStart: true
			onTriggered: {
				if (modelItem.fullGameList.titleListSimpleFinished === true && modelItem.fullGameList.titleListModerateFinished === true && modelItem.fullGameList.titleListComplexFinished === true) {
					waitingTimer.waitingIndex = undefined;
					waitingTimer.stop();

					gridMenu.getDetail(gridMenu.getStoreId());
				}
			}

			property var waitingIndex: undefined
		}

		MouseArea {
			anchors.fill: parent
			enabled: view.hasFocus !== "mainMenuList"		// gridMenu.focus === false
			onClicked: view.hasFocus = "mainMenuList"		// gridMenu.focus = true
		}

		ColumnLayout {
			anchors.left: parent.left
			anchors.right: parent.right
			anchors.verticalCenter: parent.verticalCenter
			spacing: 0
			visible: gridMenu.count === 0

			Image {
				Layout.alignment: Qt.AlignHCenter
				sourceSize.width: parent.width / 5
				fillMode: Image.PreserveAspectFit
				smooth: false
				source: "../../resources/images/xbox_logo.png"
			}

			CustomText {
				Layout.fillWidth: true
				font.bold: true
				pixelSize: modelItem.scale["H1"]
				color: modelItem.theme["Text/Standard"]
				horizontalAlignment: Text.AlignHCenter
				wrapMode: Text.Wrap
				elide: Text.ElideRight; maximumLineCount: 1
				text: "NO RESULTS"
			}
		}

		Keys.priority: Keys.BeforeItem
		Keys.onPressed: (event) => {
							// Avoid repeats if you want single-step D-Pad behavior
							//if (event.isAutoRepeat) { return; }		// in this grid its desirable

							switch (event.key) {
								case Qt.Key_Left:
									//console.log("LEFT");        // D-Pad Left

									if (gridMenu.itemAtColSelected === undefined) {
										gridMenu.itemAtColSelected = 0;
										if (gridMenu.itemAtRowSelected === undefined) { gridMenu.itemAtRowSelected = 0; }
										event.accepted = true;
									}
									else if (gridMenu.itemAtColSelected === 0) {
										//mainMenu.focus = false;
										//leftMenu.focus = true;
										view.hasFocus = "leftMenu";
										event.accepted = true;
									}
									else {
										gridMenu.itemAtColSelected = gridMenu.itemAtColSelected - 1;
										event.accepted = true;
									}
								break;

								case Qt.Key_Right:
									//console.log("RIGHT");       // D-Pad Right

									if (gridMenu.itemAtColSelected === undefined) {
										gridMenu.itemAtColSelected = 0;
										if (gridMenu.itemAtRowSelected === undefined) { gridMenu.itemAtRowSelected = 0; }
										event.accepted = true;
									}
									else if ((gridMenu.itemAtRowSelected * gridMenu.columns + gridMenu.itemAtColSelected + 1) === gridMenu.count) {
										// do nothing, we are at bottom line final item
										event.accepted = false;
									}
									else if (gridMenu.itemAtColSelected === gridMenu.columns-1) {
										if (gridMenu.itemAtRowSelected < Math.floor((gridMenu.count-1) / gridMenu.columns)) {
											// we have more lines, lets go to next line first column
											gridMenu.itemAtRowSelected = gridMenu.itemAtRowSelected + 1;
											gridMenu.itemAtColSelected = 0;
										}
										else {
											// do nothing, we are already at very right
											event.accepted = false;
										}
									}
									else {
										gridMenu.itemAtColSelected = gridMenu.itemAtColSelected + 1;
										event.accepted = true;
									}
								break;

								case Qt.Key_Up:
									//console.log("UP");          // D-Pad Up

									if (gridMenu.itemAtRowSelected === undefined) {
										gridMenu.itemAtRowSelected = 0;
										if (gridMenu.itemAtColSelected === undefined) { gridMenu.itemAtColSelected = 0; }
										event.accepted = true;
									}
									else if (gridMenu.itemAtRowSelected === 0) {
										//mainMenu.focus = false;
										//topMenu.focus = true;
										view.hasFocus = "topMenu";
										if (gridMenu.itemAtColSelected) {
											if (gridMenu.itemAtColSelected > ((gridMenu.columns - 1) / 2)) { topMenu.hasFocus = "categoryField"; }
											else { topMenu.hasFocus = "searchField"; }
										}
										else { topMenu.hasFocus = "searchField"; }
										event.accepted = true;
									}
									else {
										gridMenu.itemAtRowSelected = gridMenu.itemAtRowSelected - 1;
										event.accepted = true;
									}
								break;

								case Qt.Key_Down:
									//console.log("DOWN");        // D-Pad Down

									if (gridMenu.itemAtRowSelected === undefined) {
										gridMenu.itemAtRowSelected = 0;
										if (gridMenu.itemAtColSelected === undefined) { gridMenu.itemAtColSelected = 0; }
										event.accepted = true;
									}
									else if (gridMenu.itemAtRowSelected === Math.floor((gridMenu.count-1) / gridMenu.columns)) {
										// do nothing, we already at very bottom
										event.accepted = false;
									}
									else if (((gridMenu.itemAtRowSelected + 1) * gridMenu.columns + gridMenu.itemAtColSelected) >= gridMenu.count) {
										// do nothing, bellow is no item
										event.accepted = false;
									}
									else {
										gridMenu.itemAtRowSelected = gridMenu.itemAtRowSelected + 1;
										event.accepted = true;
									}
								break;

								// Confirm/OK (Android DPAD_CENTER maps to Qt.Key_Select)
								case Qt.Key_Select:
								case Qt.Key_Return:
								case Qt.Key_Enter:
									console.log("CONFIRM / OK");

									if (gridMenu.itemAtRowSelected !== undefined && gridMenu.itemAtColSelected !== undefined) {
										gridMenu.getDetail(gridMenu.getStoreId());
										event.accepted = true;
									}
									else {
										// do nothing, no item is selected
										event.accepted = false;
									}
								break;

								// Android Back (remote back button & phone back key)
								case Qt.Key_Back:
								case Qt.Key_Escape:
									console.log("BACK");
									// e.g., close a dialog, navigate back in your stack, etc.
									// If you do NOT accept, Android will close the Activity.
									event.accepted = true;
								break;

								default:
									// let others handle it
								break;
							}
						}


		Component {
			id: gridContent

			Item {
				id: objItem
				property real downsizeRatio: 0.96
				width: gridMenu.cellWidth * downsizeRatio
				height: gridMenu.cellHeight * downsizeRatio

				property bool isSelected: (gridMenu.itemAtRowSelected === itemRow & gridMenu.itemAtColSelected === itemCol)
				property bool isHovered: (gridMenu.itemAtRowHovered === itemRow & gridMenu.itemAtColHovered === itemCol)

				property int itemRow: Math.floor(index / gridMenu.columns)
				property int itemCol: index - itemRow * gridMenu.columns

				property int modelIndex: index

				property string storeId: model.storeId || ""

				// Cover Image
				Image {
					id: coverImage
					anchors.top: parent.top;			anchors.topMargin: gridMenu.spacing/2
					anchors.left: parent.left;			anchors.leftMargin: gridMenu.spacing/2
					anchors.right: parent.right;		anchors.rightMargin: gridMenu.spacing/2
					anchors.bottom: parent.bottom;		anchors.bottomMargin: gridMenu.spacing/2
					asynchronous: true
					fillMode: Image.PreserveAspectCrop
					smooth: false
					retainWhileLoading: true
					sourceSize: Qt.size(gridMenu.cellWidth, gridMenu.cellHeight)
					source: if (settingsData.displayPosters) {
								if (model.image_Poster) { return model.image_Poster + "?w="+parseInt(gridMenu.cellWidth); }
								else { return "../../resources/images/game_dummy.jpg"; }
							}
							else {
								if (model.image_Tile) { return model.image_Tile + "?w="+parseInt(gridMenu.cellWidth); }
								else { return "../../resources/images/game_dummy.jpg"; }
							}
					property real radius: width / 20

					layer.enabled: true; layer.effect: RoundedObject {
						radius: coverImage.radius
						forceRadius: true
						color: if (objItem.isHovered || objItem.isSelected) { return "white"; }
							   else if (model.userPrograms && model.userPrograms.length > 0) { return "#D4AF37"; }
							   else { return "transparent"; }
						showŚelected: (model.userPrograms && model.userPrograms.length > 0) || objItem.isHovered || objItem.isSelected
					}

					// TITLE
					Item {
						anchors.top: parent.top
						anchors.left: parent.left
						anchors.right: parent.right
						height: gameTitle.height * 1.5
						visible: if (objItem.isHovered || objItem.isSelected) {
									 if (model.productTitle) { return true; }
									 else { return false; }
								 }
								 else { return false; }

						Rectangle {
							anchors.fill: parent
							color: "black"
							opacity: 0.8
						}
						CustomText {
							id: gameTitle
							//anchors.bottom: parent.bottom
							anchors.verticalCenter: parent.verticalCenter
							anchors.left: parent.left
							anchors.right: parent.right
							font.bold: false
							pixelSize: modelItem.scale["C1"]
							color: modelItem.theme["Text/Standard"]
							horizontalAlignment: Text.AlignHCenter
							wrapMode: Text.Wrap
							elide: Text.ElideRight; maximumLineCount: 2
							text: model.productTitle || ""
						}
					}

					// DISCOUNT // FREE // PRICE
					Item {
						anchors.left: parent.left
						anchors.bottom: parent.bottom
						width: height * 2
						height: parent.width / 6
						visible: if (model.userPrograms && model.userPrograms.length > 0) { return false; }
								 else if (model.discount > 0) { return true; }
								 else if (model.isFree === true) { return true; }
								 else if (model.regularPrice > 0) { return true; }
								 else { return false; }

						Rectangle {
							anchors.fill: parent
							color: "black"
							opacity: 0.8
							topRightRadius: coverImage.radius / 2
						}
						CustomText {
							anchors.centerIn: parent
							color: "lime"
							font.bold: false
							text: if (model.isFree === true) { return "FREE"; }
								  else if (model.discount > 0) {
									  if (objItem.isHovered || objItem.isSelected) {
										  let locale = Qt.locale(settingsData.preferredLanguage.replace("-","_"));
										  //let full = Number((model.regularPrice - model.salePrice).toFixed(0)).toLocaleCurrencyString(locale);
										  let full = Number((model.salePrice).toFixed(0)).toLocaleCurrencyString(locale);
										  return full.replace(/[.,]\d+/, "");		// Remove any decimal part, regardless of locale (, . etc.)
									  }
									  else { return "↓ " + Math.round(model.discount * 100) + "%"; }
								  }
								  else if (model.regularPrice > 0) {
									  let locale = Qt.locale(settingsData.preferredLanguage.replace("-","_"));
									  let full = Number((model.regularPrice).toFixed(0)).toLocaleCurrencyString(locale);
									  return full.replace(/[.,]\d+/, "");		// Remove any decimal part, regardless of locale (, . etc.)
								  }
								  else { return ""; }
						}
					}

					// INPUTS
					Item {
						anchors.right: parent.right
						anchors.bottom: parent.bottom
						height: parent.width / 6
						width: [model.hasMouseAndKeyboard, model.hasController].filter(Boolean).length * singleItemWidth
						property real singleItemWidth: height * 1.3

						Rectangle {
							anchors.fill: parent
							color: "black"
							opacity: 0.8
							topLeftRadius: coverImage.radius / 2
						}
						Item {
							anchors.top: parent.top
							anchors.left: parent.left
							anchors.bottom: parent.bottom
							width: parent.singleItemWidth
							visible: model.hasController ? true : false

							ColorImage {
								anchors.centerIn: parent
								height: parent.height * 0.7
								sourceSize.height: height
								fillMode: Image.PreserveAspectFit
								source: "../../resources/images/icon_game_controller.svg"
							}
						}
						Item {
							anchors.top: parent.top
							anchors.right: parent.right
							anchors.bottom: parent.bottom
							width: parent.singleItemWidth
							visible: model.hasMouseAndKeyboard ? true : false

							ColorImage {
								anchors.centerIn: parent
								height: parent.height * 0.7
								sourceSize.height: height
								fillMode: Image.PreserveAspectFit
								source: "../../resources/images/icon_game_mkb.svg"
							}
						}
					}

					// RATING
					Item {
						anchors.right: parent.right
						anchors.bottom: parent.bottom;		anchors.bottomMargin: parent.width / 6 * 1.5
						width: parent.width / 6
						height: padding + ratingText.height + spacing + ratingImage.height + padding
						visible: model.reviewScore > 0 ? true : false

						property real padding: width / 10
						property real spacing: 0

						Rectangle {
							anchors.fill: parent
							color: "black"
							opacity: 0.8
							topLeftRadius: coverImage.radius / 2
							bottomLeftRadius: coverImage.radius / 2
						}
						CustomText {
							id: ratingText
							anchors.top: parent.top;		anchors.topMargin: parent.padding
							anchors.horizontalCenter: parent.horizontalCenter
							//height: parent.height / 2
							horizontalAlignment: Text.AlignHCenter
							verticalAlignment: Text.AlignBottom
							color: "white"
							font.bold: false
							text: model.reviewScore || ""
						}
						ColorImage {
							id: ratingImage
							anchors.bottom: parent.bottom;	anchors.bottomMargin: parent.padding
							anchors.horizontalCenter: parent.horizontalCenter
							width: parent.width
							height: width
							sourceSize.height: height
							fillMode: Image.PreserveAspectFit
							source: "../../resources/images/emoji_star2.svg"
							transform: Scale { origin.x: ratingImage.width/2; origin.y: ratingImage.height/2; xScale: 0.6; yScale: 0.6 }
							color: if (model.reviewScore) {
									   if (model.reviewScore === 0) { return "#8B0000"; }
									   else if (model.reviewScore === 1) { return "#FF4500"; }
									   else if (model.reviewScore === 2) { return "#FF8C00"; }
									   else if (model.reviewScore === 3) { return "#FFD700"; }
									   else if (model.reviewScore === 4) { return "#A4FF00"; }
									   else if (model.reviewScore === 5) { return "#00FF66"; }
									   else { return "black"; }
								   }
								   else { return "black"; }
						}
					}

					// GAME PASS
					Item {
						anchors.left: parent.left
						anchors.bottom: parent.bottom;		anchors.bottomMargin: parent.width / 6 * 1.5
						width: parent.width / 8
						height: padding + xpassText.width + padding
						visible: true	// TODO

						property real padding: width / 2

						Rectangle {
							anchors.fill: parent
							color: "black"
							opacity: 0.8
							topRightRadius: coverImage.radius / 2
							bottomRightRadius: coverImage.radius / 2
						}
						CustomText {
							id: xpassText
							anchors.centerIn: parent
							horizontalAlignment: Text.AlignHCenter
							verticalAlignment: Text.AlignVCenter
							pixelSize: modelItem.scale["C1"]
							color: "white"
							font.bold: false
							text: settingsData.displayPosters ? "GAME PASS" : "XPASS"

							transform: Rotation { origin.x: xpassText.width/2; origin.y: xpassText.height/2; angle: -90 }
						}
					}


					Item {
						id: loading
						anchors.fill: parent
						visible: waitingTimer.running === true && waitingTimer.waitingIndex === index

						Rectangle {
							anchors.fill: parent
							color: "black"
							opacity: 0.8
							radius: coverImage.radius
						}

						Image {
							id: loadingWheel
							anchors.centerIn: parent
							width: parent.width * 0.5
							sourceSize.width: width
							fillMode: Image.PreserveAspectFit
							smooth: false
							source: "../../resources/images/spinningWheel.png"
						}
						RotationAnimator {
							target: loadingWheel
							running: loading.visible
							from: 0
							to: 360
							loops: Animation.Infinite
							duration: 2000
						}
					}
				}


				MouseArea {
					anchors.fill: parent
					//enabled: gridMenu.focus === true
					hoverEnabled: true
					onEntered: {
						gridMenu.itemAtRowHovered = objItem.itemRow;
						gridMenu.itemAtColHovered = objItem.itemCol;
					}
					onExited: if (gridMenu.itemAtRowHovered === objItem.itemRow && gridMenu.itemAtColHovered === objItem.itemCol) {
								  gridMenu.itemAtColHovered = undefined;
								  gridMenu.itemAtRowHovered = undefined;
							  }
					onClicked: {
						gridMenu.itemAtRowSelected = objItem.itemRow;
						gridMenu.itemAtColSelected = objItem.itemCol;

						waitingTimer.waitingIndex = index;
						waitingTimer.restart();
					}
				}
			}
		}
	}
}