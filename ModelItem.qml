import QtQuick
import GameListModelFull
import GameListModelFiltered

Item {
	id: modelItem

	// Size Variables - initial screen size used to program all sizes
	property real baseWidth: 1000
	property real baseHeight: 640

	property real screenWidth: baseWidth
	property real screenHeight: baseHeight

	property int popupTimer: 3000
	property int inputAnimation: 250
	property int colorChangeAnimation: 100

	property var scale: {
		// TEXT
		"H1": screenWidth * (28 / baseWidth),
		"H2": screenWidth * (22 / baseWidth),
		"P1": screenWidth * (16 / baseWidth),
		"C1": screenWidth * (13 / baseWidth),

		// LINE HEIGHT
		"H1/Line": screenWidth * (38 / baseWidth),
		"H2/Line": screenWidth * (33 / baseWidth),
		"P1/Line": screenWidth * (26 / baseWidth),
		"C1/Line": screenWidth * (20 / baseWidth),

		// OTHERS
		"BORDER": screenWidth * (1 / baseWidth),
		"LINE": screenWidth * (2 / baseWidth),
		"PADDING": screenWidth * (10 / baseWidth),
		"MARGIN": screenWidth * (20 / baseWidth),
		"RADIUS": screenWidth * (5 / baseWidth),
		"SPACING": screenWidth * (5 / baseWidth)
	}

	property var theme: {
																				// LIGHT		// DARK
		"Background/Left":						settingsData.user_mode === 0 ?	"#000F0C" :		"#000F0C",
		"Background/Main":						settingsData.user_mode === 0 ?	"#1A1A1A" :		"#1A1A1A",
		"Background/Form/Active":				settingsData.user_mode === 0 ?	"#07659C" :		"#07659C",
		"Background/Form/Inactive":				settingsData.user_mode === 0 ?	"#20364C" :		"#20364C",

		"Background/Gradient/Stop1":			settingsData.user_mode === 0 ?	"#033518" :		"#033518",
		"Background/Gradient/Stop2":			settingsData.user_mode === 0 ?	"#002610" :		"#002610",
		"Background/Gradient/Stop3":			settingsData.user_mode === 0 ?	"#011C0E" :		"#011C0E",

		"Outline/Main":							settingsData.user_mode === 0 ?	"#2A403A" :		"#2A403A",
		"Outline/Form/Active":					settingsData.user_mode === 0 ?	"#2A403A" :		"#2A403A",
		"Outline/Form/Inactive":				settingsData.user_mode === 0 ?	"#2A403A" :		"#2A403A",

		"Text/Standard":						settingsData.user_mode === 0 ?	"#FDFDF1" :		"#FDFDF1",
		"Text/Link":							settingsData.user_mode === 0 ?	"#7BB5F5" :		"#7BB5F5",
		"Text/Hint":							settingsData.user_mode === 0 ?	"#BBBBBB" :		"#BBBBBB"
	}


	property var subscriptions: {
		"Ultimate": "cfq7ttc0khs0",
		"Premium": "cfq7ttc0p85b",
		"Essential": "cfq7ttc0k5dj",
		//"Console": "cfq7ttc0k6l8",
		//"PC": "cfq7ttc0kgq8",
	}
	property var platforms: {
		"All": "cfq7ttc0kgq8",
		"Console": "cfq7ttc0k6l8",
		"PC": "cfq7ttc0k5dj",
		"Xbox One": "cfq7ttc0p85b",
		"Xbox Series": "cfq7ttc0khs0",
	}

	// https://www.xbox.com/en-MY/xbox-game-pass/games/js/xgpcatPopulate-MWF2.js

	// all: f6f1f99f-9b49-4ccd-b3bf-4d9767a77f5e (all games regardless xcloud?)
	// xcloud: 29a81209-df6f-41fd-a528-2ae6b91f719c
	// new: f13cf6b4-57e6-4459-89df-6aec18cf0538
	// coming soon: 095bda36--9ee1-0a72f371fb96
	// leaving soon: 393f05bf-e596-4ef6-9487-6d4fa0eab987
	// ea-play: b8900d09-a491-44cc-916e-32b5acae621b
	// without controller: 7d8e8d56-c02f-4711-afec-73a80d8e9261
	// ubisoft: aed03b50-b954-4ee4-a426-fe1686b64f85

	property var sigls: {
		"allgames": { // (ultimate)
			"Console": "97c6c862-d28a-4907-a3d5-c401f2296a53",	// Console, Ultimate
			"PC": "97c6c862-d28a-4907-a3d5-c401f2296a53"		// PC, Ultimate
		},
		"allgamespremium": {
			"Console": "09a72c0d-c466-426a-9580-b78955d8173a",	// Console, Premium
			"PC": "09a72c0d-c466-426a-9580-b78955d8173a"		// PC, Premium
		},
		"allgamesessential": {
			"Console": "34031711-5a70-4196-bab7-45757dc2294e",	// Console, Essential
			"PC": "34031711-5a70-4196-bab7-45757dc2294e"		// PC, Essential
		},
		"allgamesconsole": {
			"Console": "f6f1f99f-9b49-4ccd-b3bf-4d9767a77f5e",	// Console, Console
			"PC": "609d944c-d395-4c0a-9ea4-e9f39b52c1ad"		// PC, Console
		},
		"allgamespc": {
			"Console": "f6f1f99f-9b49-4ccd-b3bf-4d9767a77f5e",	// Console, PC
			"PC": "609d944c-d395-4c0a-9ea4-e9f39b52c1ad"		// PC, PC
		},
		"allgamesxboxseries": {
			"Console": "f6f1f99f-9b49-4ccd-b3bf-4d9767a77f5e",	// Xbox Series, Ultimate
			"PC": "609d944c-d395-4c0a-9ea4-e9f39b52c1ad"		// Xbox Series, Ultimate
		},
		"allgamesxboxone": {
			"Console": "f6f1f99f-9b49-4ccd-b3bf-4d9767a77f5e",	// Xbox One, Ultimate
			"PC": "609d944c-d395-4c0a-9ea4-e9f39b52c1ad"		// Xbox One, Ultimate
		},
		"actionadventure": {
			"Console": "fafb048d-9850-4447-ae20-f8f698bd208a",	// Console, Ultimate
			"PC": "3b2da8c2-a0b0-49d5-aab9-f0ac40beb43d"		// PC, Ultimate
		},
		"activision": {
			"Console": "5ed00131-8bb8-4812-9410-eebb5d97980e",	// Console, Ultimate
			"PC": "751114ed-31cf-4cb5-9f62-4c3c907da263"		// PC, Ultimate
		},
		"bethesdasoftworks": {
			"Console": "f6505a9f-ec7d-4eb8-a496-be83f8f35829",	// Console, Ultimate
			"PC": "79fe89cf-f6a3-48d4-af6c-de4482cf4a51"		// PC, Ultimate
		},
		"blizzardentertainment": {
			"Console": "27c792f1-d663-4090-a3b2-9c2f4c0f887a",	// Console, Ultimate
			"PC": "7bf43e74-445d-4100-a0f1-f571a43310c4"		// PC, Ultimate
		},
		"classics": {
			"Console": "42d41e76-a5fd-4344-ae4e-05ce2f5925cd",	// Console, Ultimate
			"PC": "0f92d4e4-33da-4832-aa26-09837624145d"		// PC, Ultimate
		},
		"cloud": {
			"Console": "29a81209-df6f-41fd-a528-2ae6b91f719c",	// Console, Ultimate
			"PC": "29a81209-df6f-41fd-a528-2ae6b91f719c"		// PC, Ultimate
		},
		"comingsoon": {
			"Console": "095bda36-f5cd-43f2-9ee1-0a72f371fb96",	// Console, Ultimate
			"PC": "4165f752-d702-49c8-886b-fb57936f6bae"		// PC, Ultimate
		},
		"comingsoonpremium": {
			"Console": "f7534504-9c98-45aa-b8e9-95670783bc03",	// Console, Premium
			"PC": "f7534504-9c98-45aa-b8e9-95670783bc03"		// PC, Premium
		},
		"eaplay": {
			"Console": "b8900d09-a491-44cc-916e-32b5acae621b",	// Console, Ultimate
			"PC": "1d33fbb9-b895-4732-a8ca-a55c8b99fa2c"		// PC, Ultimate
		},
		"eaplaygametrials": {
			"Console": "490f4b6e-a107-4d6a-8398-225ee916e1f2",	// Console, Ultimate
			"PC": "19e5b90a-5a20-4b1d-9dda-6441ca632527"		// PC, Ultimate
		},
		"familykids": {
			"Console": "8e7cd765-1293-44e0-95bb-8257e2bf0221",	// Console, Ultimate
			"PC": "0f0bccc0-cdc8-4e1a-bfca-4b7da5c6c418"		// PC, Ultimate
		},
		"ingamebenefits": {
			"Console": "f4e1445f-89fb-42ca-ab12-bc06039d9927",	// Console, Ultimate
			"PC": "3a6b073e-9719-4071-b7a3-6d836f5d949e"		// PC, Ultimate
		},
		"idxbox": {
			"Console": "fc40d1b9-85ec-422d-b454-8685fb31776e",	// Console, Ultimate
			"PC": "4c894453-744d-4b35-acea-40df9f4312b1"		// PC, Ultimate
		},
		"indie": {
			"Console": "2e8e2cdf-f1bb-4e7e-8295-04949a26f6cc",	// Console, Ultimate
			"PC": "1e2ce757-e84f-4d2c-9243-34b81912644a"		// PC, Ultimate
		},
		"leavingsoon": {
			"Console": "393f05bf-e596-4ef6-9487-6d4fa0eab987",	// Console, Ultimate
			"PC": "cc7fc951-d00f-410e-9e02-5e4628e04163"		// PC, PC
		},
		"mostpopular": {
			"Console": "eab7757c-ff70-45af-bfa6-79d3cfb2bf81",	// Console, Ultimate
			"PC": "a884932a-f02b-40c8-a903-a008c23b1df1"		// PC, Ultimate
		},
		"platformer": {
			"Console": "5dfd8fdd-2fd3-4e7f-b9f8-175e96b1adac",	// Console, Ultimate
			"PC": "7dff3157-a037-4449-85db-8086d51ec4f8"		// PC, Ultimate
		},
		"playdayone": {
			"Console": "a672552e-fdc2-4ecd-96e9-b8409193f524",	// Console, Ultimate
			"PC": "4b59700c-801f-494a-a34c-842b8c98f154"		// PC, Ultimate
		},
		"puzzletrivia": {
			"Console": "62ba1846-03bb-4209-aeea-35110a9935f1",	// Console, Ultimate
			"PC": "39d48297-93f9-4b5a-85dd-641a337b212c"		// PC, Ultimate
		},
		"racingflying": {
			"Console": "6d18c7d7-7f62-4c87-b1b7-b5555c5752d0",	// Console, Ultimate
			"PC": "0767da77-95d4-4023-9971-d1a9756fccef"		// PC, Ultimate
		},
		"recentlyadded": {
			"Console": "06323672-b8c8-43cc-b0de-32d5a9834749",	// Console, Ultimate	//f13cf6b4-57e6-4459-89df-6aec18cf0538
			"PC": "06323672-b8c8-43cc-b0de-32d5a9834749"		// PC, Ultimate
		},
		"recentlyaddedpremium": {
			"Console": "06323672-b8c8-43cc-b0de-32d5a9834749",	// Console, Premium
			"PC": "06323672-b8c8-43cc-b0de-32d5a9834749"		// PC, Premium
		},
		"recentlyaddedessential": {		// essential
			"Console": "6057a765-eab8-44b4-b421-93b6f14377aa",	// Console, Essential
			"PC": "6057a765-eab8-44b4-b421-93b6f14377aa"		// PC, Essential
		},
		"recentlyaddedconsole": {
			"Console": "06323672-b8c8-43cc-b0de-32d5a9834749",	// Console, Console
			"PC": "06323672-b8c8-43cc-b0de-32d5a9834749"		// PC, Console
		},
		"riotgames": {
			"Console": "4e641124-9279-46a5-a73f-4e20d89c787c",	// Console, Ultimate
			"PC": "4e641124-9279-46a5-a73f-4e20d89c787c"		// PC, Ultimate
		},
		"roleplaying": {
			"Console": "18e0b0af-cefe-4492-845c-b9f6ab8737f8",	// Console, Ultimate
			"PC": "c621daed-3d22-4745-afc9-19ed77a2e9be"		// PC, Ultimate
		},
		"shooter": {
			"Console": "bd8e0e95-78d1-42fd-aee2-291210df273d",	// Console, Ultimate
			"PC": "15d529d7-0b6b-431f-a0fe-fa01d6a6e9c6"		// PC, Ultimate
		},
		"simulation": {
			"Console": "3950236c-9aa7-433d-88fd-96023d276346",	// Console, Ultimate
			"PC": "f0e9ffe0-176e-41af-be11-c40a05d26e2c"		// PC, Ultimate
		},
		"sports": {
			"Console": "796c328b-4a17-4996-99f8-0edb59bef85a",	// Console, Ultimate
			"PC": "6661f37d-6159-4c9c-81d8-668af0a78b04"		// PC, Ultimate
		},
		"strategy": {
			"Console": "25d0b8d5-1a6a-489f-8195-219c96656497",	// Console, Ultimate
			"PC": "9fd6a075-57c3-4084-82d0-b00e2d43424a"		// PC, Ultimate
		},
		"ubisoftclassics": {
			"Console": "66ec875c-a391-44f5-9a54-a28bd6f976ce",	// Console, Ultimate
			"PC": "66ec875c-a391-44f5-9a54-a28bd6f976ce"		// PC, Ultimate
		},
		"ubisoftconnect": {
			"Console": "a5a535fb-d926-4141-9ce4-9f6af8ca22e7",	// Console, Ultimate
			"PC": "9c09d734-1c45-4740-ae7f-fd73ff629880"		// PC, Ultimate
		},
		"xboxgamestudios": {
			"Console": "989188eb-1532-4907-8a94-2ac18bcb0f59",	// Console, Ultimate
			"PC": "691152f2-b3af-49ae-84ac-f98de8b26f61"		// PC, Ultimate
		}

		// ubisoft aed03b50-b954-4ee4-a426-fe1686b64f85
	};


	property ListModel menuModel: ListModel {
		id: menuModel
		ListElement { code: "userSessionGames";			name: "Jump back";				icon: "emoji_returnarrow.svg";				loaded: false }
		ListElement { code: "allGames";					name: "All Games";				icon: "icon_whitecontroller.png";			loaded: false }
		ListElement { code: "favoriteGames";			name: "Favorites";				icon: "emoji_heart.svg";					loaded: false }
		ListElement { code: "newGames";					name: "New Games";				icon: "emoji_smallstars.svg";				loaded: false }
		ListElement { code: "dealGames";				name: "On Sale";				icon: "emoji_moneywings.svg";				loaded: false }
		ListElement { code: "bestRatedGames";			name: "Best Rated";				icon: "emoji_star.svg";						loaded: false }
		ListElement { code: "comingSoonGames";			name: "Coming Soon";			icon: "emoji_sandclock.svg";				loaded: false }
		ListElement { code: "topFreeGames";				name: "Top Free";				icon: "emoji_present.svg";					loaded: false }
		ListElement { code: "mostPlayedGames";			name: "Most Played";			icon: "emoji_fire.svg";						loaded: false }
		ListElement { code: "previewGames";				name: "Previews";				icon: "emoji_nametag.svg";					loaded: false }
		ListElement { code: "mouseAndKeyboardGames";	name: "Keyboard";				icon: "icon_mouse.png";						loaded: false }
	}


	property QtObject userOwnData: QtObject {
		id: userOwnData
		property string xid: settingsData.xid
		property bool isSponsoredUser: false
		property var settings: []
	}

	property ListModel categoryList: ListModel {
		id: categoryList
		objectName: "categoryList"
		property bool loaded: false

		function provideSelectedCategories() {
			var tempArray = [];
			for (var i=0; i<count; i++) {
				if (get(i).selected) { tempArray.push(get(i).categoryName); }
			}
			filteredGameList.setSelectedCategories(tempArray);
		}

		function reset() {
			for (var i=0; i<count; i++) { setProperty(i, "selected", true); }
			categoryList.provideSelectedCategories();
		}
	}

	property ListModel sortFieldList: ListModel {
		id: sortFieldList
		ListElement { code: "productTitle";		name: "Title" }
		ListElement { code: "reviewScore";		name: "Rating" }
		ListElement { code: "regularPrice";		name: "Price" }		// salePrice?
		ListElement { code: "discount";			name: "Discount" }
		ListElement { code: "lastTimePlayed";	name: "Last Played" }
	}

	// TODO:
	property bool fullyLoaded: categoryList.loaded === true && fullGameList.titleListSimpleFinished === true
	onFullyLoadedChanged: {
		if (fullyLoaded === true) { filteredGameList.refreshAsync(); }
	}


	property GameListModelFull fullGameList: GameListModelFull {
		id: fullGameList

		// onDataChanged: {
		// 	console.log("dataChanged() signal received");
		// 	var found = false;
		// 	for (var i=0; i<rowCount(); i++) {

		// 		var idx = fullGameList.index(i, 0)
		// 		if (fullGameList.data(idx, GameListModelFull.StoreIdRole) === "9PCR3Z2MSM4T") {
		// 			console.log(i, fullGameList.data(idx, GameListModelFull.StoreIdRole), fullGameList.data(idx, GameListModelFull.ProductTitleRole))
		// 			found = true;
		// 		}
		// 	}
		// 	if (!found) { console.log("9PCR3Z2MSM4T (Hades II) not found"); }
		// }

		onCategoriesChanged: {
			categoryList.clear();
			for (var i=0; i<categories.length; i++) {
				categoryList.append(categories[i])
			}
			categoryList.provideSelectedCategories();
			categoryList.loaded = true;
		}


		// property bool titleListSimpleFinished
		onTitleListSimpleFinishedChanged: {
			var codes = ["userSessionGames","allGames","favoriteGames","comingSoonGames","mostPlayedGames","previewGames"];
			for (var i=0; i<modelItem.menuModel.count; i++) { if (codes.includes(modelItem.menuModel.get(i).code)) { modelItem.menuModel.setProperty(i, "loaded", titleListSimpleFinished); } }
		}

		// property bool titleListModerateFinished
		onTitleListModerateFinishedChanged: {
			var codes = ["mouseAndKeyboardGames"];
			for (var i=0; i<modelItem.menuModel.count; i++) { if (codes.includes(modelItem.menuModel.get(i).code)) { modelItem.menuModel.setProperty(i, "loaded", titleListModerateFinished); } }
		}

		// property bool titleListComplexFinished
		onTitleListComplexFinishedChanged: {
			var codes = ["newGames","dealGames","bestRatedGames","topFreeGames"];
			for (var i=0; i<modelItem.menuModel.count; i++) { if (codes.includes(modelItem.menuModel.get(i).code)) { modelItem.menuModel.setProperty(i, "loaded", titleListComplexFinished); } }
		}
	}

	property GameListModelFiltered filteredGameList: GameListModelFiltered {
		id: filteredGameList
		dynamicSortFilter: false
		sourceModel: fullGameList

		// property string code: "allGames"
		sortingField: "productTitle"
		// property int orderType: Qt.AscendingOrder
		// property string queryString: ""

		onAvailableCategoriesChanged: {
			for (var i=0; i<categoryList.count; i++) {
				if (availableCategories.includes(categoryList.get(i).categoryName)) { categoryList.setProperty(i, "available", true); }
				else {
					categoryList.setProperty(i, "available", false);
					// TODO: set selected to true?
					// TODO: if new item inside availableCategories appears? then add it:
				}
			}
		}
	}
}
