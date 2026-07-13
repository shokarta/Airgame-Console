import QtQml

QtObject {
	id: titleAPI


	// probably only one list "PINS" exist which might be the games i make star/favourite?
	function getEpList() {
		root.getEpList_xmlhttp.abort();						// cancel old call if any
		root.getEpList_xmlhttp = new XMLHttpRequest();		// clear old data

		var url = "https://eplists.xboxlive.com/users/xuid("+settingsData.xid+")/lists/PINS/PINS";

		// when responce received then do the following script:
		root.getEpList_xmlhttp.onload = function() {
console.log(root.getEpList_xmlhttp.responseText);
			// Error Handler
			let reply;
			try { reply = root.getEpList_xmlhttp.response; }
			catch (exception) { console.log("error occured on getEpList_xmlhttp:", exception); return; }

			if (reply["error"]) {
				if (reply["error"] === "invalid_grant")	{}
				else { console.log("unexpected error in getEpList():", JSON.stringify(reply)); }
			}
			else {
				// do nothing, currently not working with Lists
			}
		}

		root.getEpList_xmlhttp.open("GET", url, true);
			root.getEpList_xmlhttp.setRequestHeader('Authorization', 'XBL3.0 x=' + settingsData.webToken["DisplayClaims"]["xui"][0]["uhs"] + ';' + settingsData.webToken["token"]);
			//root.getEpList_xmlhttp.setRequestHeader('Content-Type', 'application/json');
			//root.getEpList_xmlhttp.setRequestHeader('Accept-Language', 'en-US');
			root.getEpList_xmlhttp.setRequestHeader('x-xbl-contract-version', '2');
			//root.getEpList_xmlhttp.setRequestHeader('x-xbl-client-name', 'XboxApp');
			//root.getEpList_xmlhttp.setRequestHeader('x-xbl-client-type', 'UWA');
			//root.getEpList_xmlhttp.setRequestHeader('x-xbl-client-version', '39.39.22001.0');
			if (settingsData.preferredforceIp !== "") { root.getEpList_xmlhttp.setRequestHeader('X-Forwarded-For', settingsData.preferredforceIp); }

		root.getEpList_xmlhttp.responseType = "json";
		root.getEpList_xmlhttp.send();
	}

	function getEpList_add() {
		root.getEpList_add_xmlhttp.abort();						// cancel old call if any
		root.getEpList_add_xmlhttp = new XMLHttpRequest();		// clear old data

		var url = "https://eplists.xboxlive.com/users/xuid("+settingsData.xid+")/lists/PINS/PINS";

		// when responce received then do the following script:
		root.getEpList_add_xmlhttp.onload = function() {
console.log(root.getEpList_add_xmlhttp.responseText);
			// Error Handler
			let reply;
			try { reply = root.getEpList_add_xmlhttp.response; }
			catch (exception) { console.log("error occured on getEpList_add_xmlhttp:", exception); return; }

			if (reply["error"]) {
				if (reply["error"] === "invalid_grant")	{}
				else { console.log("unexpected error in getEpList_add():", JSON.stringify(reply)); }
			}
			else {
				// do nothing, currently not working with Lists
			}
		}

		var params = Object();
			params.items = [{"itemId":"C261457LCNMJ","type": "StoreId"}];

		root.getEpList_add_xmlhttp.open("POST", url, true);
			root.getEpList_add_xmlhttp.setRequestHeader('Authorization', 'XBL3.0 x=' + settingsData.webToken["DisplayClaims"]["xui"][0]["uhs"] + ';' + settingsData.webToken["token"]);
			//root.getEpList_add_xmlhttp.setRequestHeader('Content-Type', 'application/json');
			//root.getEpList_add_xmlhttp.setRequestHeader('Accept-Language', 'en-US');
			root.getEpList_add_xmlhttp.setRequestHeader('x-xbl-contract-version', '2');
			//root.getEpList_add_xmlhttp.setRequestHeader('x-xbl-client-name', 'XboxApp');
			//root.getEpList_add_xmlhttp.setRequestHeader('x-xbl-client-type', 'UWA');
			//root.getEpList_add_xmlhttp.setRequestHeader('x-xbl-client-version', '39.39.22001.0');
			if (settingsData.preferredforceIp !== "") { root.getEpList_add_xmlhttp.setRequestHeader('X-Forwarded-For', settingsData.preferredforceIp); }

		root.getEpList_add_xmlhttp.responseType = "json";
		root.getEpList_add_xmlhttp.send(JSON.stringify(params));
	}

	function getEpList_remove() {
		root.getEpList_remove_xmlhttp.abort();						// cancel old call if any
		root.getEpList_remove_xmlhttp = new XMLHttpRequest();		// clear old data

		var url = "https://eplists.xboxlive.com/users/xuid("+settingsData.xid+")/lists/PINS/PINS";

		// when responce received then do the following script:
		root.getEpList_remove_xmlhttp.onload = function() {
console.log(root.getEpList_remove_xmlhttp.responseText);
			// Error Handler
			let reply;
			try { reply = root.getEpList_remove_xmlhttp.response; }
			catch (exception) { console.log("error occured on getEpList_remove_xmlhttp:", exception); return; }

			if (reply["error"]) {
				if (reply["error"] === "invalid_grant")	{}
				else { console.log("unexpected error in getEpList_remove():", JSON.stringify(reply)); }
			}
			else {
				// do nothing, currently not working with Lists
			}
		}

		var params = Object();
			params.items = [{"itemId":"BRKX5CRMRTC2","type": "StoreId"}];

		root.getEpList_remove_xmlhttp.open("DELETE", url, true);
			root.getEpList_remove_xmlhttp.setRequestHeader('Authorization', 'XBL3.0 x=' + settingsData.webToken["DisplayClaims"]["xui"][0]["uhs"] + ';' + settingsData.webToken["token"]);
			//root.getEpList_remove_xmlhttp.setRequestHeader('Content-Type', 'application/json');
			//root.getEpList_remove_xmlhttp.setRequestHeader('Accept-Language', 'en-US');
			root.getEpList_remove_xmlhttp.setRequestHeader('x-xbl-contract-version', '2');
			//root.getEpList_remove_xmlhttp.setRequestHeader('x-xbl-client-name', 'XboxApp');
			//root.getEpList_remove_xmlhttp.setRequestHeader('x-xbl-client-type', 'UWA');
			//root.getEpList_remove_xmlhttp.setRequestHeader('x-xbl-client-version', '39.39.22001.0');
			if (settingsData.preferredforceIp !== "") { root.getEpList_remove_xmlhttp.setRequestHeader('X-Forwarded-For', settingsData.preferredforceIp); }

		root.getEpList_remove_xmlhttp.responseType = "json";
		root.getEpList_remove_xmlhttp.send(JSON.stringify(params));
	}



	// function getGameList(categoryCode) {
	// 	root.getGameList_xmlhttp.abort();						// cancel old call if any
	// 	root.getGameList_xmlhttp = new XMLHttpRequest();		// clear old data

	// 	var url = "https://catalog.gamepass.com/sigls/v2?id=" + "f6f1f99f-9b49-4ccd-b3bf-4d9767a77f5e" + "&market=" + settingsData.preferredMarket + "&language=" + settingsData.preferredLanguage;		// for v3 is needed:+ "&platformContext=settingsData.platformId + "&subscriptionContext=settingsData.subscriptionId;
	// 	//var url = "https://catalog.gamepass.com/sigls/v2?id=" + "97c6c862-d28a-4907-a3d5-c401f2296a53" + "&market=" + settingsData.preferredMarket + "&language=" + settingsData.preferredLanguage;		// for v3 is needed:+ "&platformContext=settingsData.platformId + "&subscriptionContext=settingsData.subscriptionId;

	// 	// when responce received then do the following script:
	// 	root.getGameList_xmlhttp.onload = function() {

	// 		// Error Handler
	// 		let reply;
	// 		try { reply = root.getGameList_xmlhttp.response; }
	// 		catch (exception) { console.log("(2) error occured on getGameList_xmlhttp:", exception); return; }

	// 		if (reply["error"]) {
	// 			if (reply["error"] === "invalid_grant")	{}
	// 			else { console.log("unexpected error in getGameList():", JSON.stringify(reply)); }
	// 		}
	// 		else {
	// 			for (var i=0; i<reply.length; i++) {
	// 				if (reply[i]["id"]) { modelItem.fullGameList.append({ "storeId": reply[i]["id"], "visible": true }); }
	// 			}
	// 			root.updateGameList("simple");
	// 		}
	// 	}

	// 	root.getGameList_xmlhttp.open("GET", url, true);
	// 		if (settingsData.preferredforceIp !== "") { root.getGameList_xmlhttp.setRequestHeader('X-Forwarded-For', settingsData.preferredforceIp); }

	// 	root.getGameList_xmlhttp.responseType = "json";
	// 	root.getGameList_xmlhttp.send();

	// 	modelItem.fullGameList.clear();
	// }
	function getGameList() {
		root.getGameList_xmlhttp.abort();						// cancel old call if any
		root.getGameList_xmlhttp = new XMLHttpRequest();		// clear old data

		var url = settingsData.xcloudToken.offeringSettings.regions.find(region => region.isDefault === true).baseUri + "/v2/titles"

		// when responce received then do the following script:
		root.getGameList_xmlhttp.onload = function() {

			// Error Handler
			let reply;
			try { reply = root.getGameList_xmlhttp.response; }
			catch (exception) { console.log("(3) error occured on getGameList_xmlhttp:", exception); return; }

			if (reply["error"]) {
				if (reply["error"] === "invalid_grant")	{}
				else { console.log("unexpected error in getGameList():", JSON.stringify(reply)); }
			}
			else {
				for (var i=0; i<reply["results"].length; i++) {
					if (reply["results"][i]["details"]) { modelItem.fullGameList.append({
																							"storeId": reply["results"][i]["details"]["productId"],
																							"userPrograms": reply["results"][i]["details"]["userPrograms"],
																							"visible": true
																						});
					}
				}
				root.updateGameList("simple");
			}
		}

		root.getGameList_xmlhttp.open("GET", url, true);
			root.getGameList_xmlhttp.setRequestHeader('Authorization', 'Bearer ' + settingsData.xcloudToken["gsToken"]);
			root.getGameList_xmlhttp.setRequestHeader('Content-Type', 'application/json');
			if (settingsData.preferredforceIp !== "") { root.getGameList_xmlhttp.setRequestHeader('X-Forwarded-For', settingsData.preferredforceIp); }

		root.getGameList_xmlhttp.responseType = "json";
		root.getGameList_xmlhttp.send();

		modelItem.fullGameList.clear();
	}
}
