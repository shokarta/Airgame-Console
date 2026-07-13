import QtQuick

Item {
	id: streamAPI
	

	function getConsoleListInfo() {
		root.getConsoleListInfo_xmlhttp.abort();						// cancel old call if any
		root.getConsoleListInfo_xmlhttp = new XMLHttpRequest();		// clear old data

		var url = "https://xccs.xboxlive.com/lists/devices?queryCurrentDevice=false&includeStorageDevices=true";

		// when responce received then do the following script:
		root.getConsoleListInfo_xmlhttp.onload = function() {

			// Error Handler
			let reply;
			try { reply = root.getConsoleListInfo_xmlhttp.response; }
			catch (exception) { console.log("error occured on getConsoleListInfo_xmlhttp:", exception); return; }

			if (reply["code"]) {
				// if (reply["error"] === "authorization_pending")			{ }		// do nothing, timer will check again
				// else if (reply["error"] === "authorization_declined")	{ doPollForDeviceCodeAuthTimer.stop(); doDeviceCodeAuth(); }	// user rejected, start over
				// else if (reply["error"] === "bad_verification_code")	{ doPollForDeviceCodeAuthTimer.stop(); doDeviceCodeAuth(); }	// bad device_code, start over
				// else if (reply["error"] === "expired_token")			{ doPollForDeviceCodeAuthTimer.stop(); doDeviceCodeAuth(); }	// token expired, start over
				// else if (reply["error"] === "invalid_grant")			{ doPollForDeviceCodeAuthTimer.stop(); }	// process finished // TODO: check if process is finished
				console.log("unexpected error in getDeviceInfo():", JSON.stringify(reply));
			}
			else {
				//var tempObject = new Object;
				//tempObject["token_type"] = reply["token_type"];
				//tempObject["scope"] = reply["scope"];
				//tempObject["access_token"] = reply["access_token"];
				//tempObject["refresh_token"] = reply["refresh_token"];
				//tempObject["user_id"] = reply["user_id"];
				//tempObject["expires_in"] = new Date(Date.now() + reply["expires_in"] * 1000);
				//settingsData.msalToken = tempObject;
				//assignloginToken("msalToken", true);
			}
		}

		root.getConsoleListInfo_xmlhttp.open("GET", url, true);
			root.getConsoleListInfo_xmlhttp.setRequestHeader("Authorization", "XBL3.0 x=" + settingsData.webToken["DisplayClaims"]["xui"][0]["uhs"] + ";" + settingsData.webToken["token"]);
			root.getConsoleListInfo_xmlhttp.setRequestHeader("Accept-Language", "en-US");
			root.getConsoleListInfo_xmlhttp.setRequestHeader("x-xbl-contract-version", "2");
			root.getConsoleListInfo_xmlhttp.setRequestHeader("x-xbl-client-name", "XboxApp");
			root.getConsoleListInfo_xmlhttp.setRequestHeader("x-xbl-client-type", "UWA");
			root.getConsoleListInfo_xmlhttp.setRequestHeader("x-xbl-client-version", "39.39.22001.0");
			if (settingsData.preferredforceIp !== "") { root.getConsoleListInfo_xmlhttp.setRequestHeader("X-Forwarded-For", settingsData.preferredforceIp); }

		root.getConsoleListInfo_xmlhttp.responseType = "json";
		root.getConsoleListInfo_xmlhttp.send();
	}


	function startSession(titleId) {
		root.startSession_xmlhttp.abort();						// cancel old call if any
		root.startSession_xmlhttp = new XMLHttpRequest();		// clear old data

		var url = settingsData.xcloudToken["offeringSettings"]["regions"].find(r => r.isDefault).baseUri + "/v5/sessions/cloud/play";

		// when responce received then do the following script:
		root.startSession_xmlhttp.onload = function() {

			// Error Handler
			let reply;
			try { reply = root.startSession_xmlhttp.response; }
			catch (exception) { console.log("error occured on startSession_xmlhttp:", exception); return; }

			if (!reply["sessionPath"]) {
				//{"code":"OfferingDoesNotContainTitle","statusCode":400,"message":"Offering XGPUWEB does not contain title 33IMMORTALSGAMEPREVIEWFDFS"}
				//{"code":"InvalidRequestParameter","statusCode":400,"message":"Request validation failed for parameter TitleId. Error: Required request parameter TitleId cannot be null / empty / whitespaces."}
				// if (reply["error"] === "authorization_pending")			{ }
				// else if (reply["error"] === "authorization_declined")	{ }
				console.log("unexpected error in startSession():", JSON.stringify(reply));
			}
			else {
				root.activeSessionTitleId = titleId;
				root.activeSessionId = reply["sessionPath"].split("/")[3];
				root.activeSessionStarted = new Date();

				checkStateSession();
			}
		}

		var deviceInfo = {
			"appInfo": {
				"env": {
					"clientAppId": "www.xbox.com",
					"clientAppType": "browser",
					"clientAppVersion": "29.17.32",
					"clientSdkVersion": "10.6.53",
					"httpEnvironment": "prod",
					"sdkInstallId": ""		// 109afbe6-9e81-4f7e-85ca-f1de8f55b54c
				},
			},
			"dev": {
				"hw": {
					"make": "unknown",		// Microsoft
					"model": "unknown",
					"platformType": "desktop",
					"sdktype": "web"
				},
				"os": {
					"name": "android",		// android = 720P / windows = 1080P / tizen = 1080P(HQ) or 1440P
					"ver": "22631.2715",
					"platform": "desktop"
				},
				"displayInfo": {
					"dimensions": {
						"widthInPixels": 1920,		// 1920 / 4096
						"heightInPixels": 1080,		// 1080 / 2160
					},
					"pixelDensity": {
						"dpiX": 1,
						"dpiY": 1
					},
				},
				"browser": {
					"browserName": "edge",
					"browserVersion": "149.0.4022.62"
				}
			},
		};

		var postData = {
			clientSessionId: "",
			fallbackRegionNames: [],
			settings: {
				nanoVersion: "V3;WebrtcTransport.dll",
				enableTextToSpeech: false,
				highContrast: 0,
				locale: settingsData.preferredLanguage,
				useIceConnection: false,
				timezoneOffsetMinutes: 120,
				sdkType: "web",
				osName: "android"
			},
			systemUpdateGroup: "",
			serverId: "",
			titleId: titleId
		};

		root.startSession_xmlhttp.open("POST", url, true);
			root.startSession_xmlhttp.setRequestHeader("Authorization", "Bearer " + settingsData.xcloudToken["gsToken"]);
			root.startSession_xmlhttp.setRequestHeader("X-MS-Device-Info", JSON.stringify(deviceInfo));
			root.startSession_xmlhttp.setRequestHeader("Content-Type", "application/json");
			if (settingsData.preferredforceIp !== "") { root.startSession_xmlhttp.setRequestHeader("X-Forwarded-For", settingsData.preferredforceIp); }

		root.startSession_xmlhttp.responseType = "json";
		root.startSession_xmlhttp.send(JSON.stringify(postData));
	}


	function checkStateSession() {
		root.checkStateSession_xmlhttp.abort();						// cancel old call if any
		root.checkStateSession_xmlhttp = new XMLHttpRequest();		// clear old data

		var url = settingsData.xcloudToken["offeringSettings"]["regions"].find(r => r.isDefault).baseUri + "/v5/sessions/cloud/" + root.activeSessionId + "/state";

		// when responce received then do the following script:
		root.checkStateSession_xmlhttp.onload = function() {

			// Error Handler
			let reply;
			try { reply = root.checkStateSession_xmlhttp.response; }
			catch (exception) { console.log("error occured on checkStateSession_xmlhttp:", exception); return; }

			if (!reply["state"]) {
				console.log("unexpected error in checkStateSession():", JSON.stringify(reply));
				return;
			}
			else {
				if (reply["state"] === "ReadyToConnect") {
					console.log("state:", reply["state"]);
					sendMsalAuthentication();
				}
				else if (reply["state"] === "Provisioning" || reply["state"] === "WaitingForResources") {
					// TODO, if
					console.log("state:", reply["state"]);
					checkStateSessionTimer.restart();	// check again after 1s
				}
				else if (reply["state"] === "Provisioned") {
					console.log("state:", reply["state"]);
					configureSession();
				}
				else {
					console.log("unexpected state in checkStateSession():", JSON.stringify(reply));
					return;
				}
			}
		}

		root.checkStateSession_xmlhttp.open("GET", url, true);
			root.checkStateSession_xmlhttp.setRequestHeader("Authorization", "Bearer " + settingsData.xcloudToken["gsToken"]);
			root.checkStateSession_xmlhttp.setRequestHeader("Content-Type", "application/json");
			if (settingsData.preferredforceIp !== "") { root.checkStateSession_xmlhttp.setRequestHeader("X-Forwarded-For", settingsData.preferredforceIp); }

		root.checkStateSession_xmlhttp.responseType = "json";
		root.checkStateSession_xmlhttp.send();
	}


	function sendMsalAuthentication() {
		root.sendMsalAuthentication_xmlhttp.abort();						// cancel old call if any
		root.sendMsalAuthentication_xmlhttp = new XMLHttpRequest();		// clear old data

		var url = settingsData.xcloudToken["offeringSettings"]["regions"].find(r => r.isDefault).baseUri + "/v5/sessions/cloud/" + root.activeSessionId + "/connect";

		// when responce received then do the following script:
		root.sendMsalAuthentication_xmlhttp.onload = function() {

			// Error Handler		// this does not return anything, therefore we proceed anyway
			//let reply;
			//try { reply = root.sendMsalAuthentication_xmlhttp.response; }
			//catch (exception) { console.log("error occured on sendMsalAuthentication_xmlhttp:", exception); return; }

			checkStateSession();
		}

		var postData = {
			userToken: settingsData.msalToken["access_token"]
		};

		root.sendMsalAuthentication_xmlhttp.open("POST", url, true);
			root.sendMsalAuthentication_xmlhttp.setRequestHeader("Authorization", "Bearer " + settingsData.xcloudToken["gsToken"]);
			root.sendMsalAuthentication_xmlhttp.setRequestHeader("Content-Type", "application/json");
			if (settingsData.preferredforceIp !== "") { root.sendMsalAuthentication_xmlhttp.setRequestHeader("X-Forwarded-For", settingsData.preferredforceIp); }

		root.sendMsalAuthentication_xmlhttp.responseType = "json";
		root.sendMsalAuthentication_xmlhttp.send(JSON.stringify(postData));
	}


	function configureSession() {
		root.configureSession_xmlhttp.abort();						// cancel old call if any
		root.configureSession_xmlhttp = new XMLHttpRequest();		// clear old data

		var url = settingsData.xcloudToken["offeringSettings"]["regions"].find(r => r.isDefault).baseUri + "/v5/sessions/cloud/" + root.activeSessionId + "/configuration";

		// when responce received then do the following script:
		root.configureSession_xmlhttp.onload = function() {

			// Error Handler
			let reply;
			try { reply = root.configureSession_xmlhttp.response; }
			catch (exception) { console.log("error occured on configureSession_xmlhttp:", exception); return; }

			if (reply["code"]) {
				console.log("unexpected error in configureSession():", JSON.stringify(reply));
			}
			else {
				keepAliveTimer.interval = reply["keepAlivePulseInSeconds"] * 1000;
				// {
				// 	"keepAlivePulseInSeconds": 60,
				// 	"timeoutForNoConnectionSeconds": 300,
				// 	"serverDetails": {
				// 		"ipAddress": "13.104.106.200",
				// 		"port": 1048,
				// 		"ipV4Address": "13.104.106.200",
				// 		"ipV4Port": 1048,
				// 		"ipV6Address": "[2603:1020:204:84::ADB:641A]",
				// 		"ipV6Port": 9002,
				// 		"srtp": {
				// 			"key": "uheEwmI/1gID/D60FW/EqD3TzpcnjmJeqIdQcupP"
				// 		},
				// 		"ipV4List": [
				// 			{
				// 				"address": "13.104.106.200",
				// 				"port": 1048,
				// 				"rigPort": 1280,
				// 				"routingPreference": "AZURE"
				// 			}
				// 		]
				// 	},
				// 	"clientStreamingConfigOverrides": "{\"chatConfiguration\":{\"useMediaStreamsChat\":true},\"inputConfiguration\":{\"useIntervalWorkerThreadForInput\":true},\"nqiConfiguration\":{\"consecutiveBadIntervalsForTrigger\":10,\"pingMsBadThreshold\":100}}"
				// }

				webrtc.createOffer();	// this triggers generation of SDP Offer and sends it into sendSdpOffer(sdp)
			}
		}

		root.configureSession_xmlhttp.open("GET", url, true);
			root.configureSession_xmlhttp.setRequestHeader("Authorization", "Bearer " + settingsData.xcloudToken["gsToken"]);
			root.configureSession_xmlhttp.setRequestHeader("Content-Type", "application/json");
			if (settingsData.preferredforceIp !== "") { root.configureSession_xmlhttp.setRequestHeader("X-Forwarded-For", settingsData.preferredforceIp); }

		root.configureSession_xmlhttp.responseType = "json";
		root.configureSession_xmlhttp.send();
	}


	function sendSdpOffer(sdp) {
		root.sendSdpOffer_xmlhttp.abort();						// cancel old call if any
		root.sendSdpOffer_xmlhttp = new XMLHttpRequest();		// clear old data

		var url = settingsData.xcloudToken["offeringSettings"]["regions"].find(r => r.isDefault).baseUri + "/v5/sessions/cloud/" + root.activeSessionId + "/sdp";
console.log("sdpOffer send to url:", url);
		// when responce received then do the following script:
		root.sendSdpOffer_xmlhttp.onload = function() {

			// Error Handler		// this does not return anything, therefore we proceed anyway
			//let reply;
			//try { reply = root.sendSdpOffer_xmlhttp.response; }
			//catch (exception) { console.log("error occured on sendSdpOffer_xmlhttp:", exception); return; }

			checkSdpOffer();
		}

		var postData = {
			messageType: 'offer',
			sdp: sdp,
			configuration: {
				chatConfiguration: {
					//isMediaStreamsChatRenegotiation: true,
					bytesPerSample: 2,
					expectedClipDurationMs: 20,
					format: {
						codec: 'opus',
						container: 'webm',
					},
					numChannels: 1,
					sampleFrequencyHz: 24000
				},
				chat: {
					minVersion: 1,
					maxVersion: 1
				},
				control: {
					minVersion: 1,
					maxVersion: 3
				},
				input: {
					minVersion: 1,
					maxVersion: 9
				},
				message: {
					minVersion: 1,
					maxVersion: 1
				},
				reliableinput: {
					minVersion: 9,
					maxVersion: 9
				},
				unreliableinput: {
					minVersion: 9,
					maxVersion: 9
				}
			}
		};

		root.sendSdpOffer_xmlhttp.open("POST", url, true);
			root.sendSdpOffer_xmlhttp.setRequestHeader("Authorization", "Bearer " + settingsData.xcloudToken["gsToken"]);
			root.sendSdpOffer_xmlhttp.setRequestHeader("Content-Type", "application/json");
			if (settingsData.preferredforceIp !== "") { root.sendSdpOffer_xmlhttp.setRequestHeader("X-Forwarded-For", settingsData.preferredforceIp); }

		root.sendSdpOffer_xmlhttp.responseType = "json";
		root.sendSdpOffer_xmlhttp.send(JSON.stringify(postData));
	}


	function checkSdpOffer() {
		root.checkSdpOffer_xmlhttp.abort();						// cancel old call if any
		root.checkSdpOffer_xmlhttp = new XMLHttpRequest();		// clear old data

		var url = settingsData.xcloudToken["offeringSettings"]["regions"].find(r => r.isDefault).baseUri + "/v5/sessions/cloud/" + root.activeSessionId + "/sdp";
console.log("sdpOffer reply queried to url:", url);
		// when responce received then do the following script:
		root.checkSdpOffer_xmlhttp.onload = function() {
//console.log("sdpOffer reply received:", root.checkSdpOffer_xmlhttp.responseText)
			// Error Handler
			let reply;
			try { reply = root.checkSdpOffer_xmlhttp.response; }
			catch (exception) {
				//console.log("error occured on checkSdpOffer_xmlhttp:", exception);

				var timeStart = new Date().getTime();
				while (new Date().getTime() - timeStart < 1000) {} // do nothing, just wait
				console.log("re-quering checkSdpOffer()");
				checkSdpOffer(); return;
			}

			if (reply["exchangeResponse"]) {
				var exchangeObj = JSON.parse(reply["exchangeResponse"]);
				if (exchangeObj["status"] === "success") {
					webrtc.setRemoteAnswer(exchangeObj["sdp"]);
					sendIceCandidates(webrtc.localIceCandidates);
				}
				else {
					console.log("unexpected success status in checkSdpOffer() exchangeResponse:", JSON.stringify(reply));
				}
			}
			else {
				console.log("unexpected reply in checkSdpOffer():", JSON.stringify(reply));
			}
		}

		root.checkSdpOffer_xmlhttp.open("GET", url, true);
			root.checkSdpOffer_xmlhttp.setRequestHeader("Authorization", "Bearer " + settingsData.xcloudToken["gsToken"]);
			root.checkSdpOffer_xmlhttp.setRequestHeader("Content-Type", "application/json");
			if (settingsData.preferredforceIp !== "") { root.checkSdpOffer_xmlhttp.setRequestHeader("X-Forwarded-For", settingsData.preferredforceIp); }

		root.checkSdpOffer_xmlhttp.responseType = "json";
		root.checkSdpOffer_xmlhttp.send();
	}


	function sendIceCandidates(candidates) {
		root.sendIceCandidates_xmlhttp.abort();						// cancel old call if any
		root.sendIceCandidates_xmlhttp = new XMLHttpRequest();		// clear old data

		var url = settingsData.xcloudToken["offeringSettings"]["regions"].find(r => r.isDefault).baseUri + "/v5/sessions/cloud/" + root.activeSessionId + "/ice";
console.log("iceCandidates send to url:", url);
		// when responce received then do the following script:
		root.sendIceCandidates_xmlhttp.onload = function() {

			// Error Handler		// this does not return anything, therefore we proceed anyway
			//let reply;
			//try { reply = root.sendIceCandidates_xmlhttp.response; }
			//catch (exception) { console.log("error occured on sendIceCandidates_xmlhttp:", exception); return; }

			checkIceCandidates();
		}

		var postData = {
			messageType: 'iceCandidate',
			candidate: candidates
		};

		root.sendIceCandidates_xmlhttp.open("POST", url, true);
			root.sendIceCandidates_xmlhttp.setRequestHeader("Authorization", "Bearer " + settingsData.xcloudToken["gsToken"]);
			root.sendIceCandidates_xmlhttp.setRequestHeader("Content-Type", "application/json");
			if (settingsData.preferredforceIp !== "") { root.sendIceCandidates_xmlhttp.setRequestHeader("X-Forwarded-For", settingsData.preferredforceIp); }

		root.sendIceCandidates_xmlhttp.responseType = "json";
		root.sendIceCandidates_xmlhttp.send(JSON.stringify(postData));
	}


	function checkIceCandidates() {
		root.checkIceCandidates_xmlhttp.abort();						// cancel old call if any
		root.checkIceCandidates_xmlhttp = new XMLHttpRequest();		// clear old data

		var url = settingsData.xcloudToken["offeringSettings"]["regions"].find(r => r.isDefault).baseUri + "/v5/sessions/cloud/" + root.activeSessionId + "/ice";
console.log("iceCandidated reply queried to url:", url);
		// when responce received then do the following script:
		root.checkIceCandidates_xmlhttp.onload = function() {
//console.log("iceCandidated reply received:", root.checkIceCandidates_xmlhttp.responseText)
			// Error Handler
			let reply;
			try { reply = root.checkIceCandidates_xmlhttp.response; }
			catch (exception) {
				//console.log("error occured on checkIceCandidates_xmlhttp:", exception);

				var timeStart = new Date().getTime();
				while (new Date().getTime() - timeStart < 1000) {} // do nothing, just wait
				console.log("re-quering checkIceCandidates()");
				checkIceCandidates(); return;
			}

			if (reply["exchangeResponse"]) {
				var exchangeObj = JSON.parse(reply["exchangeResponse"]);
				for (var i=0; i<exchangeObj.length; i++) {
					var candidate = exchangeObj[i]["candidate"];

					if (candidate === "a=end-of-candidates") { continue; }

					if (candidate.startsWith("a=")) { candidate = candidate.substring(2); }		// remove a= if it contains, but should not

					webrtc.addIceCandidate(candidate, exchangeObj[i]["sdpMid"], exchangeObj[i]["sdpMLineIndex"]);
				}
				keepAliveTimer.restart();
			}
			else {
				console.log("unexpected reply in checkIceCandidates():", JSON.stringify(reply));
			}
		}

		root.checkIceCandidates_xmlhttp.open("GET", url, true);
			root.checkIceCandidates_xmlhttp.setRequestHeader("Authorization", "Bearer " + settingsData.xcloudToken["gsToken"]);
			root.checkIceCandidates_xmlhttp.setRequestHeader("Content-Type", "application/json");
			if (settingsData.preferredforceIp !== "") { root.checkIceCandidates_xmlhttp.setRequestHeader("X-Forwarded-For", settingsData.preferredforceIp); }

		root.checkIceCandidates_xmlhttp.responseType = "json";
		root.checkIceCandidates_xmlhttp.send();
	}









	function sendKeepAlive() {
		root.sendKeepAlive_xmlhttp.abort();						// cancel old call if any
		root.sendKeepAlive_xmlhttp = new XMLHttpRequest();		// clear old data

		var url = settingsData.xcloudToken["offeringSettings"]["regions"].find(r => r.isDefault).baseUri + "/v5/sessions/cloud/" + root.activeSessionId + "/keepalive";

		// when responce received then do the following script:
		root.sendKeepAlive_xmlhttp.onload = function() {
console.log("KEEPALIVE REPLY:", root.sendKeepAlive_xmlhttp.responseText);
			// Error Handler		// this does not return anything, therefore we proceed anyway
			let reply;
			try { reply = root.sendKeepAlive_xmlhttp.response; }
			catch (exception) { console.log("error occured on sendKeepAlive_xmlhttp:", exception); return; }

			// {"aliveSeconds":null,"reason":"None"}
			// {"code":"SessionNotActive","statusCode":410,"message":"Session F216B012-C7E4-426E-B005-7C0EE88D6DB5 no longer active"}
			if (reply["statusCode"]) {
				keepAliveTimer.stop();
				root.gamePlayerVisible = false;
			}
			else {
				root.gamePlayerVisible = true;
			}
		}

		var postData = {};		// empty post data

		root.sendKeepAlive_xmlhttp.open("POST", url, true);
			root.sendKeepAlive_xmlhttp.setRequestHeader("Authorization", "Bearer " + settingsData.xcloudToken["gsToken"]);
			root.sendKeepAlive_xmlhttp.setRequestHeader("Content-Type", "application/json");
			if (settingsData.preferredforceIp !== "") { root.sendKeepAlive_xmlhttp.setRequestHeader("X-Forwarded-For", settingsData.preferredforceIp); }

		root.sendKeepAlive_xmlhttp.responseType = "json";
		root.sendKeepAlive_xmlhttp.send(JSON.stringify(postData));
	}


	function stopSession() {
		root.stopSession_xmlhttp.abort();						// cancel old call if any
		root.stopSession_xmlhttp = new XMLHttpRequest();		// clear old data

		var url = settingsData.xcloudToken["offeringSettings"]["regions"].find(r => r.isDefault).baseUri + "/v5/sessions/cloud/" + root.activeSessionId;

		// when responce received then do the following script:
		root.stopSession_xmlhttp.onload = function() {
console.log("STOPSESSION REPLY:", root.stopSession_xmlhttp.responseText);
			// Error Handler		// this does not return anything, therefore we proceed anyway
			//let reply;
			//try { reply = root.stopSession_xmlhttp.response; }
			//catch (exception) { console.log("error occured on stopSession_xmlhttp:", exception); return; }

			root.gamePlayerVisible = false;
		}

		root.stopSession_xmlhttp.open("DELETE", url, true);
			root.stopSession_xmlhttp.setRequestHeader("Authorization", "Bearer " + settingsData.xcloudToken["gsToken"]);
			root.stopSession_xmlhttp.setRequestHeader("Content-Type", "application/json");
			if (settingsData.preferredforceIp !== "") { root.stopSession_xmlhttp.setRequestHeader("X-Forwarded-For", settingsData.preferredforceIp); }

		root.stopSession_xmlhttp.responseType = "json";
		root.stopSession_xmlhttp.send();
	}






	Timer {
		id: checkStateSessionTimer
		interval: 1000
		running: false
		repeat: false
		onTriggered: checkStateSession()
	}
}
