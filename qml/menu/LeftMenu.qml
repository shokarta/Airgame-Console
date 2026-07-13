import QtQuick
import QtQuick.Layouts
import QtQml.Models
import "../../qml/components"

Rectangle {
	id: objRoot
	anchors.top: parent.top
	anchors.left: parent.left
	anchors.bottom: parent.bottom
	width: objRoot.focus ? focusActiveWidth : focusInactiveWidth
	color: modelItem.theme["Background/Left"]

	property real focusActiveWidth: parent.width * 0.2
	property real focusInactiveWidth: parent.width * 0.075

	property string hasFocus: ""
	property string hasHover: ""

	Behavior on width {	NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

	MouseArea {
		anchors.fill: parent
		enabled: true	// view.hasFocus === "leftMenu"
		onClicked: view.hasFocus = "leftMenu"
	}

	Gradient {
		id: gradBackground
		orientation: Gradient.Horizontal
		GradientStop { position: 0.0; color: modelItem.theme["Background/Gradient/Stop1"] }
		GradientStop { position: 0.8; color: modelItem.theme["Background/Gradient/Stop2"] }
		GradientStop { position: 1.0; color: modelItem.theme["Background/Gradient/Stop3"] }
	}


	Keys.priority: Keys.BeforeItem
	Keys.onPressed: (event) => {
						// Avoid repeats if you want single-step D-Pad behavior
						if (event.isAutoRepeat) { return; }

						switch (event.key) {
							case Qt.Key_Left:
								//console.log("LEFT");        // D-Pad Left

								// do nothing
								event.accepted = false;
							break;

							case Qt.Key_Right:
								//console.log("RIGHT");       // D-Pad Right

								//leftMenu.focus = false;
								//mainMenu.focus = true;
								view.hasFocus = "mainMenu";
								event.accepted = true;
							break;

							case Qt.Key_Up:
								//console.log("UP");          // D-Pad Up

								if (objRoot.hasFocus === "") {
									objRoot.hasFocus = modelItem.menuModel.get(modelItem.menuModel.count-1).code;
									event.accepted = true;
								}
								else {
									if (objRoot.hasFocus === modelItem.menuModel.get(0).code) {
										objRoot.hasFocus = "userAvatar";
										event.accepted = true;
									}
									else if (objRoot.hasFocus === "userAvatar") {
										// do nothing, already on top
										event.accepted = false;
									}
									else if (objRoot.hasFocus === "settingsButton") {
										objRoot.hasFocus = "playableGamesButton";
										event.accepted = true;
									}
									else {
										for (var i=0; i<modelItem.menuModel.count; i++) { if (modelItem.menuModel.get(i).code === objRoot.hasFocus) { break; } }	// get index of current hasFocus code
										objRoot.hasFocus = modelItem.menuModel.get(i-1).code;		// use index what we found -1
										event.accepted = true;
									}
								}
							break;

							case Qt.Key_Down:
								//console.log("DOWN");        // D-Pad Down

								if (objRoot.hasFocus === "") {
									objRoot.hasFocus = "userAvatar";
									event.accepted = true;
								}
								else {
									if (objRoot.hasFocus === "settingsButton") {
										// do nothing, already at bottom
										event.accepted = false;
									}
									else if (objRoot.hasFocus === modelItem.menuModel.get(modelItem.menuModel.count-1).code) {
										// do nothing, already at bottom
										objRoot.hasFocus = "playableGamesButton";
										event.accepted = true;
									}
								else if (objRoot.hasFocus === "playableGamesButton") {
										// do nothing, already at bottom
										objRoot.hasFocus = "settingsButton";
										event.accepted = true;
									}
									else if (objRoot.hasFocus === "userAvatar") {
										objRoot.hasFocus = modelItem.menuModel.get(0).code;
										event.accepted = true;
									}
									else {
										for (var i=0; i<modelItem.menuModel.count; i++) { if (modelItem.menuModel.get(i).code === objRoot.hasFocus) { break; } }	// get index of current hasFocus code
										objRoot.hasFocus = modelItem.menuModel.get(i+1).code;		// use index what we found +1
										event.accepted = true;
									}
								}
							break;

							// Confirm/OK (Android DPAD_CENTER maps to Qt.Key_Select)
							case Qt.Key_Select:
							case Qt.Key_Return:
							case Qt.Key_Enter:
								//console.log("CONFIRM / OK");

								if (objRoot.hasFocus !== "") {
									objRoot.clickEvent(objRoot.hasFocus);
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

	function clickEvent(clickCode) {
		var i, j;

		if (clickCode === "userAvatar") {
			console.log("clickEvent(userAvatar)");
		}

		else if (clickCode === "settingsButton") {
			console.log("clickEvent(settingsButton)");

				var request = new XMLHttpRequest();

				request.open("GET", settingsData.xcloudToken.offeringSettings.regions.find(region => region.isDefault === true).baseUri + "/v2/titles", false);
					request.setRequestHeader('Authorization', 'Bearer ' + settingsData.xcloudToken["gsToken"]);
					request.setRequestHeader('Content-Type', 'application/json');
					if (settingsData.preferredforceIp !== "") { request.setRequestHeader('X-Forwarded-For', settingsData.preferredforceIp); }
				request.responseType = "json";
				request.send();

				// when responce received then do the following script:
				if (request.readyState === XMLHttpRequest.DONE) {
//console.log("finish:", request.responseText);
					var reply;
					try { reply = request.response; }
					catch (exception) { console.log("error occured on request TEST:", exception); return; }

					var testArray = [];
					for (i=0; i<reply["results"].length; i++) {
						if (reply["results"][i]["details"]["userPrograms"].length === 1 && reply["results"][i]["details"]["userPrograms"][0] === "CALLISTO") {}
						else {
							//console.log(reply["results"][i]["details"]["productId"], reply["results"][i]["titleId"], JSON.stringify(reply["results"][i]["details"]["userPrograms"]))
							testArray.push(reply["results"][i]["details"]["productId"]);
						}
					}
					console.log("following games does not have CALLISTO in userPrograms but are included in ULTIMATE list");
					for (i=0; i<modelItem.fullGameList.count; i++) {
						if (testArray.includes(modelItem.fullGameList.get(i).storeId)) {
							console.log(modelItem.fullGameList.get(i).storeId, modelItem.fullGameList.get(i).productTitle)
						}
					}
					console.log("konec");
				}
		}

		else if (clickCode === "userSessionGames") {
			mainMenu.changeMainMenu("mainMenuList");
			modelItem.filteredGameList.code = "userSessionGames";
			modelItem.filteredGameList.sortingField = "lastTimePlayed";
			modelItem.filteredGameList.orderType = Qt.DescendingOrder;
			modelItem.categoryList.reset();
			topMenu.queryString.clear();
			mainMenu.children[0].children[0].resetView();
			modelItem.filteredGameList.refreshAsync();
		}
		else if (clickCode === "allGames") {
			mainMenu.changeMainMenu("mainMenuList");
			modelItem.filteredGameList.code = "allGames";
			modelItem.filteredGameList.sortingField = "productTitle";
			modelItem.filteredGameList.orderType = Qt.AscendingOrder;
			modelItem.categoryList.reset();
			topMenu.queryString.clear();
			mainMenu.children[0].children[0].resetView();
			modelItem.filteredGameList.refreshAsync();
		}
		else if (clickCode === "favoriteGames") {
			mainMenu.changeMainMenu("mainMenuList");
			modelItem.filteredGameList.code = "favoriteGames";
			modelItem.filteredGameList.sortingField = "productTitle";
			modelItem.filteredGameList.orderType = Qt.AscendingOrder;
			modelItem.categoryList.reset();
			topMenu.queryString.clear();
			mainMenu.children[0].children[0].resetView();
			modelItem.filteredGameList.refreshAsync();
		}
		else if (clickCode === "newGames") {
			mainMenu.changeMainMenu("mainMenuList");
			modelItem.filteredGameList.code = "newGames";
			modelItem.filteredGameList.sortingField = "productTitle";
			modelItem.filteredGameList.orderType = Qt.AscendingOrder;
			modelItem.categoryList.reset();
			topMenu.queryString.clear();
			mainMenu.children[0].children[0].resetView();
			modelItem.filteredGameList.refreshAsync();
		}
		else if (clickCode === "dealGames") {
			mainMenu.changeMainMenu("mainMenuList");
			modelItem.filteredGameList.code = "dealGames";
			//modelItem.filteredGameList.sortingField = "discount";		// discount / salePrice / regularPrice
			modelItem.filteredGameList.sortingField = "salePrice";
			//modelItem.filteredGameList.orderType = Qt.DescendingOrder;
			modelItem.filteredGameList.orderType = Qt.AscendingOrder;
			modelItem.categoryList.reset();
			topMenu.queryString.clear();
			mainMenu.children[0].children[0].resetView();
			modelItem.filteredGameList.refreshAsync();
		}
		else if (clickCode === "bestRatedGames") {
			mainMenu.changeMainMenu("mainMenuList");
			modelItem.filteredGameList.code = "bestRatedGames";
			modelItem.filteredGameList.sortingField = "reviewScore";
			modelItem.filteredGameList.orderType = Qt.DescendingOrder;
			modelItem.categoryList.reset();
			topMenu.queryString.clear();
			mainMenu.children[0].children[0].resetView();
			modelItem.filteredGameList.refreshAsync();
		}
		else if (clickCode === "comingSoonGames") {
			mainMenu.changeMainMenu("mainMenuList");
			modelItem.filteredGameList.code = "comingSoonGames";
			modelItem.filteredGameList.sortingField = "productTitle";
			modelItem.filteredGameList.orderType = Qt.AscendingOrder;
			modelItem.categoryList.reset();
			topMenu.queryString.clear();
			mainMenu.children[0].children[0].resetView();
			modelItem.filteredGameList.refreshAsync();
		}
		else if (clickCode === "topFreeGames") {
			mainMenu.changeMainMenu("mainMenuList");
			modelItem.filteredGameList.code = "topFreeGames";
			modelItem.filteredGameList.sortingField = "reviewScore";
			modelItem.filteredGameList.orderType = Qt.DescendingOrder;
			modelItem.categoryList.reset();
			topMenu.queryString.clear();
			mainMenu.children[0].children[0].resetView();
			modelItem.filteredGameList.refreshAsync();
		}
		else if (clickCode === "mostPlayedGames") {
			mainMenu.changeMainMenu("mainMenuList");
			modelItem.filteredGameList.code = "mostPlayedGames";
			modelItem.filteredGameList.sortingField = "productTitle";
			modelItem.filteredGameList.orderType = Qt.AscendingOrder;
			modelItem.categoryList.reset();
			topMenu.queryString.clear();
			mainMenu.children[0].children[0].resetView();
			modelItem.filteredGameList.refreshAsync();
		}
		else if (clickCode === "previewGames") {
			mainMenu.changeMainMenu("mainMenuList");
			modelItem.filteredGameList.code = "previewGames";
			modelItem.filteredGameList.sortingField = "productTitle";
			modelItem.filteredGameList.orderType = Qt.AscendingOrder;
			modelItem.categoryList.reset();
			topMenu.queryString.clear();
			mainMenu.children[0].children[0].resetView();
			modelItem.filteredGameList.refreshAsync();
		}
		else if (clickCode === "mouseAndKeyboardGames") {
			mainMenu.changeMainMenu("mainMenuList");
			modelItem.filteredGameList.code = "mouseAndKeyboardGames";
			modelItem.filteredGameList.sortingField = "productTitle";
			modelItem.filteredGameList.orderType = Qt.AscendingOrder;
			modelItem.categoryList.reset();
			topMenu.queryString.clear();
			mainMenu.children[0].children[0].resetView();
			modelItem.filteredGameList.refreshAsync();
		}
		else if (clickCode === "playableGamesButton") {
			settingsData.displayPlayableGames = !settingsData.displayPlayableGames;
			modelItem.filteredGameList.displayPlayableGames = settingsData.displayPlayableGames;
			mainMenu.changeMainMenu("mainMenuList");
			mainMenu.children[0].children[0].resetView();
			modelItem.filteredGameList.refreshAsync();
		}

		else {
			console.log("UNEXPECTED CLICKEVENT CODE:", clickCode);
		}

	}


	ColumnLayout {
		id: masterlayout
		anchors.top: parent.top
		anchors.left: parent.left
		anchors.right: parent.right
		spacing: 0


		Item {
			Layout.fillWidth: true
			Layout.preferredHeight: objRoot.focusActiveWidth / 2

			Image {
				id: userAvatar
				anchors.centerIn: parent
				width: parent.width / 2.5
				height: width
				sourceSize: Qt.size(objRoot.focusActiveWidth / 2, objRoot.focusActiveWidth / 2)
				fillMode: Image.PreserveAspectCrop
				asynchronous: true
				retainWhileLoading: true
				smooth: false
				source: (modelItem.userOwnData.settings || []).find(s => s.id === "PublicGamerpic")?.value || "../../resources/images/icon_avatar.png"
				layer.enabled: true; layer.effect: RoundedObject { radius: userAvatar.width/2; showŚelected: objRoot.hasHover === "userAvatar" || objRoot.hasFocus === "userAvatar" }

				property bool isSelected: objRoot.hasFocus === "userAvatar"

				MouseArea {
					anchors.fill: parent
					enabled: view.hasFocus === "leftMenu"
					hoverEnabled: true
					onEntered: objRoot.hasHover = "userAvatar"
					onExited: if (objRoot.hasHover === "userAvatar") { objRoot.hasHover = ""; }
					onClicked: {
						objRoot.hasFocus = "userAvatar";
						objRoot.clickEvent("userAvatar");
					}
				}
			}
		}


		// Extra Space
		Item { Layout.fillWidth: true; Layout.preferredHeight: modelItem.scale["PADDING"] }


		Repeater {
			model: modelItem.menuModel

			Rectangle {
				id: objRect
				required property int index
				Layout.fillWidth: true
				Layout.preferredHeight: objRoot.height / 20		//objRoot.focusActiveWidth * 0.175
				color: if (mainMenu.currentView === "mainMenuList" && objRoot.hasFocus === modelItem.menuModel.get(index).code) { return "#033518"; }
					   else { return "transparent"; }
				gradient: if (view.hasFocus === "leftMenu" && (objRoot.hasFocus === modelItem.menuModel.get(index).code || objRoot.hasHover === modelItem.menuModel.get(index).code)) { return gradBackground; }
						  else { return undefined; }

				Item {
					id: rowLayout
					anchors.top: parent.top
					anchors.left: parent.left
					anchors.right: parent.right
					anchors.bottom: parent.bottom
					property real spacing: modelItem.scale["PADDING"]

					Image {
						id: buttonIcon
						anchors.left: parent.left;	anchors.leftMargin: if (view.hasFocus === "leftMenu") { return modelItem.scale["MARGIN"]; }
																		else { return objRoot.focusInactiveWidth/2 - width/2; }
						anchors.verticalCenter: parent.verticalCenter
						height: view.hasFocus === "leftMenu" ? parent.height * 0.5 : parent.height * 0.75
						sourceSize.height: height
						fillMode: Image.PreserveAspectFit
						asynchronous: true
						smooth: false
						source: "../../resources/images/" + modelItem.menuModel.get(index).icon

						Behavior on anchors.leftMargin { NumberAnimation { duration: 50 } }
						//Behavior on height { NumberAnimation { duration: 150 } }
					}

					CustomText {
						id: buttonText
						anchors.verticalCenter: parent.verticalCenter
						anchors.left: buttonIcon.right;		anchors.leftMargin: rowLayout.spacing
						anchors.right: parent.right;		anchors.rightMargin: modelItem.scale["PADDING/INNER"]
						color: modelItem.menuModel.get(index).loaded ? modelItem.theme["Text/Standard"] : modelItem.theme["Text/Hint"]
						pixelSize: parent.height / 1.75
						elide: Text.ElideRight; maximumLineCount: 1
						text: modelItem.menuModel.get(index).name
						visible: view.hasFocus === "leftMenu"
					}
				}

				MouseArea {
					anchors.fill: parent
					enabled: view.hasFocus === "leftMenu" && modelItem.menuModel.get(index).loaded
					hoverEnabled: modelItem.menuModel.get(index).loaded
					onEntered: objRoot.hasHover = modelItem.menuModel.get(index).code
					onExited: if (objRoot.hasHover === modelItem.menuModel.get(index).code) { objRoot.hasHover = ""; }
					onClicked: {
						objRoot.hasFocus = modelItem.menuModel.get(index).code;
						objRoot.clickEvent(modelItem.menuModel.get(index).code);
					}
				}
			}
		}


		// Extra Space
		Item { Layout.fillWidth: true; Layout.preferredHeight: modelItem.scale["MARGIN"] }


		ColumnLayout {
			id: playableGames
			Layout.fillWidth: true
			spacing: 0

			property bool enabled: modelItem.fullGameList.titleListSimpleFinished

			CustomText {
				Layout.fillWidth: true
				Layout.preferredHeight: objRoot.height / 20
				horizontalAlignment: Text.AlignHCenter
				pixelSize: view.hasFocus === "leftMenu" ? height / 1.75 : height / 2.25
				color: playableGames.enabled ? modelItem.theme["Text/Standard"] : modelItem.theme["Text/Hint"]
				text: view.hasFocus === "leftMenu" ? "Playable Games" : "Playable"
			}
			Rectangle {
				Layout.preferredWidth: view.hasFocus === "leftMenu" ? objRoot.focusActiveWidth / 3 : objRoot.focusActiveWidth / 4
				Layout.preferredHeight: objRoot.height / 20
				Layout.alignment: Qt.AlignHCenter
				color: modelItem.theme["Background/Form/Inactive"]
				border.width: modelItem.scale["LINE"]
				border.color: objRoot.hasFocus === "playableGamesButton" || objRoot.hasHover === "playableGamesButton" ? modelItem.theme["Outline/Form/Active"] : modelItem.theme["Outline/Form/Inactive"]
				radius: height / 2

				Rectangle {
					anchors.verticalCenter: parent.verticalCenter
						//anchors.topMargin: parent.border.width
					//anchors.left: isEnabled ? undefined : parent.left
						//anchors.leftMargin: isEnabled ? 0 : parent.border.width
					//anchors.right: isEnabled ? parent.right : undefined
						//anchors.rightMargin: isEnabled ? parent.border.width : 0
						//anchors.bottomMargin: parent.border.width
					width: height
					height: objRoot.hasFocus === "playableGamesButton" || objRoot.hasHover === "playableGamesButton" ? parent.height * 1.2 : parent.height

					radius: height / 2
					color: isEnabled ? modelItem.theme["Text/Link"] : modelItem.theme["Text/Hint"]
					border.width: objRoot.hasFocus === "playableGamesButton" || objRoot.hasHover === "playableGamesButton" ? modelItem.scale["LINE"]*2 : modelItem.scale["LINE"]
					border.color: objRoot.hasFocus === "playableGamesButton" || objRoot.hasHover === "playableGamesButton" ? modelItem.theme["Text/Link"] : modelItem.theme["Outline/Form/Active"]

					property bool isEnabled: settingsData.displayPlayableGames
					onIsEnabledChanged: isEnabled ? reanchorToRight() : reanchorToLeft()

					function reanchorToLeft() {
						anchors.right = undefined;
							anchors.rightMargin = 0;
						anchors.left = parent.left;
					}
					function reanchorToRight() {
						anchors.left = undefined;
							anchors.leftMargin = 0;
						anchors.right = parent.right
					}
				}

				MouseArea {
					anchors.fill: parent
					enabled: playableGames.enabled
					hoverEnabled: playableGames.enabled
					onEntered: objRoot.hasHover = "playableGamesButton"
					onExited: objRoot.hasHover = ""
					onClicked: {
						objRoot.hasFocus = "playableGamesButton";
						objRoot.clickEvent("playableGamesButton");
					}
				}
			}
		}
	}


	Rectangle {
		id: settingsButton
		anchors.bottom: parent.bottom
		anchors.left: parent.left
		anchors.right: parent.right
		height: objRoot.focusActiveWidth * 0.175

		color: if (objRoot.hasHover === "settingsButton") { return "#033518"; }
			   else {
				  if (objRoot.hasHover === "" && objRoot.hasFocus === "settingsButton") { return "#033518"; }
				  else { return "transparent"; }
			   }
		gradient: if (view.hasFocus === "leftMenu") {
					  if (objRoot.hasHover === "settingsButton") { return gradBackground; }
					  else {
						  if (objRoot.hasHover === "" && objRoot.hasFocus === "settingsButton") { return gradBackground; }
						  else { return undefined; }
					  }
				  }
				  else { return undefined; }

		property bool isSelected: objRoot.hasFocus === "settingsButton"

		CustomText {
			anchors.centerIn: parent
			elide: Text.ElideRight; maximumLineCount: 1
			pixelSize: objRoot.focusActiveWidth / 12.5
			color: settingsData.user_mode === 1 ? "white" : "black"
			text: view.hasFocus === "leftMenu" ? "AirGame Console" : "AGC"
		}

		MouseArea {
			anchors.fill: parent
			enabled: view.hasFocus === "leftMenu"
			hoverEnabled: true
			onEntered: objRoot.hasHover = "settingsButton"
			onExited: if (objRoot.hasHover === "settingsButton") { objRoot.hasHover = ""; }
			onClicked: {
				objRoot.hasFocus = "settingsButton";
				objRoot.clickEvent("settingsButton");
			}
		}
	}


	// Line
	Rectangle {
		anchors.top: parent.top
		anchors.right: parent.right
		anchors.bottom: parent.bottom
		width: modelItem.scale["LINE"]
		color: modelItem.theme["Outline/Main"]
	}
}
