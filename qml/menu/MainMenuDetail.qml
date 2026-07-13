import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../qml/components"

Item {
	id: masterItem
	onFocusChanged: if (focus) { titleMenu.focus = true; }


	Flickable {
		id: titleMenu
		anchors.fill: parent
			anchors.topMargin: modelItem.scale["PADDING"]
			anchors.leftMargin: leftMenu.focusInactiveWidth + modelItem.scale["PADDING"]
			anchors.rightMargin: modelItem.scale["PADDING"]
			anchors.bottomMargin: modelItem.scale["PADDING"]
		contentHeight: flickContent.height

		property string storeId: ""
			onStoreIdChanged: { console.log("StoreId:", storeId, "in DETAIL_VIEW"); titleMenu.resetView(); }
		property int modelIndex: if (storeId) { return modelItem.fullGameList.getIndex(storeId); }
								 else { return -1; }
			//onModelIndexChanged: console.log("modelIndex:", modelIndex)
		property var modelData: if (storeId) { return modelItem.fullGameList.getData(storeId); }
								else { return undefined; }
			//onModelDataChanged: console.log(JSON.stringify(modelData))

		property bool gamePlayable: modelData ? ((modelData.userPrograms && modelData.userPrograms.length > 0) || false) : false

		interactive: titleMenu.focus
		boundsBehavior: Flickable.StopAtBounds
		flickableDirection: Flickable.VerticalFlick

		property real spacing: modelItem.scale["PADDING"]
		property real margin: modelItem.scale["PADDING"]

		property string itemSelected: ""
			onItemSelectedChanged: Qt.callLater(moveView)
		property string itemHovered: ""

		function moveView() {
			if (itemSelected === "playButton") { titleMenu.flickTo(Qt.point(0, 0)); }

			else if (itemSelected.startsWith("galeryView_")) {
				titleMenu.flickToChild(galeryLabel, Flickable.AlignTop);
				var galeryIndex = Number(itemSelected.split("_")[1]);
				galeryView.positionViewAtIndex(galeryIndex, ListView.Contain);
			}

			else if (itemSelected.startsWith("trailerView_")) {
				titleMenu.flickToChild(trailerLabel, Flickable.AlignTop);
				var trailerIndex = Number(itemSelected.split("_")[1]);
				trailerView.positionViewAtIndex(trailerIndex, ListView.Contain);
			}
		}

		function resetView() {
			titleMenu.itemHovered = "";
			titleMenu.itemSelected = "";
			titleMenu.flickTo(Qt.point(0, 0));
		}

		function openLink() {
			Qt.openUrlExternally("https://www.xbox.com/cs-CZ/play/games/" + titleMenu.storeId);		// old
			//Qt.openUrlExternally("https://play.xbox.com/products/" + titleMenu.storeId);				// new
		}

		function startGame() {
			streamAPI.startSession(modelData.xcloudTitleId);
		}


		function setPreviewScreenshot(idx) {
			imgRect.source = "";
			imgRect.coverImage = ("https:" + titleMenu.modelData.screenshots[idx]["URL"] + "?h="+parseInt(imgRect.height)) || "";

			if (idx === 0) { imgRect.arrowLeftVisible = false; }
			else { imgRect.arrowLeftVisible = true; }

			if (idx+1 < galeryView.count) { imgRect.arrowRightVisible = true; }
			else { imgRect.arrowRightVisible = false; }

		}
		function setPreviewTrailer(idx) {
			imgRect.source = (titleMenu.modelData.trailers[idx]["FormatURL"]["Hls"] + "?h="+parseInt(imgRect.height)) || "";
			imgRect.coverImage = (titleMenu.modelData.trailers[idx]["PreviewImageURL"] + "?h="+parseInt(imgRect.height)) || "";

			if (idx === 0) { imgRect.arrowLeftVisible = false; }
			else { imgRect.arrowLeftVisible = true; }

			if (idx+1 < trailerView.count) { imgRect.arrowRightVisible = true; }
			else { imgRect.arrowRightVisible = false; }
		}
		function clearPreview() {
			imgRect.source = "";
			imgRect.coverImage = "";
			imgRect.arrowLeftVisible = false;
			imgRect.arrowRightVisible = false;
		}

		MouseArea {
			anchors.fill: parent
			enabled: view.hasFocus !== "mainMenuDetail"
			onClicked: view.hasFocus = "mainMenuDetail"
		}

		Keys.priority: Keys.BeforeItem
		Keys.onPressed: (event) => {
							// Avoid repeats if you want single-step D-Pad behavior
							//if (event.isAutoRepeat) { return; }		// in this grid its desirable

							switch (event.key) {
								case Qt.Key_Left:
									//console.log("LEFT");        // D-Pad Left

									if (titleMenu.itemSelected === "") {
										titleMenu.itemSelected = "playButton";
										event.accepted = true;
									}
									else {
										if (titleMenu.itemSelected === "playButton") {
											view.hasFocus = "leftMenu";
											event.accepted = true;
										}
										else if (titleMenu.itemSelected.startsWith("galeryView_")) {
											var galerySplit = titleMenu.itemSelected.split("_");
											if (galerySplit[1] === "00") {
												if (imgRect.visible) {
													event.accepted = false;
												}
												else {
													view.hasFocus = "leftMenu";
													event.accepted = true;
												}
											}
											else {
												titleMenu.itemSelected = "galeryView_" + String(Number(galerySplit[1]) - 1).padStart(2, "0");
												if (imgRect.visible) { titleMenu.setPreviewScreenshot(Number(galerySplit[1]) - 1); }
												event.accepted = true;
											}
										}
										else if (titleMenu.itemSelected.startsWith("trailerView_")) {
											var trailerSplit = titleMenu.itemSelected.split("_");
											if (trailerSplit[1] === "00") {
												if (imgRect.visible) {
													event.accepted = false;
												}
												else {
													view.hasFocus = "leftMenu";
													event.accepted = true;
												}
											}
											else {
												titleMenu.itemSelected = "trailerView_" + String(Number(trailerSplit[1]) - 1).padStart(2, "0");
												if (imgRect.visible) { titleMenu.setPreviewTrailer(Number(trailerSplit[1]) - 1); }
												event.accepted = true;
											}
										}
									}
								break;

								case Qt.Key_Right:
									//console.log("RIGHT");       // D-Pad Right

									if (titleMenu.itemSelected === "") {
										titleMenu.itemSelected = "playButton";
										event.accepted = true;
									}
									else {
										if (titleMenu.itemSelected === "playButton") {
											// do nothing
											event.accepted = false;
										}
										else if (titleMenu.itemSelected.startsWith("galeryView_")) {
											var galerySplit = titleMenu.itemSelected.split("_");
											if (Number(galerySplit[1])+1 === galeryView.count) {
												// do nothing, we already at the last Galery
												event.accepted = false;
											}
											else {
												titleMenu.itemSelected = "galeryView_" + String(Number(galerySplit[1]) + 1).padStart(2, "0");
												if (imgRect.visible) { titleMenu.setPreviewScreenshot(Number(galerySplit[1]) + 1); }
												event.accepted = true;
											}
										}
										else if (titleMenu.itemSelected.startsWith("trailerView_")) {
											var trailerSplit = titleMenu.itemSelected.split("_");
											if (Number(trailerSplit[1])+1 === trailerView.count) {
												// do nothing, we already at the last Trailer
												event.accepted = false;
											}
											else {
												titleMenu.itemSelected = "trailerView_" + String(Number(trailerSplit[1]) + 1).padStart(2, "0");
												if (imgRect.visible) { titleMenu.setPreviewTrailer(Number(trailerSplit[1]) + 1); }
												event.accepted = true;
											}
										}
									}
								break;

								case Qt.Key_Up:
									//console.log("UP");          // D-Pad Up

									if (titleMenu.itemSelected === "") {
										titleMenu.itemSelected = "playButton";
										event.accepted = true;
									}
									else {
										if (titleMenu.itemSelected === "playButton") {
											// do nothing, we already at the very top
											event.accepted = false;
										}
										else if (titleMenu.itemSelected.startsWith("galeryView_")) {
											if (imgRect.visible) {
												event.accepted = false;
											}
											else {
												titleMenu.itemSelected = "playButton";
												event.accepted = true;
											}
										}
										else if (titleMenu.itemSelected.startsWith("trailerView_")) {
											if (imgRect.visible) {
												event.accepted = false;
											}
											else {
												titleMenu.itemSelected = "galeryView_00";
												event.accepted = true;
											}
										}
									}
								break;

								case Qt.Key_Down:
									//console.log("DOWN");        // D-Pad Down

									if (titleMenu.itemSelected === "") {
										titleMenu.itemSelected = "playButton";
										event.accepted = true;
									}
									else {
										if (titleMenu.itemSelected === "playButton") {
											titleMenu.itemSelected = "galeryView_00";
											event.accepted = true;
										}
										else if (titleMenu.itemSelected.startsWith("galeryView_")) {
											if (imgRect.visible) {
												event.accepted = false;
											}
											else {
												titleMenu.itemSelected = "trailerView_00";
												event.accepted = true;
											}
										}
										else if (titleMenu.itemSelected.startsWith("trailerView_")) {
											// do nothing, we already at the very bottom
											event.accepted = false;
										}
									}
								break;

								// Confirm/OK (Android DPAD_CENTER maps to Qt.Key_Select)
								case Qt.Key_Select:
								case Qt.Key_Return:
								case Qt.Key_Enter:
									//console.log("CONFIRM / OK");

									if (imgRect.source !== "" || imgRect.coverImage !== "") {
										event.accepted = false;
									}
									else {
										if (titleMenu.itemSelected === "playButton") {
											titleMenu.startGame();
										}
										else if (titleMenu.itemSelected.startsWith("galeryView_")) {
											var galerySplit = titleMenu.itemSelected.split("_");
											titleMenu.setPreviewScreenshot(Number(galerySplit[1]));
										}
										else if (titleMenu.itemSelected.startsWith("trailerView_")) {
											var trailerSplit = titleMenu.itemSelected.split("_");
											titleMenu.setPreviewTrailer(Number(trailerSplit[1]));
										}
									}

								break;

								// Android Back (remote back button & phone back key)
								case Qt.Key_Back:
								case Qt.Key_Escape:
									//console.log("BACK");

									if (imgRect.source !== "" || imgRect.coverImage !== "") {
										titleMenu.clearPreview();
										event.accepted = true;
									}
									else {
										view.hasFocus = "mainMenuList";
										mainMenu.changeMainMenu("mainMenuList");
										event.accepted = true;
									}
								break;

								default:
									// let others handle it
								break;
							}
						}


		Item {
			id: flickContent
			anchors.top: parent.top;		anchors.topMargin: titleMenu.spacing
			anchors.left: parent.left;		anchors.leftMargin: titleMenu.spacing
			anchors.right: parent.right;	anchors.rightMargin: titleMenu.spacing
			height: col1top.height + colBottom.anchors.topMargin + colBottom.height + (titleMenu.spacing*2)

			ColumnLayout {
				id: col1top
				anchors.top: parent.top
				anchors.left: parent.left
				width: parent.width / 3
				spacing: 0


				RowLayout {
					Layout.preferredHeight: modelItem.scale["P1"] * 3
					spacing: modelItem.scale["PADDING"] * 2

					// BUTTON TO START GAME
					Rectangle {
						id: playButton
						Layout.preferredWidth: playButtonText.width * 1.25
						//Layout.preferredHeight: playButtonText.height * 2
						Layout.fillHeight: true
						color: titleMenu.gamePlayable ? "#008746" : "#3E434B"
						border.width: 2
						border.color: titleMenu.gamePlayable ? "#373535" : "#6B7584"
						radius: height / 8

						Rectangle {
							anchors.centerIn: parent
							width: parent.width + modelItem.scale["PADDING"]
							height: parent.height + modelItem.scale["PADDING"]
							radius: height / 8
							color: "transparent"
							border.color: "white"
							border.width: modelItem.scale["LINE"]
							visible: titleMenu.itemSelected === "playButton" || titleMenu.itemHovered === "playButton"
						}

						CustomText {
							id: playButtonText
							anchors.centerIn: parent
							pixelSize: modelItem.scale["P1"]
							font.bold: titleMenu.gamePlayable ? true : false
							color: "white"
							text: titleMenu.gamePlayable ? "Start the game" : "Game not available"
						}

						MouseArea {
							anchors.fill: parent
							hoverEnabled: true
							onEntered: titleMenu.itemHovered = "playButton"
							onExited: if (titleMenu.itemHovered === "playButton") { titleMenu.itemHovered = ""; }
							onClicked: {
								titleMenu.itemSelected = "playButton"

								if (titleMenu.gamePlayable) { titleMenu.startGame(); }
								else { titleMenu.openLink(); }
							}
						}
					}

					// REGULAR Price
					CustomText {
						id: regularPriceLabel
						//Layout.fillWidth: true
						pixelSize: modelItem.scale["H2"]
						font.bold: false
						color: salePriceLabel.text !== "" ? "#FF0000" : "#44BB00"
						font.strikeout: salePriceLabel.text !== "" ? true : false
						text: if (titleMenu.modelData) {
								  if (titleMenu.modelData.regularPrice) {
									  let locale = Qt.locale(settingsData.preferredLanguage.replace("-","_"));
									  let full = Number((titleMenu.modelData.regularPrice).toFixed(0)).toLocaleCurrencyString(locale);
									  return full.replace(/[.,]\d+/, "");		// Remove any decimal part, regardless of locale (, . etc.)
								  }
								  else { return ""; }
							  }
							  else { return ""; }
					}

					// SALE Price
					CustomText {
						id: salePriceLabel
						//Layout.fillWidth: true
						pixelSize: modelItem.scale["H2"]
						font.bold: false
						color: "#44BB00"
						text: if (titleMenu.modelData) {
								  if (titleMenu.modelData.salePrice) {
									  let locale = Qt.locale(settingsData.preferredLanguage.replace("-","_"));
									  let full = Number((titleMenu.modelData.salePrice).toFixed(0)).toLocaleCurrencyString(locale);
									  return full.replace(/[.,]\d+/, "");		// Remove any decimal part, regardless of locale (, . etc.)
								  }
								  else { return ""; }
							  }
							  else { return ""; }
					}
				}

				// Extra Space
				Item { Layout.fillWidth: true; Layout.preferredHeight: titleMenu.spacing*2 }

				CustomText {
					Layout.fillWidth: true
					pixelSize: modelItem.scale["H2"]
					font.bold: true
					color: "white"
					wrapMode: Text.Wrap
					text: titleMenu.modelData ? (titleMenu.modelData.productTitle || "") : ""
				}

				// Extra Space
				Item { Layout.fillWidth: true; Layout.preferredHeight: titleMenu.spacing }

				CustomText {
					Layout.fillWidth: true
					pixelSize: modelItem.scale["P1"]
					font.bold: false
					color: "white"
					wrapMode: Text.Wrap
					text: "Developed by: " + (titleMenu.modelData ? (titleMenu.modelData.developerName || "") : "")
				}
				CustomText {
					Layout.fillWidth: true
					pixelSize: modelItem.scale["P1"]
					font.bold: false
					color: "white"
					wrapMode: Text.Wrap
					text: "Published by: " + (titleMenu.modelData ? (titleMenu.modelData.publisherName || "") : "")
				}

				// Extra Space
				Item { Layout.fillWidth: true; Layout.preferredHeight: titleMenu.spacing }

				CustomText {
					Layout.fillWidth: true
					pixelSize: modelItem.scale["P1"]
					font.bold: false
					color: "white"
					wrapMode: Text.Wrap
					text: titleMenu.modelData ? (titleMenu.modelData.localizedCategories.join(" - ") || "") : ""
				}

				// Extra Space
				Item { Layout.fillWidth: true; Layout.preferredHeight: titleMenu.spacing }

				Row {
					spacing: titleMenu.spacing

					CustomText {
						pixelSize: modelItem.scale["P1"]
						font.bold: true
						color: "white"
						text: "Play with:"
					}
					ColorImage {
						anchors.verticalCenter: parent.verticalCenter
						height: 20
						sourceSize.height: height
						fillMode: Image.PreserveAspectFit
						source: "../../resources/images/icon_game_controller.svg"
						visible: titleMenu.modelData ? (titleMenu.modelData.hasController || false) : false
					}
					ColorImage {
						anchors.verticalCenter: parent.verticalCenter
						height: 20
						sourceSize.height: height
						fillMode: Image.PreserveAspectFit
						source: "../../resources/images/icon_game_mkb.svg"
						visible: titleMenu.modelData ? (titleMenu.modelData.hasMouseAndKeyboard || false) : false
					}
				}

				// Extra Space
				Item { Layout.fillWidth: true; Layout.preferredHeight: titleMenu.spacing*2 }

				RowLayout {
					id: ratingRow
					spacing: titleMenu.spacing

					ColorImage {
						id: ratingImage
						Layout.alignment: Qt.AlignTop
						Layout.preferredWidth: 50
						sourceSize.width: width
						fillMode: Image.PreserveAspectFit
						source: titleMenu.modelData ? (titleMenu.modelData.contentRating.LogoUrl || "") : ""
					}
					ColumnLayout {
						Layout.fillWidth: true
						spacing: titleMenu.spacing / 2

						CustomText {
							Layout.fillWidth: true
							pixelSize: modelItem.scale["C1"]
							font.bold: false
							color: "white"
							wrapMode: Text.Wrap
							text: titleMenu.modelData ? (titleMenu.modelData.contentRating.Description || "") : ""
						}
						CustomText {
							Layout.fillWidth: true
							pixelSize: modelItem.scale["C1"]
							font.bold: false
							color: "white"
							wrapMode: Text.Wrap
							text: titleMenu.modelData ? (titleMenu.modelData.contentRating.LocalizedInteractiveElements.join(" - ") || "") : ""
						}
						CustomText {
							Layout.fillWidth: true
							pixelSize: modelItem.scale["C1"]
							font.bold: false
							color: "white"
							wrapMode: Text.Wrap
							text: titleMenu.modelData ? (titleMenu.modelData.contentRating.LocalizedDescriptors.join(" - ") || "") : ""
						}
					}
				}
			}

			CustomText {
				id: col2top
				anchors.top: parent.top
				anchors.left: col1top.right;		 anchors.leftMargin: titleMenu.spacing * 2
				anchors.right: parent.right
				height: col1top.height
				verticalAlignment: Text.AlignTop
				elide: Text.ElideRight
				pixelSize: modelItem.scale["C1"]
				font.bold: false
				color: "white"
				text: titleMenu.modelData ? (titleMenu.modelData.productDescription || "") : ""
				wrapMode: Text.Wrap
			}


			ColumnLayout {
				id: colBottom
				anchors.top: col1top.bottom;	anchors.topMargin: titleMenu.spacing * 2
				anchors.left: parent.left;		anchors.leftMargin: titleMenu.spacing
				anchors.right: parent.right;	anchors.rightMargin: titleMenu.spacing
				spacing: titleMenu.spacing

				CustomText {
					id: galeryLabel
					Layout.fillWidth: true
					pixelSize: modelItem.scale["P1"]
					font.bold: true
					color: "white"
					text: "Galery:"
				}

				ListView {
					id: galeryView
					Layout.fillWidth: true
					Layout.preferredHeight: root.width * 0.1
					highlightRangeMode: ListView.StrictlyEnforceRange

					spacing: titleMenu.spacing / 2
					cacheBuffer: masterItem.width

					boundsBehavior: Flickable.StopAtBounds
					flickableDirection: Flickable.HorizontalFlick

					model: titleMenu.modelData ? (titleMenu.modelData.screenshots || undefined): undefined

					orientation: ListView.Horizontal
					layoutDirection: Qt.LeftToRight
					snapMode: ListView.SnapOneItem
					clip: false

					visible: count > 0

					delegate: Component {
						Item {
							id: galeryItem
							width: galery.width
							height: galeryView.height

							property bool isSelected: titleMenu.itemSelected === "galeryView_" + String(index).padStart(2, "0")
							property bool isHovered: titleMenu.itemHovered === "galeryView_" + String(index).padStart(2, "0")

							Image {
								id: galery
								height: parent.height
								sourceSize.height: height
								fillMode: Image.PreserveAspectCrop
								smooth: false
								source: ("https:" + titleMenu.modelData.screenshots[index]["URL"] + "?h="+parseInt(galeryView.height)) || ""
							}

							Rectangle {
								anchors.centerIn: parent
								width: parent.width + modelItem.scale["PADDING"]
								height: parent.height + modelItem.scale["PADDING"]
								radius: height / 20
								color: "transparent"
								border.color: "white"
								border.width: modelItem.scale["LINE"]
								visible: galeryItem.isSelected || galeryItem.isHovered
							}

							MouseArea {
								anchors.fill: parent
								hoverEnabled: true
								onEntered: titleMenu.itemHovered = "galeryView_" + String(index).padStart(2, "0");
								onExited: if (titleMenu.itemHovered === "galeryView_" + String(index).padStart(2, "0")) { titleMenu.itemHovered = ""; }
								onClicked: {
									titleMenu.itemSelected = "galeryView_" + String(index).padStart(2, "0");
									titleMenu.setPreviewScreenshot(index);
								}
							}
						}
					}
				}

				// Extra Space
				Item { Layout.fillWidth: true; Layout.preferredHeight: titleMenu.spacing }

				CustomText {
					id: trailerLabel
					Layout.fillWidth: true
					pixelSize: modelItem.scale["P1"]
					font.bold: true
					color: "white"
					text: "Video:"
				}

				ListView {
					id: trailerView
					Layout.fillWidth: true
					Layout.preferredHeight: root.width * 0.1
					highlightRangeMode: ListView.StrictlyEnforceRange

					spacing: titleMenu.spacing / 2
					cacheBuffer: masterItem.width

					boundsBehavior: Flickable.StopAtBounds
					flickableDirection: Flickable.HorizontalFlick

					model: titleMenu.modelData ? (titleMenu.modelData.trailers || undefined): undefined

					orientation: ListView.Horizontal
					layoutDirection: Qt.LeftToRight
					snapMode: ListView.SnapOneItem
					clip: false

					visible: count > 0

					delegate: Component {
						Item {
							id: trailerItem
							width: trailer.width
							height: trailerView.height

							property bool isSelected: titleMenu.itemSelected === "trailerView_" + String(index).padStart(2, "0")
							property bool isHovered: titleMenu.itemHovered === "trailerView_" + String(index).padStart(2, "0")

							Image {
								id: trailer
								height: parent.height
								sourceSize.height: height
								fillMode: Image.PreserveAspectCrop
								smooth: false
								source: (titleMenu.modelData.trailers[index]["PreviewImageURL"] + "?h="+parseInt(trailerView.height)) || ""
								// url to video: titleMenu.modelData.trailers[index]["FormatURL"]["Hls"]
							}

							Image {
								anchors.centerIn: parent
								height: parent.height / 3
								sourceSize.height: height
								fillMode: Image.PreserveAspectFit
								smooth: false
								source: "../../resources/images/video_play.svg"
							}

							Rectangle {
								anchors.centerIn: parent
								width: parent.width + modelItem.scale["PADDING"]
								height: parent.height + modelItem.scale["PADDING"]
								radius: height / 20
								color: "transparent"
								border.color: "white"
								border.width: modelItem.scale["LINE"]
								visible: trailerItem.isSelected || trailerItem.isHovered
							}

							MouseArea {
								anchors.fill: parent
								hoverEnabled: true
								onEntered: titleMenu.itemHovered = "trailerView_" + String(index).padStart(2, "0")
								onExited: if (titleMenu.itemHovered === "trailerView_" + String(index).padStart(2, "0")) { titleMenu.itemHovered = ""; }
								onClicked: {
									titleMenu.itemSelected = "trailerView_" + String(index).padStart(2, "0");
									titleMenu.setPreviewTrailer(index);
								}
							}
						}
					}
				}
			}
		}
	}


	Image {
		anchors.fill: parent
		z: titleMenu.z -1
		fillMode: Image.PreserveAspectCrop
		smooth: false
		source: titleMenu.modelData ? (titleMenu.modelData.image_Hero || ""): ""

		Rectangle {
			anchors.fill: parent
			color: "black"
			opacity: 0.5
		}
	}

}