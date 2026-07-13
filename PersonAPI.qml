import QtQml

QtObject {
	id: personAPI


	function getOwnUserData() {
		root.getOwnUserData_xmlhttp.abort();						// cancel old call if any
		root.getOwnUserData_xmlhttp = new XMLHttpRequest();		// clear old data

		var url = "https://profile.xboxlive.com/users/batch/profile/settings";
		//var url = "https://profile.xboxlive.com/users/me/profile/settings?settings=GameDisplayName,AppDisplayName,AppDisplayPicRaw,GameDisplayPicRaw,PublicGamerpic,ShowUserAsAvatar,Gamerscore,Gamertag,AccountTier,TenureLevel,XboxOneRep,PreferredColor,Location,Bio,Watermarks,RealName,RealNameOverride";	// or GET like this (to "me" without XID POST parameter)

		// when responce received then do the following script:
		root.getOwnUserData_xmlhttp.onload = function() {

			// Error Handler
			let reply;
			try { reply = root.getOwnUserData_xmlhttp.response; }
			catch (exception) { console.log("error occured on getOwnUserData_xmlhttp:", exception); return; }

			if (reply["error"]) {
				if (reply["error"] === "invalid_grant")	{}
				else { console.log("unexpected error in refreshTokens():", JSON.stringify(reply)); }
			}
			else {
				modelItem.userOwnData.settings = [];		// clear data to trigger Changed for settings
				modelItem.userOwnData.settings =			reply["profileUsers"][0]["settings"];
				modelItem.userOwnData.isSponsoredUser =		reply["profileUsers"][0]["isSponsoredUser"];
			}
		}

		var params = Object();
			params.userIds = [settingsData.xid];
			params.settings = ["AccountTier","AppDisplayName","AppDisplayPicRaw","Bio","GameDisplayName","GameDisplayPicRaw","Gamerscore","Gamertag","Location","PreferredColor","PublicGamerpic","RealName","RealNameOverride","ShowUserAsAvatar","TenureLevel","Watermarks","XboxOneRep"];

		root.getOwnUserData_xmlhttp.open("POST", url, true);
			root.getOwnUserData_xmlhttp.setRequestHeader('Authorization', 'XBL3.0 x=' + settingsData.webToken["DisplayClaims"]["xui"][0]["uhs"] + ';' + settingsData.webToken["token"]);
			root.getOwnUserData_xmlhttp.setRequestHeader('Content-Type', 'application/json');
			//root.getOwnUserData_xmlhttp.setRequestHeader('Accept-Language', 'en-US');
			root.getOwnUserData_xmlhttp.setRequestHeader('x-xbl-contract-version', '2');
			//root.getOwnUserData_xmlhttp.setRequestHeader('x-xbl-client-name', 'XboxApp');
			//root.getOwnUserData_xmlhttp.setRequestHeader('x-xbl-client-type', 'UWA');
			//root.getOwnUserData_xmlhttp.setRequestHeader('x-xbl-client-version', '39.39.22001.0');
			if (settingsData.preferredforceIp !== "") { root.getOwnUserData_xmlhttp.setRequestHeader('X-Forwarded-For', settingsData.preferredforceIp); }

		root.getOwnUserData_xmlhttp.responseType = "json";
		root.getOwnUserData_xmlhttp.send(JSON.stringify(params));
	}
}
