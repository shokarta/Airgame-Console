# SPDX-FileCopyrightText: (C) 2026 Jiri Zaloudek <shokarta@gmail.com> https://www.sfatmt.com
# SPDX-License-Identifier: MIT

cmake_minimum_required(VERSION 3.29)

# Variables needed more than once below
set(MY_APP_PROJECT_NAME "AirGame Console")
string(TOLOWER ${MY_APP_PROJECT_NAME} MY_APP_PROJECT_NAME_URI)
string(REPLACE " " "-" MY_APP_PROJECT_NAME_URI "${MY_APP_PROJECT_NAME_URI}")
set(TARGET_NAME "airgame-console")
set(PROJECT_VERSION 0.1)
set(MY_APP_REVERSE_DNS_IDENTIFIER "com.sfatmt.${TARGET_NAME}")
set(LANGUAGES CXX)


project(${MY_APP_PROJECT_NAME} VERSION ${PROJECT_VERSION} LANGUAGES ${LANGUAGES})

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)



find_package(QT NAMES Qt6)		# load Qt CMake Variables (ie: QT_VERSION_MAJOR etc)
find_package(Qt6 REQUIRED COMPONENTS Quick)
find_package(Qt6 REQUIRED COMPONENTS QuickControls2)
find_package(Qt6 REQUIRED COMPONENTS Multimedia)
find_package(Qt6 REQUIRED COMPONENTS Core)
find_package(Qt6 REQUIRED COMPONENTS Gui)
find_package(Qt6 REQUIRED COMPONENTS Widgets)
find_package(Qt6 REQUIRED COMPONENTS WebView)
find_package(Qt6 REQUIRED COMPONENTS Network)
find_package(Qt6 REQUIRED COMPONENTS ShaderTools)
find_package(Qt6 REQUIRED COMPONENTS Concurrent)
#find_package(Qt6 REQUIRED COMPONENTS NetworkAuth)

find_package(Qt6 REQUIRED COMPONENTS GuiPrivate)
find_package(Qt6 REQUIRED COMPONENTS CorePrivate)


# OpenSSL
#if (CMAKE_SYSTEM_NAME STREQUAL "Android")
#	include("${CMAKE_SOURCE_DIR}/../../extralibs/openssl/android/android_openssl.cmake")
#	set(OPENSSL_ROOT_DIR "${CMAKE_SOURCE_DIR}/../../extralibs/openssl/android/ssl_3")		#set(OPENSSL_ROOT_DIR "${CMAKE_SOURCE_DIR}/../../extralibs/openssl/android/ssl_3/${CMAKE_ANDROID_ARCH_ABI}")
#	set(OPENSSL_LIBRARIES "${CMAKE_SOURCE_DIR}/../../extralibs/openssl/android/ssl_3/${CMAKE_ANDROID_ARCH_ABI}")
#	set(OPENSSL_CRYPTO_LIBRARY "${CMAKE_SOURCE_DIR}/../../extralibs/openssl/android/ssl_3/${CMAKE_ANDROID_ARCH_ABI}")
#	set(OPENSSL_INCLUDE_DIR "${CMAKE_SOURCE_DIR}/../../extralibs/openssl/android/ssl_3/include")
#	include_directories(${OPENSSL_INCLUDE_DIR})
#	find_package(OpenSSL)
#elseif (CMAKE_SYSTEM_NAME STREQUAL "iOS")
#	#include("${CMAKE_SOURCE_DIR}/../../extralibs/openssl/ios/lib/cmake/OpenSSL/OpenSSLConfig.cmake")
#	set(OPENSSL_ROOT_DIR "${CMAKE_SOURCE_DIR}/../../extralibs/openssl/ios")
#	set(OPENSSL_LIBRARIES "${CMAKE_SOURCE_DIR}/../../extralibs/openssl/ios/lib")
#	set(OPENSSL_CRYPTO_LIBRARY "${CMAKE_SOURCE_DIR}/../../extralibs/openssl/ios/libcrypto.a")		# or *.dylib?
#	set(OPENSSL_INCLUDE_DIR "${CMAKE_SOURCE_DIR}/../../extralibs/openssl/ios/include")
#	include_directories(${OPENSSL_INCLUDE_DIR})
#	find_package(OpenSSL)
#elseif (CMAKE_SYSTEM_NAME STREQUAL "Windows")
#	include("${CMAKE_SOURCE_DIR}/../../extralibs/openssl/windows/lib/cmake/OpenSSL/OpenSSLConfig.cmake")
#	set(OPENSSL_ROOT_DIR "${CMAKE_SOURCE_DIR}/../../extralibs/openssl/windows")
#	set(OPENSSL_LIBRARIES "${CMAKE_SOURCE_DIR}/../../extralibs/openssl/windows/lib")
#	set(OPENSSL_CRYPTO_LIBRARY "${CMAKE_SOURCE_DIR}/../../extralibs/openssl/windows/libcrypto.lib")
#	set(OPENSSL_INCLUDE_DIR "${CMAKE_SOURCE_DIR}/../../extralibs/openssl/windows/include")
#	include_directories(${OPENSSL_INCLUDE_DIR})
#	find_package(OpenSSL)
#endif()


qt_policy(
	SET QTP0002 NEW
)

if (CMAKE_SYSTEM_NAME STREQUAL "iOS")
	set(QT_USE_RISKY_DSYM_ARCHIVING_WORKAROUND ON)		# Workaround Missing DSYM - https://gitlab.kitware.com/cmake/cmake/-/issues/23734
	set(QT_FORCE_CMP0156_TO_NEW ON)						# QTBUG-132412 QTBUG-135978
endif()


# Collect files
file(GLOB_RECURSE sources_qml			LIST_DIRECTORIES false		RELATIVE ${CMAKE_CURRENT_LIST_DIR}	CONFIGURE_DEPENDS "*.qml" "qml/components/*.qml" "qml/screens/*.qml" "qml/popups/*.qml")
file(GLOB_RECURSE sources_js			LIST_DIRECTORIES false		RELATIVE ${CMAKE_CURRENT_LIST_DIR}	CONFIGURE_DEPENDS "*.js" "qml/components/*.qml")
file(GLOB_RECURSE sources_mjs			LIST_DIRECTORIES false		RELATIVE ${CMAKE_CURRENT_LIST_DIR}	CONFIGURE_DEPENDS "*.mjs")
file(GLOB_RECURSE sources_images		LIST_DIRECTORIES false		RELATIVE ${CMAKE_CURRENT_LIST_DIR}	CONFIGURE_DEPENDS "resources/images/*.gif" "resources/images/*.svg" "resources/images/*.png" "resources/images/*.jpg" "resources/images/*.webp")
file(GLOB_RECURSE sources_fonts			LIST_DIRECTORIES false		RELATIVE ${CMAKE_CURRENT_LIST_DIR}	CONFIGURE_DEPENDS "resources/fonts/*.ttf")
file(GLOB_RECURSE sources_ssl			LIST_DIRECTORIES false		RELATIVE ${CMAKE_CURRENT_LIST_DIR}	CONFIGURE_DEPENDS "resources/ssl/*.pem")


#set(corefunctions	"CoreFunctions.h"	"native/CoreFunctions_fileContent.cpp"		# common for all systems
set(coreFunctions	"GameListController.h")	#	"QtVideoRenderer.h" "QtVideoRenderer.cpp"	"MyFboItem.h" "MyFboItem.cpp")											# common for all systems
set(webrtc)	#			"WebRtcClient.h" "WebRtcClient.cpp"							# common for all systems
set(firebase_h)
set(firebase_cpp)
set(firebase_swift)

if (CMAKE_SYSTEM_NAME STREQUAL "Windows")
	#list(APPEND corefunctions	"native/CoreFunctions_requestNotifications.cpp"	"native/CoreFunctions_requestMedia.cpp"	"native/CoreFunctions_settingsMedia.cpp"	"native/CoreFunctions_screenOn.cpp"	"native/CoreFunctions_getDevice.cpp"	"native/CoreFunctions_logPipe.cpp")

elseif (CMAKE_SYSTEM_NAME STREQUAL "Android")
	#list(APPEND corefunctions	"native/CoreFunctions_requestNotifications.cpp"	"native/CoreFunctions_requestMedia.cpp"	"native/CoreFunctions_settingsMedia.cpp"	"native/CoreFunctions_screenOn.cpp"	"native/CoreFunctions_getDevice.cpp"	"native/CoreFunctions_logPipe.cpp")
	list(APPEND firebase_h		"../../extralibs/firebase-qt/src/firebaseqtabstractmodule.h"	"../../extralibs/firebase-qt/src/firebaseqtapp.h"	"../../extralibs/firebase-qt/src/firebaseqtapp_p.h"			"../../extralibs/firebase-qt/src/firebaseqtmessaging.h")
	list(APPEND firebase_cpp	"../../extralibs/firebase-qt/src/firebaseqtabstractmodule.cpp"	"../../extralibs/firebase-qt/src/firebaseqtapp.cpp"	"../../extralibs/firebase-qt/src/firebaseqtmessaging.cpp")

elseif (CMAKE_SYSTEM_NAME STREQUAL "iOS")
	#list(APPEND corefunctions	"native/CoreFunctions_requestNotifications.mm"		"native/CoreFunctions_requestMedia.mm"		"native/CoreFunctions_settingsMedia.mm"	"native/CoreFunctions_screenOn.mm"		"native/CoreFunctions_getDevice.mm"	"native/CoreFunctions_logPipe.mm")
	list(APPEND firebase_h		"../../extralibs/firebase-qt/src/firebaseqtabstractmodule.h"	"../../extralibs/firebase-qt/src/firebaseqtapp.h"	"../../extralibs/firebase-qt/src/firebaseqtapp_p.h"			"../../extralibs/firebase-qt/src/firebaseqtmessaging.h")
	list(APPEND firebase_cpp	"../../extralibs/firebase-qt/src/firebaseqtabstractmodule.cpp"	"../../extralibs/firebase-qt/src/firebaseqtapp.cpp"	"../../extralibs/firebase-qt/src/firebaseqtmessaging.cpp")
	list(APPEND firebase_swift	"../../extralibs/firebase-qt/src/ios.swift")

endif()


# Add executable or library
qt_add_executable(${TARGET_NAME}
    main.cpp
	${coreFunctions}
	${webrtc}
	#Firebase.h
	${firebase_h}
	${firebase_cpp}
	${firebase_swift}
	CHANGELOG.md
)


# pass values to AndroidManifest / Info.Plist
set(VAR_PROJECT_NAME 			${MY_APP_PROJECT_NAME})
set(VAR_PROJECT_DNS_IDENTIFIER	${MY_APP_REVERSE_DNS_IDENTIFIER})
set(VAR_PROJECT_VERSION			${PROJECT_VERSION})
set(VAR_PROJECT_VERSION_PATCH	${PROJECT_VERSION_PATCH})
set(VAR_PROJECT_COPYRIGHT		"Copyright © 2026 SyncFlow Automations")

# pass values to main.cpp
target_compile_definitions(${TARGET_NAME} PRIVATE APP_APPLICATIONNAME="${VAR_PROJECT_NAME}")
target_compile_definitions(${TARGET_NAME} PRIVATE APP_ORGANIZATIONNAME="${MY_APP_PROJECT_NAME_URI}")
target_compile_definitions(${TARGET_NAME} PRIVATE APP_ORGANIZATIONDOMAIN="${VAR_PROJECT_DNS_IDENTIFIER}")
target_compile_definitions(${TARGET_NAME} PRIVATE APP_VERSION="${VAR_PROJECT_VERSION}")



#WebRTC
#if (CMAKE_SYSTEM_NAME STREQUAL "Android")
#	set(WEBRTC_ROOT_DIR "${CMAKE_SOURCE_DIR}/../../extralibs/webrtc/android")

#	target_include_directories(${TARGET_NAME} PRIVATE
#		${WEBRTC_ROOT_DIR}/include
#		${WEBRTC_ROOT_DIR}/include/third_party/abseil-cpp
#	)

#	link_directories("${WEBRTC_ROOT_DIR}/lib/${CMAKE_ANDROID_ARCH_ABI}")

#	target_compile_definitions(${TARGET_NAME} PRIVATE
#		WEBRTC_WIN
#		WEBRTC_ARCH_LITTLE_ENDIAN
#		NOMINMAX
#		WIN32_LEAN_A
#	)
#elseif (CMAKE_SYSTEM_NAME STREQUAL "iOS")
#	set(WEBRTC_ROOT_DIR "${CMAKE_SOURCE_DIR}/../../extralibs/webrtc/ios")

#	target_include_directories(${TARGET_NAME} PRIVATE
#		${WEBRTC_ROOT_DIR}/include
#		${WEBRTC_ROOT_DIR}/include/third_party/abseil-cpp
#	)

#	link_directories("${WEBRTC_ROOT_DIR}/lib/device-arm64")

#	target_compile_definitions(${TARGET_NAME} PRIVATE
#		WEBRTC_WIN
#		WEBRTC_ARCH_LITTLE_ENDIAN
#		NOMINMAX
#		WIN32_LEAN_A
#	)
#elseif (CMAKE_SYSTEM_NAME STREQUAL "Windows")
#	set(WEBRTC_ROOT_DIR "${CMAKE_SOURCE_DIR}/../../extralibs/webrtc/windows")

#	target_include_directories(${TARGET_NAME} PRIVATE
#		${WEBRTC_ROOT_DIR}/include
#		${WEBRTC_ROOT_DIR}/include/third_party/abseil-cpp
#	)

#	link_directories("${WEBRTC_ROOT_DIR}/lib/x86_64")

#	target_compile_definitions(${TARGET_NAME} PRIVATE
#		WEBRTC_WIN
#		WEBRTC_ARCH_LITTLE_ENDIAN
#		NOMINMAX
#		WIN32_LEAN_A
#	)
#endif()


set_source_files_properties(Main.qml PROPERTIES QT_QML_SINGLETON_TYPE TRUE)
qt_add_qml_module(${TARGET_NAME}
    URI ${MY_APP_PROJECT_NAME_URI}
    VERSION ${PROJECT_VERSION}
    RESOURCE_PREFIX /

    QML_FILES
        ${sources_qml}
		#qml/components/qrcode.min.js

    RESOURCES
        # ANDROID
		#android/AndroidManifest.xml
		#android/res/drawable/splash.xml
		#android/res/values/themes.xml
		##android/src/org/myapp/activity/MyActivity.java
		#android/build.gradle
		#android/gradle.properties
		#android/google-services.json
		#android/postscript.cmd
		#android/crashlytics_postscript.cmd

		# iOS
		#ios/Info.plist.in
		#ios/LaunchScreen.storyboard
		#ios/GoogleService-Info.plist
		#ios/filmtoroMobile.entitlements
		#ios/postscript.sh
		#ios/crashlytics_postscript.sh
		#ios/releasescheme_postscript.sh

		# JavaScript
		${sources_js}

		# Module JavaScript
		${sources_mjs}

		# IMAGES
		${sources_images}

		# FONTS
		${sources_fonts}

		# SSL
		${sources_ssl}
)



# C++ visibility needed to generate symbols for upload.
# Essential for being able to symbolicate crash reports.
# Note that Qt hide visibility of their own code by default and warn against
# making your own code visible. However I have not encountered any issues
# and I cannot get it to generate symbols without this.
# See also XCODE_ATTRIBUTE_GCC_GENERATE_DEBUGGING_SYMBOLS below
set(CMAKE_CXX_VISIBILITY_PRESET default)

if (CMAKE_SYSTEM_NAME STREQUAL "Android")
	#add_android_openssl_libraries(${TARGET_NAME})

elseif (CMAKE_SYSTEM_NAME STREQUAL "iOS")

elseif (CMAKE_SYSTEM_NAME STREQUAL "Windows")

    set_target_properties(${TARGET_NAME} PROPERTIES
        WIN32_EXECUTABLE TRUE
    )
else()

		message(FATAL_ERROR "set_target_properties() NOT set for: ${CMAKE_SYSTEM_NAME} or ${CMAKE_OSX_DEPLOYMENT_TARGET} or ${ARCH} or ${EMBT_TARGET} or ${CMAKE_HOST_SYSTEM_NAME}")

endif()

#if(CMAKE_SYSTEM_NAME STREQUAL "Android")
#	add_custom_command(POST_BUILD
#		TARGET ${TARGET_NAME}
#		COMMAND ${CMAKE_COMMAND} -E copy_if_different "${WEBRTC_ROOT_DIR}/lib/${CMAKE_ANDROID_ARCH_ABI}/libwebrtc.a" "$<TARGET_FILE_DIR:${TARGET_NAME}>"
#	)
#elseif(CMAKE_SYSTEM_NAME STREQUAL "iOS")
#	add_custom_command(POST_BUILD
#		TARGET ${TARGET_NAME}
#		COMMAND ${CMAKE_COMMAND} -E copy_if_different "${WEBRTC_ROOT_DIR}/lib/device-arm64/libwebrtc.a" "$<TARGET_FILE_DIR:${TARGET_NAME}>"
#	)
#elseif(CMAKE_SYSTEM_NAME STREQUAL "Windows")
#	set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
#	add_custom_command(POST_BUILD
#		TARGET ${TARGET_NAME}
#		COMMAND ${CMAKE_COMMAND} -E copy_if_different "${WEBRTC_ROOT_DIR}/lib/x86_64/webrtc.lib" "$<TARGET_FILE_DIR:${TARGET_NAME}>"
#	)
#endif()


target_link_libraries(${TARGET_NAME} PRIVATE Qt6::Quick)
target_link_libraries(${TARGET_NAME} PRIVATE Qt6::QuickControls2)
target_link_libraries(${TARGET_NAME} PRIVATE Qt6::Multimedia)
target_link_libraries(${TARGET_NAME} PRIVATE Qt6::Core)
target_link_libraries(${TARGET_NAME} PRIVATE Qt6::Gui)
target_link_libraries(${TARGET_NAME} PRIVATE Qt6::Widgets)
target_link_libraries(${TARGET_NAME} PRIVATE Qt6::WebView)
target_link_libraries(${TARGET_NAME} PRIVATE Qt6::Network)
target_link_libraries(${TARGET_NAME} PRIVATE Qt6::Concurrent)
#target_link_libraries(${TARGET_NAME} PRIVATE Qt6::NetworkAuth)

target_link_libraries(${TARGET_NAME} PRIVATE Qt6::GuiPrivate)
target_link_libraries(${TARGET_NAME} PRIVATE Qt6::CorePrivate)


# OpenSSL
#if(OPENSSL_FOUND)
#	if(CMAKE_SYSTEM_NAME STREQUAL "Android")
#		target_link_libraries(${TARGET_NAME} PRIVATE "${CMAKE_SOURCE_DIR}/../../extralibs/openssl/android/ssl_3/${CMAKE_ANDROID_ARCH_ABI}/libcrypto_3.so" "${CMAKE_SOURCE_DIR}/../../extralibs/openssl/android/ssl_3/${CMAKE_ANDROID_ARCH_ABI}/libssl_3.so")
#	elseif(CMAKE_SYSTEM_NAME STREQUAL "iOS")
#		target_link_libraries(${TARGET_NAME} PRIVATE "${CMAKE_SOURCE_DIR}/../../extralibs/openssl/ios/lib/libcrypto.a" "${CMAKE_SOURCE_DIR}/../../extralibs/openssl/ios/lib/libssl.a")		# or *.dylib?
#	elseif(CMAKE_SYSTEM_NAME STREQUAL "Windows")
#		target_link_libraries(${TARGET_NAME} PRIVATE "${CMAKE_SOURCE_DIR}/../../extralibs/openssl/windows/lib/libcrypto.lib" "${CMAKE_SOURCE_DIR}/../../extralibs/openssl/windows/lib/libssl.lib")
#	endif()
#else()
#	message(FATAL_ERROR "OpenSSL not found!")
#endif()

# WebRTC
#if(CMAKE_SYSTEM_NAME STREQUAL "Android")
#	target_link_libraries(${TARGET_NAME} PRIVATE "${WEBRTC_ROOT_DIR}/lib/${CMAKE_ANDROID_ARCH_ABI}/libwebrtc.a")
#elseif(CMAKE_SYSTEM_NAME STREQUAL "iOS")
#	target_link_libraries(${TARGET_NAME} PRIVATE "${WEBRTC_ROOT_DIR}/lib/device-arm64/libwebrtc.a")
#elseif(CMAKE_SYSTEM_NAME STREQUAL "Windows")
#	target_link_libraries(${TARGET_NAME} PRIVATE "${WEBRTC_ROOT_DIR}/lib/x86_64/webrtc.lib")
#endif()


include(GNUInstallDirs)
install(TARGETS ${TARGET_NAME}
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
