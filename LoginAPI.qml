import QtQuick

Item {
	id: loginAPI
	

	function debugTokenExpiration() {
		const now = new Date();

		var userTokenExpiration = settingsData.userToken["expires_in"];
		console.log("userToken expires", Qt.formatDateTime(userTokenExpiration, "d.M.yyyy hh:mm:ss"), "which is in:", funcAPI.formatDurationCompactSigned(userTokenExpiration - now));

		var msalTokenExpiration = settingsData.msalToken["expires_in"];
		console.log("msalToken expires", Qt.formatDateTime(msalTokenExpiration, "d.M.yyyy hh:mm:ss"), "which is in:", funcAPI.formatDurationCompactSigned(msalTokenExpiration - now));

		var xstsTokenExpiration = settingsData.xstsToken["expires_in"];
		console.log("xstsToken expires", Qt.formatDateTime(xstsTokenExpiration, "d.M.yyyy hh:mm:ss"), "which is in:", funcAPI.formatDurationCompactSigned(xstsTokenExpiration - now));

		var webTokenExpiration = settingsData.webToken["expires_in"];
		console.log("webToken expires", Qt.formatDateTime(webTokenExpiration, "d.M.yyyy hh:mm:ss"), "which is in:", funcAPI.formatDurationCompactSigned(webTokenExpiration - now));

		var gssvTokenExpiration = settingsData.gssvToken["expires_in"];
		console.log("gssvToken expires", Qt.formatDateTime(gssvTokenExpiration, "d.M.yyyy hh:mm:ss"), "which is in:", funcAPI.formatDurationCompactSigned(gssvTokenExpiration - now));

		var xhomeTokenExpiration = settingsData.xhomeToken["expires_in"];
		console.log("xhomeToken expires", Qt.formatDateTime(xhomeTokenExpiration, "d.M.yyyy hh:mm:ss"), "which is in:", funcAPI.formatDurationCompactSigned(xhomeTokenExpiration - now));

		var xcloudTokenExpiration = settingsData.xcloudToken["expires_in"];
		console.log("xcloudToken expires", Qt.formatDateTime(xcloudTokenExpiration, "d.M.yyyy hh:mm:ss"), "which is in:", funcAPI.formatDurationCompactSigned(xcloudTokenExpiration - now));
	}

	function checkTokenExpiration(tokenExpiration, debugString) {
		var check1, check2, check3;

		if (tokenExpiration instanceof Date) {
			check1 = true;
			if (settingsData.debugMode) { console.log(debugString, "1st check OK"); }
		}
		else {
			check1 = false;
			if (settingsData.debugMode) { console.log(debugString, "1st check NOK"); }
		}

		if (!isNaN(tokenExpiration.getTime())) {
			check2 = true;
			if (settingsData.debugMode) { console.log(debugString, "2nd check OK"); }
		}
		else {
			check2 = false;
			if (settingsData.debugMode) { console.log(debugString, "2nd check NOK"); }
		}

		if (((tokenExpiration - new Date()) / 1000/60) > 5) {
			check3 = true;
			if (settingsData.debugMode) { console.log(debugString, "3rd check OK"); }
		}
		else {
			check3 = false;
			if (settingsData.debugMode) { console.log(debugString, "3rd check NOK"); }
		}

		if (check1 && check2 && check3) { return true; }
		else { return false; }
	}

	function assignloginToken(tokenType, returnValue) {
		var newArray = root.loginCompleted.slice();

		var found = false;
		for (var i=0; i<newArray.length; i++) {
			if (newArray[i]["tokenType"] === tokenType) { newArray[i]["returnValue"] = returnValue; found = true; }
		}
		if (!found) { newArray.push({ "tokenType": tokenType, "returnValue": returnValue }); }

		root.loginCompleted = newArray;
	}



	function refreshTokens() {
		root.refreshTokens_xmlhttp.abort();						// cancel old call if any
		root.refreshTokens_xmlhttp = new XMLHttpRequest();		// clear old data

		var url = "https://login.microsoftonline.com/consumers/oauth2/v2.0/token";

		// when responce received then do the following script:
		root.refreshTokens_xmlhttp.onload = function() {

			// Error Handler
			let reply;
			try { reply = root.refreshTokens_xmlhttp.response; }
			catch (exception) { console.log("error occured on refreshTokens_xmlhttp:", exception); return; }

			if (reply["error"]) {
				if (reply["error"] === "invalid_grant")	{}
				else { console.log("unexpected error in refreshTokens():", JSON.stringify(reply)); }

				doDeviceCodeAuth();
			}
			else {
				var tempObject = new Object;
				tempObject["token_type"] = reply["token_type"];
				tempObject["access_token"] = reply["access_token"];
				tempObject["refresh_token"] = reply["refresh_token"];
				tempObject["id_token"] = reply["id_token"];
				tempObject["expires_in"] = new Date(Date.now() + reply["expires_in"] * 1000);
				settingsData.userToken = tempObject;
				assignloginToken("userToken", true);

				getMsalToken();
				doXstsAuthentication();
			}
		}

		root.refreshTokens_xmlhttp.open("POST", url, true);
			root.refreshTokens_xmlhttp.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
			root.refreshTokens_xmlhttp.setRequestHeader('Cache-Control', 'no-store, must-revalidate, no-cache');
			if (settingsData.preferredforceIp !== "") { root.refreshTokens_xmlhttp.setRequestHeader('X-Forwarded-For', settingsData.preferredforceIp); }

		var payload = Object();
			payload.client_id = settingsData.xbox_client_id;
			payload.grant_type = 'refresh_token';
			payload.refresh_token = settingsData.userToken["refresh_token"];
			payload.scope = "xboxlive.signin openid profile offline_access";

		root.refreshTokens_xmlhttp.responseType = "json";
		root.refreshTokens_xmlhttp.send(funcAPI.jsonToForm(payload));
	}



	function doDeviceCodeAuth() {
		root.doDeviceCodeAuth_xmlhttp.abort();						// cancel old call if any
		root.doDeviceCodeAuth_xmlhttp = new XMLHttpRequest();		// clear old data

		var url = "https://login.microsoftonline.com/consumers/oauth2/v2.0/devicecode";

		// when responce received then do the following script:
		root.doDeviceCodeAuth_xmlhttp.onload = function() {

			// Error Handler
			let reply;
			try { reply = root.doDeviceCodeAuth_xmlhttp.response; }
			catch (exception) { console.log("error occured on doDeviceCodeAuth_xmlhttp:", exception); return; }

			deviceTokenJson = reply;
			doPollForDeviceCodeAuthTimer.restart();
		}

		root.doDeviceCodeAuth_xmlhttp.open("POST", url, true);
			root.doDeviceCodeAuth_xmlhttp.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
			if (settingsData.preferredforceIp !== "") { root.doDeviceCodeAuth_xmlhttp.setRequestHeader('X-Forwarded-For', settingsData.preferredforceIp); }

		var params = Object();
			params.client_id = settingsData.xbox_client_id;
			params.scope = "xboxlive.signin openid profile offline_access";

		root.doDeviceCodeAuth_xmlhttp.responseType = "json";
		root.doDeviceCodeAuth_xmlhttp.send(funcAPI.jsonToForm(params));
	}



	property var deviceTokenJson: ({})
	Timer {
		id: doPollForDeviceCodeAuthTimer
		interval: deviceTokenJson["interval"] * 1000
		running: false
		repeat: true
		onTriggered: doPollForDeviceCodeAuth()
	}
	function doPollForDeviceCodeAuth() {
		root.doPollForDeviceCodeAuth_xmlhttp.abort();						// cancel old call if any
		root.doPollForDeviceCodeAuth_xmlhttp = new XMLHttpRequest();		// clear old data

		var url = "https://login.microsoftonline.com/consumers/oauth2/v2.0/token";

		// when responce received then do the following script:
		root.doPollForDeviceCodeAuth_xmlhttp.onload = function() {

			// Error Handler
			let reply;
			try { reply = root.doPollForDeviceCodeAuth_xmlhttp.response; }
			catch (exception) { console.log("error occured on doPollForDeviceCodeAuth_xmlhttp:", exception); return; }

			if (reply["error"]) {
				// https://docs.azure.cn/en-us/entra/identity-platform/v2-oauth2-device-code
				if (reply["error"] === "authorization_pending")			{ }		// do nothing, timer will check again
				else if (reply["error"] === "authorization_declined")	{ doPollForDeviceCodeAuthTimer.stop(); doDeviceCodeAuth(); }	// user rejected, start over
				else if (reply["error"] === "bad_verification_code")	{ doPollForDeviceCodeAuthTimer.stop(); doDeviceCodeAuth(); }	// bad device_code, start over
				else if (reply["error"] === "expired_token")			{ doPollForDeviceCodeAuthTimer.stop(); doDeviceCodeAuth(); }	// token expired, start over
				else if (reply["error"] === "invalid_grant")			{ doPollForDeviceCodeAuthTimer.stop(); }	// process finished // TODO: check if process is finished
				else { console.log("unexpected error in doPollForDeviceCodeAuth():", JSON.stringify(reply)); }
			}
			else {
				var tempObject = new Object;
				tempObject["token_type"] = reply["token_type"];
				tempObject["access_token"] = reply["access_token"];
				tempObject["refresh_token"] = reply["refresh_token"];
				tempObject["id_token"] = reply["id_token"];
				tempObject["expires_in"] = new Date(Date.now() + reply["expires_in"] * 1000);
				settingsData.userToken = tempObject;
				assignloginToken("userToken", true);
				deviceTokenJson = ({});

				getMsalToken();
				doXstsAuthentication();
			}
		}

		root.doPollForDeviceCodeAuth_xmlhttp.open("POST", url, true);
			root.doPollForDeviceCodeAuth_xmlhttp.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
			if (settingsData.preferredforceIp !== "") { root.doPollForDeviceCodeAuth_xmlhttp.setRequestHeader('X-Forwarded-For', settingsData.preferredforceIp); }

		var params = Object();
			params.grant_type = 'urn:ietf:params:oauth:grant-type:device_code';
			params.client_id = settingsData.xbox_client_id;
			params.device_code = deviceTokenJson["device_code"];

		root.doPollForDeviceCodeAuth_xmlhttp.responseType = "json";
		root.doPollForDeviceCodeAuth_xmlhttp.timeout = 1000;
		root.doPollForDeviceCodeAuth_xmlhttp.send(funcAPI.jsonToForm(params));
	}



	function getMsalToken() {
		root.getMsalToken_xmlhttp.abort();						// cancel old call if any
		root.getMsalToken_xmlhttp = new XMLHttpRequest();		// clear old data

		var url = "https://login.live.com/oauth20_token.srf";

		// when responce received then do the following script:
		root.getMsalToken_xmlhttp.onload = function() {

			// Error Handler
			let reply;
			try { reply = root.getMsalToken_xmlhttp.response; }
			catch (exception) { console.log("error occured on getMsalToken_xmlhttp:", exception); return; }

			if (reply["error"]) {
				// if (reply["error"] === "authorization_pending")			{ }		// do nothing, timer will check again
				// else if (reply["error"] === "authorization_declined")	{ doPollForDeviceCodeAuthTimer.stop(); doDeviceCodeAuth(); }	// user rejected, start over
				// else if (reply["error"] === "bad_verification_code")	{ doPollForDeviceCodeAuthTimer.stop(); doDeviceCodeAuth(); }	// bad device_code, start over
				// else if (reply["error"] === "expired_token")			{ doPollForDeviceCodeAuthTimer.stop(); doDeviceCodeAuth(); }	// token expired, start over
				// else if (reply["error"] === "invalid_grant")			{ doPollForDeviceCodeAuthTimer.stop(); }	// process finished // TODO: check if process is finished
				console.log("unexpected error in getMsalToken():", JSON.stringify(reply));
			}
			else {
				var tempObject = new Object;
				tempObject["token_type"] = reply["token_type"];
				tempObject["scope"] = reply["scope"];
				tempObject["access_token"] = reply["access_token"];
				tempObject["refresh_token"] = reply["refresh_token"];
				tempObject["user_id"] = reply["user_id"];
				tempObject["expires_in"] = new Date(Date.now() + reply["expires_in"] * 1000);
				settingsData.msalToken = tempObject;
				assignloginToken("msalToken", true);
			}
		}

		root.getMsalToken_xmlhttp.open("POST", url, true);
			root.getMsalToken_xmlhttp.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
			if (settingsData.preferredforceIp !== "") { root.getMsalToken_xmlhttp.setRequestHeader('X-Forwarded-For', settingsData.preferredforceIp); }

		var params = Object();
			params.client_id = settingsData.xbox_client_id;
			params.scope = 'service::http://Passport.NET/purpose::PURPOSE_XBOX_CLOUD_CONSOLE_TRANSFER_TOKEN';
			params.grant_type = 'refresh_token';
			params.refresh_token = settingsData.userToken["refresh_token"];

		root.getMsalToken_xmlhttp.responseType = "json";
		root.getMsalToken_xmlhttp.send(funcAPI.jsonToForm(params));
	}



	function doXstsAuthentication() {
		root.doXstsAuthentication_xmlhttp.abort();						// cancel old call if any
		root.doXstsAuthentication_xmlhttp = new XMLHttpRequest();		// clear old data

		var url = "https://user.auth.xboxlive.com/user/authenticate";

		// when responce received then do the following script:
		root.doXstsAuthentication_xmlhttp.onload = function() {

			// Error Handler
			let reply;
			try { reply = root.doXstsAuthentication_xmlhttp.response; }
			catch (exception) { console.log("error occured on doXstsAuthentication_xmlhttp:", exception); return; }

			if (reply["error"]) {
				// if (reply["error"] === "authorization_pending")			{ }		// do nothing, timer will check again
				// else if (reply["error"] === "authorization_declined")	{ doPollForDeviceCodeAuthTimer.stop(); doDeviceCodeAuth(); }	// user rejected, start over
				// else if (reply["error"] === "bad_verification_code")	{ doPollForDeviceCodeAuthTimer.stop(); doDeviceCodeAuth(); }	// bad device_code, start over
				// else if (reply["error"] === "expired_token")			{ doPollForDeviceCodeAuthTimer.stop(); doDeviceCodeAuth(); }	// token expired, start over
				// else if (reply["error"] === "invalid_grant")			{ doPollForDeviceCodeAuthTimer.stop(); }	// process finished // TODO: check if process is finished
				console.log("unexpected error in doXstsAuthentication_xmlhttp():", JSON.stringify(reply));
			}
			else {
				var tempObject = new Object;
				tempObject["token"] = reply["Token"];
				tempObject["expires_in"] = funcAPI.parseIsoUtcToDate(reply["NotAfter"]);
				tempObject["DisplayClaims"] = reply["DisplayClaims"];
				settingsData.xstsToken = tempObject;
				assignloginToken("xstsToken", true);

				getWebToken();
				getGssvToken();
			}
		}

		root.doXstsAuthentication_xmlhttp.open("POST", url, true);
			root.doXstsAuthentication_xmlhttp.setRequestHeader('x-xbl-contract-version', '1');
			root.doXstsAuthentication_xmlhttp.setRequestHeader('Cache-Control', 'no-cache');
			root.doXstsAuthentication_xmlhttp.setRequestHeader('Content-Type', 'application/json');
			root.doXstsAuthentication_xmlhttp.setRequestHeader('Origin', 'https://www.xbox.com');
			root.doXstsAuthentication_xmlhttp.setRequestHeader('Referer', 'https://www.xbox.com');
			if (settingsData.preferredforceIp !== "") { root.doXstsAuthentication_xmlhttp.setRequestHeader('X-Forwarded-For', settingsData.preferredforceIp); }

		var properties = Object();
			properties.AuthMethod = 'RPS';
			properties.RpsTicket = 'd=' + settingsData.userToken["access_token"];
			properties.SiteName = 'user.auth.xboxlive.com';
		var payload = Object();
			payload.Properties = properties;
			payload.RelyingParty = 'http://auth.xboxlive.com';
			payload.TokenType = 'JWT';

		root.doXstsAuthentication_xmlhttp.responseType = "json";
		root.doXstsAuthentication_xmlhttp.send(JSON.stringify(payload));
	}


	function getWebToken() {
		root.getWebToken_xmlhttp.abort();						// cancel old call if any
		root.getWebToken_xmlhttp = new XMLHttpRequest();		// clear old data

		var url = "https://xsts.auth.xboxlive.com/xsts/authorize";

		// when responce received then do the following script:
		root.getWebToken_xmlhttp.onload = function() {

			// Error Handler
			let reply;
			try { reply = root.getWebToken_xmlhttp.response; }
			catch (exception) { console.log("error occured on getWebToken_xmlhttp:", exception); return; }

			if (reply["error"]) {
				// if (reply["error"] === "authorization_pending")			{ }		// do nothing, timer will check again
				// else if (reply["error"] === "authorization_declined")	{ doPollForDeviceCodeAuthTimer.stop(); doDeviceCodeAuth(); }	// user rejected, start over
				// else if (reply["error"] === "bad_verification_code")	{ doPollForDeviceCodeAuthTimer.stop(); doDeviceCodeAuth(); }	// bad device_code, start over
				// else if (reply["error"] === "expired_token")			{ doPollForDeviceCodeAuthTimer.stop(); doDeviceCodeAuth(); }	// token expired, start over
				// else if (reply["error"] === "invalid_grant")			{ doPollForDeviceCodeAuthTimer.stop(); }	// process finished // TODO: check if process is finished
				console.log("unexpected error in getWebToken_xmlhttp():", JSON.stringify(reply));
			}
			else {
				var tempObject = new Object;
				tempObject["token"] = reply["Token"];
				tempObject["expires_in"] = funcAPI.parseIsoUtcToDate(reply["NotAfter"]);
				tempObject["DisplayClaims"] = reply["DisplayClaims"];
				settingsData.webToken = tempObject;
				assignloginToken("webToken", true);

				settingsData.xid = reply["DisplayClaims"]["xui"][0]["xid"];
			}
		}

		root.getWebToken_xmlhttp.open("POST", url, true);
			root.getWebToken_xmlhttp.setRequestHeader('x-xbl-contract-version', '1');
			root.getWebToken_xmlhttp.setRequestHeader('Cache-Control', 'no-cache');
			root.getWebToken_xmlhttp.setRequestHeader('Content-Type', 'application/json');
			root.getWebToken_xmlhttp.setRequestHeader('Origin', 'https://www.xbox.com');
			root.getWebToken_xmlhttp.setRequestHeader('Referer', 'https://www.xbox.com');
			root.getWebToken_xmlhttp.setRequestHeader('Accept', '*/*');
			root.getWebToken_xmlhttp.setRequestHeader('ms-cv', '0');
			root.getWebToken_xmlhttp.setRequestHeader('User-Agent', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36');
			if (settingsData.preferredforceIp !== "") { root.getWebToken_xmlhttp.setRequestHeader('X-Forwarded-For', settingsData.preferredforceIp); }

		var properties = Object();
			properties.SandboxId = 'RETAIL';
			properties.UserTokens = [settingsData.xstsToken["token"]];
		var payload = Object();
			payload.Properties = properties;
			payload.RelyingParty = 'http://xboxlive.com';
			payload.TokenType = 'JWT';

		root.getWebToken_xmlhttp.responseType = "json";
		root.getWebToken_xmlhttp.send(JSON.stringify(payload));
	}
	function getGssvToken() {
		root.getGssvToken_xmlhttp.abort();						// cancel old call if any
		root.getGssvToken_xmlhttp = new XMLHttpRequest();		// clear old data

		var url = "https://xsts.auth.xboxlive.com/xsts/authorize";

		// when responce received then do the following script:
		root.getGssvToken_xmlhttp.onload = function() {

			// Error Handler
			let reply;
			try { reply = root.getGssvToken_xmlhttp.response; }
			catch (exception) { console.log("error occured on getGssvToken_xmlhttp:", exception); return; }

			if (reply["error"]) {
				// if (reply["error"] === "authorization_pending")			{ }		// do nothing, timer will check again
				// else if (reply["error"] === "authorization_declined")	{ doPollForDeviceCodeAuthTimer.stop(); doDeviceCodeAuth(); }	// user rejected, start over
				// else if (reply["error"] === "bad_verification_code")	{ doPollForDeviceCodeAuthTimer.stop(); doDeviceCodeAuth(); }	// bad device_code, start over
				// else if (reply["error"] === "expired_token")			{ doPollForDeviceCodeAuthTimer.stop(); doDeviceCodeAuth(); }	// token expired, start over
				// else if (reply["error"] === "invalid_grant")			{ doPollForDeviceCodeAuthTimer.stop(); }	// process finished // TODO: check if process is finished
				console.log("unexpected error in getGssvToken_xmlhttp():", JSON.stringify(reply));
			}
			else {
				var tempObject = new Object;
				tempObject["token"] = reply["Token"];
				tempObject["expires_in"] = funcAPI.parseIsoUtcToDate(reply["NotAfter"]);
				tempObject["DisplayClaims"] = reply["DisplayClaims"];
				settingsData.gssvToken = tempObject;
				assignloginToken("gssvToken", true);

				getXhomeToken();
				getXcloudToken();
			}
		}

		root.getGssvToken_xmlhttp.open("POST", url, true);
			root.getGssvToken_xmlhttp.setRequestHeader('x-xbl-contract-version', '1');
			root.getGssvToken_xmlhttp.setRequestHeader('Cache-Control', 'no-cache');
			root.getGssvToken_xmlhttp.setRequestHeader('Content-Type', 'application/json');
			root.getGssvToken_xmlhttp.setRequestHeader('Origin', 'https://www.xbox.com');
			root.getGssvToken_xmlhttp.setRequestHeader('Referer', 'https://www.xbox.com');
			root.getGssvToken_xmlhttp.setRequestHeader('Accept', '*/*');
			root.getGssvToken_xmlhttp.setRequestHeader('ms-cv', '0');
			root.getGssvToken_xmlhttp.setRequestHeader('User-Agent', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36');
			if (settingsData.preferredforceIp !== "") { root.getGssvToken_xmlhttp.setRequestHeader('X-Forwarded-For', settingsData.preferredforceIp); }

		var properties = Object();
			properties.SandboxId = 'RETAIL';
			properties.UserTokens = [settingsData.xstsToken["token"]];
		var payload = Object();
			payload.Properties = properties;
			payload.RelyingParty = 'http://gssv.xboxlive.com/';
			payload.TokenType = 'JWT';

		root.getGssvToken_xmlhttp.responseType = "json";
		root.getGssvToken_xmlhttp.send(JSON.stringify(payload));
	}



	function getXhomeToken() {
		root.getXhomeToken_xmlhttp.abort();						// cancel old call if any
		root.getXhomeToken_xmlhttp = new XMLHttpRequest();		// clear old data

		var url = "https://xhome.gssv-play-prod.xboxlive.com/v2/login/user";

		// when responce received then do the following script:
		root.getXhomeToken_xmlhttp.onload = function() {

			// Error Handler
			let reply;
			try { reply = root.getXhomeToken_xmlhttp.response; }
			catch (exception) { console.log("error occured on getXhomeToken_xmlhttp:", exception); return; }

			if (reply["error"]) {
				// if (reply["error"] === "authorization_pending")			{ }		// do nothing, timer will check again
				// else if (reply["error"] === "authorization_declined")	{ doPollForDeviceCodeAuthTimer.stop(); doDeviceCodeAuth(); }	// user rejected, start over
				// else if (reply["error"] === "bad_verification_code")	{ doPollForDeviceCodeAuthTimer.stop(); doDeviceCodeAuth(); }	// bad device_code, start over
				// else if (reply["error"] === "expired_token")			{ doPollForDeviceCodeAuthTimer.stop(); doDeviceCodeAuth(); }	// token expired, start over
				// else if (reply["error"] === "invalid_grant")			{ doPollForDeviceCodeAuthTimer.stop(); }	// process finished // TODO: check if process is finished
				console.log("unexpected error in getXhomeToken_xmlhttp():", JSON.stringify(reply));
			}
			else {
				var tempObject = new Object;
				tempObject["tokenType"] = reply["tokenType"];
				tempObject["gsToken"] = reply["gsToken"];
				tempObject["market"] = reply["market"];
				tempObject["expires_in"] = new Date(Date.now() + reply["durationInSeconds"] * 1000);
				tempObject["offeringSettings"] = reply["offeringSettings"];
				settingsData.xhomeToken = tempObject;
				assignloginToken("xhomeToken", true);
			}
		}

		root.getXhomeToken_xmlhttp.open("POST", url, true);
			root.getXhomeToken_xmlhttp.setRequestHeader('x-gssv-client', 'XboxComBrowser');
			root.getXhomeToken_xmlhttp.setRequestHeader('Cache-Control', 'no-store, must-revalidate, no-cache');
			root.getXhomeToken_xmlhttp.setRequestHeader('Content-Type', 'application/json');
			if (settingsData.preferredforceIp !== "") { root.getXhomeToken_xmlhttp.setRequestHeader('X-Forwarded-For', settingsData.preferredforceIp); }

		var payload = Object();
			payload.token = settingsData.gssvToken["token"];
			payload.offeringId = 'xhome';

		root.getXhomeToken_xmlhttp.responseType = "json";
		root.getXhomeToken_xmlhttp.send(JSON.stringify(payload));
	}
	function getXcloudToken() {
		root.getXcloudToken_xmlhttp.abort();						// cancel old call if any
		root.getXcloudToken_xmlhttp = new XMLHttpRequest();		// clear old data

		var url = "https://xgpuweb.gssv-play-prod.xboxlive.com/v2/login/user";

		// when responce received then do the following script:
		root.getXcloudToken_xmlhttp.onload = function() {

			// Error Handler
			let reply;
			try { reply = root.getXcloudToken_xmlhttp.response; }
			catch (exception) { console.log("error occured on getXcloudToken_xmlhttp:", exception); return; }

			if (reply["code"]) {
				// {"code":"InvalidCountry","statusCode":403,"message":""}
				// if (reply["error"] === "authorization_pending")			{ }		// do nothing, timer will check again
				// else if (reply["error"] === "authorization_declined")	{ doPollForDeviceCodeAuthTimer.stop(); doDeviceCodeAuth(); }	// user rejected, start over
				// else if (reply["error"] === "bad_verification_code")	{ doPollForDeviceCodeAuthTimer.stop(); doDeviceCodeAuth(); }	// bad device_code, start over
				// else if (reply["error"] === "expired_token")			{ doPollForDeviceCodeAuthTimer.stop(); doDeviceCodeAuth(); }	// token expired, start over
				// else if (reply["error"] === "invalid_grant")			{ doPollForDeviceCodeAuthTimer.stop(); }	// process finished // TODO: check if process is finished
				console.log("unexpected error in getXcloudToken_xmlhttp():", JSON.stringify(reply));
			}
			else {
				var tempObject = new Object;
				tempObject["tokenType"] = reply["tokenType"];
				tempObject["gsToken"] = reply["gsToken"];
				tempObject["market"] = reply["market"];
				tempObject["expires_in"] = new Date(Date.now() + reply["durationInSeconds"] * 1000);
				tempObject["offeringSettings"] = reply["offeringSettings"];
				settingsData.xcloudToken = tempObject;
				assignloginToken("xcloudToken", true);
			}
		}

		root.getXcloudToken_xmlhttp.open("POST", url, true);
			root.getXcloudToken_xmlhttp.setRequestHeader('x-gssv-client', 'XboxComBrowser');
			root.getXcloudToken_xmlhttp.setRequestHeader('Cache-Control', 'no-store, must-revalidate, no-cache');
			root.getXcloudToken_xmlhttp.setRequestHeader('Content-Type', 'application/json');
			if (settingsData.preferredforceIp !== "") { root.getXcloudToken_xmlhttp.setRequestHeader('X-Forwarded-For', settingsData.preferredforceIp); }

		var payload = Object();
			payload.token = settingsData.gssvToken["token"];
			payload.offeringId = 'xgpuweb';

		root.getXcloudToken_xmlhttp.responseType = "json";
		root.getXcloudToken_xmlhttp.send(JSON.stringify(payload));
	}
}
