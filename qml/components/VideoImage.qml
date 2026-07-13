import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia

Item {
	id: objMaster
	visible: (coverImage !== "" || source !== "") ? true : false

	property string coverImage: ""
	property string source: ""
	property bool autoplay: false

	property bool arrowLeftVisible: false
	property bool arrowRightVisible: false

	// Black Background
	Rectangle {
		anchors.centerIn: parent
		width: root.width
		height: root.height
		color: "black"
		opacity: 0.8
		visible: objMaster.visible
	}

	MediaPlayer {
		id: mediaPlayer
		source: objMaster.source
		audioOutput: audioOutput
		videoOutput: videoOutput
		onMediaStatusChanged: if (mediaStatus === MediaPlayer.BufferingMedia) {
								  if (playbackState === MediaPlayer.PlayingState && mediaStatus === MediaPlayer.BufferingMedia) {
									  mediaPlayer.pause();
									  bufferTimer.restart();
								  }
							  }
		autoPlay: objMaster.autoplay
	}
	AudioOutput {
		id: audioOutput
		volume: settingsData.videoVolume
		onVolumeChanged: (volume) => {
			if (muted && volume > 0) { muted = false; }
			if (!muted) { settingsData.videoVolume = audioOutput.volume; }
		}
	}
	VideoOutput {
		id: videoOutput
		width: objMaster.width
		height: mediaPlayer.playbackState !== MediaPlayer.StoppedState ? objMaster.height : 0
		fillMode: VideoOutput.PreserveAspectCrop
	}

	Timer {
		property int counter: 1

		id: bufferTimer
		interval: 50
		running: false
		repeat: false
		triggeredOnStart: false
		onTriggered: {
			if (mediaPlayer.mediaStatus === MediaPlayer.BufferingMedia) {
				if (bufferTimer.interval * bufferTimer.counter > 3000) {
					//console.log("video " + source + " is buffering longer then 3000ms... playing");
					bufferTimer.counter = 1;
					mediaPlayer.play();
				}
				else {
					//console.log("video " + source + " is buffering... waiting 50 ms");
					bufferTimer.counter++;
					bufferTimer.restart();
				}
			}
			else {
				//console.log("video " + source + " is no longer buffering");
				bufferTimer.counter = 1;
				mediaPlayer.play();
			}
		}
	}


	Image {
		id: coverPicture
		width: objMaster.width
		height: mediaPlayer.playbackState !== MediaPlayer.StoppedState ? 0 : parent.height
		sourceSize.width: width
		// sourceSize.height: height
		smooth: false
		fillMode: Image.PreserveAspectCrop
		source: objMaster.coverImage
		asynchronous: true
		retainWhileLoading: true
	}


	Image {
		id: arrowLeft
		anchors.left: parent.left;		anchors.leftMargin: modelItem.scale["PADDING"]
		anchors.verticalCenter: parent.verticalCenter
		asynchronous: true
		source: "../../resources/images/video_play.svg"
		fillMode: Image.PreserveAspectFit
		sourceSize.height: parent.height / 6
		smooth: false
		visible: objMaster.arrowLeftVisible
		mirror: true
	}
	Image {
		id: arrowRight
		anchors.right: parent.right;		anchors.rightMargin: modelItem.scale["PADDING"]
		anchors.verticalCenter: parent.verticalCenter
		asynchronous: true
		source: "../../resources/images/video_play.svg"
		fillMode: Image.PreserveAspectFit
		sourceSize.height: parent.height / 6
		smooth: false
		visible: objMaster.arrowRightVisible
	}


	Image {
		id: playButtonCenter
		anchors.centerIn: parent
		asynchronous: true
		source: "../../resources/images/video_play.svg"
		fillMode: Image.PreserveAspectFit
		sourceSize.height: parent.height / 4
		smooth: false
		visible: if (objMaster.source !== "") {
					 if (mediaPlayer.playbackState === MediaPlayer.PausedState || mediaPlayer.playbackState === MediaPlayer.StoppedState) { return true; }
					 else { return false; }
				 }
				 else { return false; }
	}

	MouseArea {
		anchors.fill: objMaster.source !== "" ? parent : undefined
		onClicked: if (mediaPlayer.playbackState === MediaPlayer.PlayingState) { mediaPlayer.pause(); }
				   else { mediaPlayer.play(); }
	}


	Rectangle {
		id: bottomMenu
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.bottom: parent.bottom
		height: width / 9
		color: "black"
		z: opacity === 0 ? mediaPlayer.z - 1 : mediaPlayer.z + 1
		opacity: if (objMaster.source === "") { return 0; }
				 else {
					 if (mediaPlayer.playbackState == MediaPlayer.StoppedState) { return 0; }
					 else if (mediaPlayer.playbackState != MediaPlayer.PlayingState) { return 0.8; }
					 else { return 0; }
				 }

		Behavior on opacity {
			SequentialAnimation {
				PauseAnimation  { duration: bottomMenu.opacity === 0.8 ? 3000 : 0 }
				OpacityAnimator { duration: 500 }
			}
		}
		SequentialAnimation {
			id: bottomMenuClick
			running: false
			ScriptAction    { script: { bottomMenu.opacity = 0.8; } }
			PauseAnimation  { duration: 3000 }
			OpacityAnimator { target: bottomMenu; from: 0.8; to: 0; duration: 500 }
		}


		Item {
			id: bottomMenu1
			anchors.top: parent.top
			anchors.left: parent.left
			anchors.right: parent.right
			anchors.bottom: bottomMenu2.top
			z: bottomMenu2.z + 1

			// PRIMARY Position Slider
			Slider {
				id: bottomMenu1_positionSlider

				anchors.left: parent.left
				anchors.right: parent.right
				anchors.verticalCenter: parent.verticalCenter
				height: parent.height

				enabled: objMaster.source !== "" && bottomMenu.opacity > 0

				from: 0
				to: 1
				value: pressed ? value : mediaPlayer.position / mediaPlayer.duration

				onPressedChanged: {
					if (objMaster.source !== "") { bottomMenuClick.restart(); }
					onMoved: {
						var origState = mediaPlayer.playbackState;
						if (origState === MediaPlayer.StoppedState || origState == MediaPlayer.PlayingState) { mediaPlayer.pause(); }
						mediaPlayer.setPosition(value * mediaPlayer.duration);
						if (origState === MediaPlayer.PlayingState) { mediaPlayer.play(); }
					}
				}
				onVisualPositionChanged: if (bottomMenu1_positionSlider.pressed) { bottomMenuClick.restart(); }
			}
		}
		Item {
			id: bottomMenu2
			anchors.left: parent.left
			anchors.right: parent.right
			anchors.bottom: parent.bottom
			height: parent.height * 0.45

			// PLAY / PAUSE Icon
			Image {
				id: bottomMenu2_play
				anchors.top: parent.top
				anchors.left: parent.left; anchors.leftMargin: parent.height / 2
				anchors.bottom: parent.bottom
				smooth: false
				fillMode: Image.PreserveAspectFit
				asynchronous: true
				source: if (mediaPlayer.playbackState === MediaPlayer.PlayingState) { "../../resources/images/yt_pause.png"; }
						else { "../../resources/images/yt_play.png"; }

				MouseArea {
					anchors.fill: parent
					enabled: bottomMenu.opacity > 0
					onClicked: {
						bottomMenuClick.restart();
						if (mediaPlayer.playbackState === MediaPlayer.PlayingState) { mediaPlayer.pause(); }
						else { mediaPlayer.play(); }
					}
				}
			}

			// VOLUME Icon
			Image {
				id: bottomMenu2_volume
				anchors.top: parent.top
				anchors.left: bottomMenu2_play.right; anchors.leftMargin: parent.height / 2
				anchors.bottom: parent.bottom
				smooth: false
				fillMode: Image.PreserveAspectFit
				asynchronous: true
				source: if (audioOutput.muted || audioOutput.volume === 0) { "../../resources/images/yt_volume0.png"; }
						else {
							if (audioOutput.volume > 0.8) { "../../resources/images/yt_volume4.png"; }
							else if (audioOutput.volume > 0.6) { "../../resources/images/yt_volume3.png"; }
							else if (audioOutput.volume > 0.4) { "../../resources/images/yt_volume2.png"; }
							else { "../../resources/images/yt_volume1.png"; }
						}

				MouseArea {
					anchors.fill: parent
					enabled: bottomMenu.opacity > 0
					onClicked: {
						if (objMaster.source !== "") { bottomMenuClick.restart(); }
						if (mediaPlayer.hasAudio) { audioOutput.muted = !audioOutput.muted; }
					}
				}
			}

			// VOLUME Slider
			Slider {
				id: bottomMenu2_volumeSlider

				anchors.left: bottomMenu2_volume.right
				anchors.right: bottomMenu2_time1.left
				anchors.verticalCenter: parent.verticalCenter
				height: parent.height
				enabled: mediaPlayer.hasAudio && bottomMenu.opacity > 0

				from: 0
				to: 1
				value: audioOutput.volume

				onPressedChanged: {
					if (objMaster.source !== "") { bottomMenuClick.restart(); }
					onMoved: {
						audioOutput.volume = value;
					}
				}
				onVisualPositionChanged: if (bottomMenu2_volumeSlider.pressed) { bottomMenuClick.restart(); }
			}

			CustomText {
				id: bottomMenu2_time1
				anchors.right: bottomMenu2_time.left
				anchors.verticalCenter: parent.verticalCenter
				pixelSize: parent.height * 0.5
				color: "white"
				text: reformateTime(mediaPlayer.position)
			}
			CustomText {
				id: bottomMenu2_time
				anchors.right: bottomMenu2_time2.left
				anchors.verticalCenter: parent.verticalCenter
				pixelSize: parent.height * 0.5
				color: "white"
				text: " / "
			}
			CustomText {
				id: bottomMenu2_time2
				anchors.right: parent.right; anchors.rightMargin: parent.height / 2
				anchors.verticalCenter: parent.verticalCenter
				pixelSize: parent.height * 0.5
				color: "white"
				text: reformateTime(mediaPlayer.duration)
			}
		}
	}



	// Reformate time to [hh]:mm:ss
	function reformateTime(input) {
		const formatTime = (time) => {
			const sec = Math.floor((time / 1000) % 60).toString();
			const min = Math.floor((time / 1000 / 60) % 60).toString();
			const hr =  Math.floor((time / 1000 / 60 / 60) % 24).toString();

			let formattedTime = "";
			if (hr > 0) {
				formattedTime += `${hr.toString().padStart(2, "0")}:`;
			}
			formattedTime += `${min.toString().padStart(2, "0")}:${sec.toString().padStart(2, "0")}`;

			return formattedTime;
		};

		const output = `${formatTime(input)}`;
		return output;
	}
}
