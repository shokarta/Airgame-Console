pragma Singleton
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtCore
import QtWebView
import "qml/components"
import "qml/menu"
import "qml/popups"
//import WebRtcClient


Window {
	id: root
	width: 1000
	height: 640
	visible: true
	title: "AirGame Console"
	color: "black"


	// WebRtcClient {
	// 	id: webrtc

	//	Component.onCompleted: {
			//webrtc.initialize();
	//}


	// 	onOfferCreated: function (sdp) {
	// 		//console.log("offer:", sdp);
	// 		//webrtc.setRemoteOffer(sdp);		// happens automaticaly form c++ when offer is generated
	// 		streamAPI.sendSdpOffer(sdp);
	// 	}

	// 	onLocalIceCandidatesFinished: {
	// 		//console.log("candidates:");
	// 		//console.log(JSON.stringify(localIceCandidates));
	// 	}
	//}

	Settings {
		id: settingsData

		property bool debugMode: false
		property string client_id: "0c10aad4-3a8f-4257-bbdb-64f46217db8e"
		property string xbox_client_id: "1f907974-e22b-4810-a9de-d9647380c97e"
		property string preferredforceIp: ""		// IP to bypass region restriction, so i need to get some static ips which always exist and use them here
		property string preferredLanguage: "en-US"
		property string preferredMarket: "US"
		property string preferredCorrelationVector: "0"
		property string preferredCallingAppName: "Xbox Cloud Gaming Web"
		property string preferredCallingAppVersion: "24.17.63"
		property string preferredPlatform: "Console"
		property string preferredSubscription: "Ultimate"
		property bool displayPosters: true
		property int user_mode: 1
		property bool displayPlayableGames: true


		// Login Process
		property var userToken: ({})		// 1 hour expiration
		property var msalToken: ({})		// 1 hour expiration
		property var xstsToken: ({})		// 4 days expiration
		property var webToken: ({})			// 16 hours expiration
		property var gssvToken: ({})		// 16 hours expiration
		property var xhomeToken: ({})		// 4 hours expiration
		property var xcloudToken: ({})		// 4 hours expiration

		// User Data
		property string xid: ""

		property real videoVolume: 0.8
	}

property var deepLinkData: []
	property var test_xmlhttp: new XMLHttpRequest()
	Component.onCompleted: {
		// root.test_xmlhttp.abort();						// cancel old call if any
		// root.test_xmlhttp = new XMLHttpRequest();		// clear old data

		// var url = "https://filmtoro.cz/.well-known/apple-app-site-association";

		// // when responce received then do the following script:
		// root.test_xmlhttp.onload = function() {
		// 	console.log("reply");
		// 	console.log(root.test_xmlhttp.responseText);
		// }

		// root.test_xmlhttp.open("GET", url, true);
		// //root.test_xmlhttp.responseType = "json";
		// root.test_xmlhttp.send();
	}


	property string activeSessionTitleId: ""
	property string activeSessionId: ""
	property date activeSessionStarted: new Date(0)
	Timer {
		id: keepAliveTimer
		running: false
		repeat: true
		triggeredOnStart: true
		onTriggered: streamAPI.sendKeepAlive()
	}



	Timer {
		id: refreshTokenTimer
		running: true
		interval: 60000
		repeat: true
		triggeredOnStart: true
		onTriggered: {
			if (root.oauth2Display) { return; }		// oauth in process, so we wait to finish
			if (!settingsData.userToken["refresh_token"] || !settingsData.userToken["expires_in"]) { loginAPI.doDeviceCodeAuth(); return; }		// dont have valid refresh_token

			loginAPI.assignloginToken("userToken", loginAPI.checkTokenExpiration(settingsData.userToken["expires_in"], "userToken"));
			loginAPI.assignloginToken("msalToken", loginAPI.checkTokenExpiration(settingsData.msalToken["expires_in"], "msalToken"));
			loginAPI.assignloginToken("xstsToken", loginAPI.checkTokenExpiration(settingsData.xstsToken["expires_in"], "xstsToken"));
			loginAPI.assignloginToken("webToken", loginAPI.checkTokenExpiration(settingsData.webToken["expires_in"], "webToken"));
			loginAPI.assignloginToken("gssvToken", loginAPI.checkTokenExpiration(settingsData.gssvToken["expires_in"], "gssvToken"));
			loginAPI.assignloginToken("xhomeToken", loginAPI.checkTokenExpiration(settingsData.xhomeToken["expires_in"], "xhomeToken"));
			loginAPI.assignloginToken("xcloudToken", loginAPI.checkTokenExpiration(settingsData.xcloudToken["expires_in"], "xcloudToken"));
		}
	}

	property var loginCompleted: []
	onLoginCompletedChanged: {
		if (settingsData.debugMode) { console.log(root.loginCompleted.length, "loginChanged triggered:", JSON.stringify(root.loginCompleted)); }

		if (loginCompleted.length === 7) {
			if (settingsData.debugMode) { console.log("all tokens found registered, proceeding with check"); }

			var needToRefreshTokens = false;
			for (var i=0; i<root.loginCompleted.length; i++) {
				if (root.loginCompleted[i]["returnValue"] === false) {
					if (settingsData.debugMode) { console.log("token", root.loginCompleted[i]["tokenType"], "is false, thefeore settings up needToRefreshTokens"); }
					needToRefreshTokens = true;
				}
				else {
					if (settingsData.debugMode) { console.log("token", root.loginCompleted[i]["tokenType"], "is true"); }
				}
			}

			if (needToRefreshTokens === true) {
				if (settingsData.debugMode) { console.log("refreshing all tokens"); }
				root.loginCompleted = [];		// need to clear array because if now one of the token changes and being updated here in array, its again length of 7 and immidiately it will srtart refreshing again while other tokens are currently being refreshed.... alternativly i can check if any of the xmlhttprequest for token is pending reply
				loginAPI.refreshTokens();
			}
			else {
				if (settingsData.debugMode) { console.log("all tokens OK, finishing up login process"); }
				root.initialOwnUserDetailLoad = true;
				root.initialGameListLoad = true;
			}
		}
	}

	property bool initialOwnUserDetailLoad: false
		onInitialOwnUserDetailLoadChanged: {
			if (settingsData.debugMode) { console.log("initialOwnUserDetailLoad triggered, calling personAPI.getOwnUserData()"); }
			if (initialOwnUserDetailLoad) { personAPI.getOwnUserData(); }
		}
	property bool initialGameListLoad: false
		onInitialGameListLoadChanged: {
			if (settingsData.debugMode) { console.log("initialGameListLoad triggered, calling modelItem.fullGameList.getFullList()"); }
			if (initialGameListLoad) { modelItem.fullGameList.getFullList(); }
		}



	// Login Requests
	property var refreshTokens_xmlhttp: new XMLHttpRequest()
	property var doDeviceCodeAuth_xmlhttp: new XMLHttpRequest()
	property var doPollForDeviceCodeAuth_xmlhttp: new XMLHttpRequest()
	property var getMsalToken_xmlhttp: new XMLHttpRequest()
	property var doXstsAuthentication_xmlhttp: new XMLHttpRequest()
	property var getWebToken_xmlhttp: new XMLHttpRequest()
	property var getGssvToken_xmlhttp: new XMLHttpRequest()
	property var getXhomeToken_xmlhttp: new XMLHttpRequest()
	property var getXcloudToken_xmlhttp: new XMLHttpRequest()

	// Stream Requests
	property var getConsoleListInfo_xmlhttp: new XMLHttpRequest()
	property var startSession_xmlhttp: new XMLHttpRequest()
	property var configureSession_xmlhttp: new XMLHttpRequest()
	property var checkStateSession_xmlhttp: new XMLHttpRequest()
	property var sendMsalAuthentication_xmlhttp: new XMLHttpRequest()
	property var sendSdpOffer_xmlhttp: new XMLHttpRequest()
	property var checkSdpOffer_xmlhttp: new XMLHttpRequest()
	property var sendIceCandidates_xmlhttp: new XMLHttpRequest()
	property var checkIceCandidates_xmlhttp: new XMLHttpRequest()

	property var sendKeepAlive_xmlhttp: new XMLHttpRequest()
	property var stopSession_xmlhttp: new XMLHttpRequest()

	// Profile Requests
	property var getOwnUserData_xmlhttp: new XMLHttpRequest()

	// Title Requests
	property var getEpList_xmlhttp: new XMLHttpRequest()
	property var getEpList_add_xmlhttp: new XMLHttpRequest()
	property var getEpList_remove_xmlhttp: new XMLHttpRequest()
	// property var getGameList_xmlhttp: new XMLHttpRequest()
	// property var updateGameList_xmlhttp: new XMLHttpRequest()


	property var modelItem: ModelItem {}	//modelItem
	property var funcAPI: FuncAPI {}
	property var loginAPI: LoginAPI {}
	property var streamAPI: StreamAPI {}
	property var titleAPI: TitleAPI {}
	property var personAPI: PersonAPI {}


	Rectangle {
		id: view
		anchors.fill: parent
		color: modelItem.theme["Background/Main"]

		property string hasFocus: "leftMenu"
		onHasFocusChanged: {
			if (hasFocus === "") {
				mainMenu.focus = false;
					mainMenuList.focus = false;
					mainMenuDetail.focus = false;
				topMenu.focus = false;
				leftMenu.focus = false;
			}
			else if (hasFocus === "leftMenu") {
				mainMenu.focus = false;
					mainMenuList.focus = false;
					mainMenuDetail.focus = false;
				topMenu.focus = false;
				leftMenu.focus = true;
			}
			else if (hasFocus === "topMenu") {
				mainMenu.focus = false;
					mainMenuList.focus = false;
					mainMenuDetail.focus = false;
				leftMenu.focus = false;
				topMenu.focus = true;
			}
			else if (hasFocus === "mainMenu") {
				topMenu.focus = false;
				leftMenu.focus = false;
				mainMenu.focus = true;
					mainMenuList.focus = false;
					mainMenuDetail.focus = false;
			}
				else if (hasFocus === "mainMenuList") {
					topMenu.focus = false;
					leftMenu.focus = false;
					mainMenu.focus = false;
						mainMenuDetail.focus = false;
						mainMenuList.focus = true;
				}
				else if (hasFocus === "mainMenuDetail") {
					topMenu.focus = false;
					leftMenu.focus = false;
					mainMenu.focus = false;
						mainMenuList.focus = false;
						mainMenuDetail.focus = true;
				}
			else { console.log("UNEXPECTED view.hasFocus =", hasFocus); }
		}

		// MAIN SCREEN - GAMELIST
		StackLayout {
			id: mainMenu
			anchors.fill: parent
			currentIndex: 0

			focus: false
			onFocusChanged: if (focus) { mainMenu.setFocus(); }

			property string currentView: mainMenu.children[mainMenu.currentIndex].objectName


			MainMenuList {
				id: mainMenuList
				objectName: "mainMenuList"
				focus: false
				onFocusChanged: if (focus) { view.hasFocus = "mainMenuList"; }
			}

			MainMenuDetail {
				id: mainMenuDetail
				objectName: "mainMenuDetail"
				focus: false
				onFocusChanged: if (focus) { view.hasFocus = "mainMenuDetail"; }
			}


			function changeMainMenu(mainMenuName = "mainMenuList") {
				for (var i = 0; i<mainMenu.children.length; i++) {
					if (mainMenu.children[i].objectName === mainMenuName) {
						mainMenu.currentIndex = i;
						return true;
					}
				}
				console.warn("StackLayout does not have objectName:", mainMenuName);
				return false;
			}

			function setFocus() {
				if (mainMenu.focus) {
					for (var i = 0; i<mainMenu.children.length; i++) {
						if (i === mainMenu.currentIndex) {
							//mainMenu.children[i].focus = true;
							view.hasFocus = mainMenu.children[i].objectName;
						}
						else {
							//mainMenu.children[i].focus = false;
						}
					}
				}
			}
		}

		// LEFT MENU
		TopMenu {
			id: topMenu
			focus: false
			onFocusChanged: if (focus) { view.hasFocus = "topMenu"; }
			visible: mainMenu.currentView === "mainMenuList" ? true : false
		}

		// LEFT MENU
		LeftMenu {
			id: leftMenu
			focus: true
			onFocusChanged: if (focus) { view.hasFocus = "leftMenu"; }
		}
	}


	// SCREENSHOT / TRAILER Display
	VideoImage {
		id: imgRect
		anchors.centerIn: parent
		width: parent.width * 0.8
		height: parent.height * 0.8

		visible: source !== "" || coverImage !== ""
	}


	property bool oauth2Display: loginAPI.deviceTokenJson["user_code"] ? true : false
	Login { id: oauth2Screen }

	property bool gamePlayerVisible: false
	GamePlayer { id: gamePlayer }


}