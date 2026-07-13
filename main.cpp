#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>

#include <QQuickWindow>

#include <QtWebView>
//#include "CoreFunctions.h"
#include <GameListController.h>


//#include "api/peer_connection_interface.h"
//#include "api/video/video_frame.h"
//#include "api/video/video_sink_interface.h"

//#include "WebRtcClient.h"

//MyFboItem* g_fbo = nullptr;


int main(int argc, char *argv[])
{
	//QtWebView::initialize();

	//QQuickWindow::setGraphicsApi(QSGRendererInterface::OpenGL);

	QGuiApplication app(argc, argv);

	//rtc::ThreadManager::Instance()->WrapCurrentThread();	// generate its thread dedicated for webrtc
	//libwebrtc::LibWebRTC::Initialize();

	QQmlApplicationEngine engine;





	// load style
	QQuickStyle::setStyle("Material");

	// set core data
	QCoreApplication::setApplicationName(APP_APPLICATIONNAME);
	QCoreApplication::setOrganizationName(APP_ORGANIZATIONNAME);
	QCoreApplication::setOrganizationDomain(QString(APP_ORGANIZATIONDOMAIN).split(u'.')[0] + "." + QString(APP_ORGANIZATIONDOMAIN).split(u'.')[1]);
	QCoreApplication::setApplicationVersion(APP_VERSION);


	QSettings settings;
	settings.setPath(QSettings::IniFormat, QSettings::UserScope, QStandardPaths::writableLocation(QStandardPaths::AppDataLocation));

	// CoreFunctions
	//qmlRegisterType<CoreFunctions>("CoreFunctions", 1,0, "CoreFunctions");

	// SSO
	//LiveSSO liveSSO{&engine};			engine.rootContext()->setContextProperty("LiveSSO", &liveSSO);

	// QAbstractListModel
	qmlRegisterType<GameListModelFull>("GameListModelFull", 1, 0, "GameListModelFull");
	qmlRegisterType<GameListModelFiltered>("GameListModelFiltered", 1, 0, "GameListModelFiltered");

	// WebRTC Client
	//qmlRegisterType<WebRtcClient>("WebRtcClient", 1, 0, "WebRtcClient");

	// MyFboItem
	//qmlRegisterType<MyFboItem>("MyFboItem", 1, 0, "MyFboItem");


	const QUrl url("qrc:/airgame-console/Main.qml");
	QObject::connect(
		&engine,
		&QQmlApplicationEngine::objectCreationFailed,
		&app,
		[]() { QCoreApplication::exit(-1); },
		Qt::QueuedConnection);
	engine.load(url);


	if (engine.rootObjects().isEmpty()) {
		qDebug() << "QML NOT Loaded";
		return -1;
	}


	//QObject *root = engine.rootObjects().constFirst();
	//g_fbo = root->findChild<MyFboItem*>();


	int ret = app.exec();

	//libwebrtc::LibWebRTC::Terminate();

	return ret;
}
