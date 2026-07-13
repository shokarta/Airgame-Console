#ifndef COREFUNCTIONS_H
#define COREFUNCTIONS_H

#include <QMainWindow>
#include <QMessageBox>
#include <QtCore/QObject>
#include <QtCore/QMetaObject>
#include <QUrl>
#include <QDesktopServices>

#include <QtGlobal>
#include <QProcess>
#include <QDateTime>
#include <QJsonDocument>
#include <QJsonObject>
#include <QRegularExpression>
#include <QSettings>
#include <QOperatingSystemVersion>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QCoreApplication>
#include <QQuickWindow>


#if defined(Q_OS_ANDROID)
	#include <android/log.h>
	#include <QtCore/qjniobject.h>
	#include <QtCore/qcoreapplication.h>
	#include <QtCore/private/qandroidextras_p.h>
#elif defined(Q_OS_IOS)
	#include <dispatch/dispatch.h>
	#include <objc/objc.h>
	#include <objc/message.h>
	#include <objc/runtime.h>
#endif

//#include <signal.h>

extern QString sessionID;


class CoreFunctions : public QObject
{
	Q_OBJECT


	public:
		CoreFunctions(QObject *parent = nullptr) : QObject(parent) {}

		// Permissions
		Q_INVOKABLE bool requestMedia();
		Q_INVOKABLE void settingsMedia();
		Q_INVOKABLE void requestNotifications();
		
		// FileContent
		Q_INVOKABLE QVariantMap fileContent(QString url);

		// Screen Always ON / OFF
		Q_INVOKABLE void enableScreenAlwaysOn();
		Q_INVOKABLE void disableScreenAlwaysOn();

		// Device Model
		QString getDevice();
		
		// Get Android/iOS log
		void logPipe();
		
		// Submit log to REST API
		void submitLog(QString category, QString file, QString function, int line, QString message, QString type, QString origin)
		{
			QSettings settings;

			if (settings.value("user_in_debug", "defaultUser").toBool() == true || QStringList({"UNDEFINED","WARNING","CRITICAL","ERROR","SILENT","FATAL"}).contains(type)) {

				QOperatingSystemVersion osVersion = QOperatingSystemVersion::current();

				QQuickWindow(view);
					auto rhiBackend = view.rendererInterface() ? view.rendererInterface()->graphicsApi() : QSGRendererInterface::Unknown;
				QString graphicApiString;
					if (rhiBackend == 0) { graphicApiString = "Unknown"; }
					else if (rhiBackend == 1) { graphicApiString = "Software"; }
					else if (rhiBackend == 2) { graphicApiString = "OpenVG"; }			// only Android (very rare, not modern anymore)
					else if (rhiBackend == 3) { graphicApiString = "OpenGL"; }			// only Android
					else if (rhiBackend == 4) { graphicApiString = "Direct3D11"; }		// only Windows
					else if (rhiBackend == 5) { graphicApiString = "Vulcan"; }			// only Android
					else if (rhiBackend == 6) { graphicApiString = "Metal"; }			// only iOS
					else if (rhiBackend == 7) { graphicApiString = "Null"; }			// headless, for CLI apps
					else if (rhiBackend == 8) { graphicApiString = "Direct3D12"; }		// only Windows

				QJsonObject log;
					log["timestamp"] = QDateTime::currentMSecsSinceEpoch();
					log["version"] = QCoreApplication::applicationVersion();	// APP_VERSION (variable from cmake);
					log["type"] = type;
					log["origin"] = origin;
					log["message"] = message;
					log["os"] = osVersion.name();
					log["os_version"] = QString("%1.%2.%3").arg(osVersion.majorVersion()).arg(osVersion.minorVersion()).arg(osVersion.microVersion());
					log["user"] = settings.value("user_id", "defaultUser").toInt();
					log["user_in_debug"] = settings.value("user_in_debug", "defaultUser").toBool();
					log["file"] = file;
					log["line"] = line;
					log["function"] = function;
					log["category"] = category;
					log["device"] = getDevice();
					log["gpu"] = graphicApiString;
					log["session"] = sessionID;

				QNetworkAccessManager *manager = new QNetworkAccessManager();
				QNetworkRequest request(QUrl("https://filmtoro.com/api/error.asp"));		// https://filmtoro.com/api/error.asp https://admin.mamavis.cz/data.php
					request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
					//request.setRawHeader("Authorization", "Bearer YOUR_TOKEN_HERE");

				//Send POST request
				//QNetworkReply *reply = manager->post(request, QJsonDocument(log).toJson());		// this instead of line bellow to retrieve reply (whcih is recommended)
				manager->post(request, QJsonDocument(log).toJson());

				// QObject::connect(reply, &QNetworkReply::finished, [reply, type, message] {
				// 	QByteArray serverReply = reply->readAll();
				// 	#if defined(Q_OS_ANDROID)
				// 		__android_log_print(ANDROID_LOG_DEBUG, "Qt", "%s", qPrintable(serverReply.constData()));
				// 	#elif defined(Q_OS_IOS)
				// 		NSString *nsMsg = [NSString stringWithUTF8String:serverReply.constData().toUtf8().constData()];			// does not work, can not do this in *.cpp (must be *.mm)
				// 		NSLog(@"[Debug] %@", nsMsg);																						// does not work, can not do this in *.cpp (must be *.mm)
				// 	#else
				// 		fprintf(stderr, "%s\n", serverReply.constData());
				// 		fflush(stderr);
				// 	#endif
				// 	reply->deleteLater();
				// });


			}
		}

		// OS Version
		//Q_INVOKABLE QString osVersion();
		
		// Status/Navigation Bar Modes
		//Q_INVOKABLE void setBarMode(int mode);
	
		// Simulate Crash
		//Q_INVOKABLE void simulateCrash() { raise(SIGSEGV); }
};

#endif // COREFUNCTIONS_H
