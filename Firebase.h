#ifndef FIREBASE_H
#define FIREBASE_H

#include <QObject>
#include <QLoggingCategory>

#include "../../firebase-qt/src/firebaseqtapp.h"
#include "../../firebase-qt/src/firebaseqtmessaging.h"

#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS)
#include <firebase/messaging.h>
#endif


class Firebase : public QObject
{
    Q_OBJECT
	Q_PROPERTY(QString firebaseToken	READ firebaseToken		NOTIFY firebaseTokenChanged)
	Q_PROPERTY(QString firebaseMessage	READ firebaseMessage	NOTIFY firebaseMessageChanged)
	

	public:
		explicit Firebase(QObject *parent = nullptr) : QObject(parent)
		{
			#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS)
				auto firebase =		new FirebaseQtApp(this);
				auto messaging =	new FirebaseQtMessaging(firebase);

				connect(messaging, &FirebaseQtMessaging::tokenReceived,		this,	&Firebase::tokenReceived,	Qt::QueuedConnection);
				connect(messaging, &FirebaseQtMessaging::messageReceived,	this,	&Firebase::messageReceived,	Qt::QueuedConnection);

				// no need to set as far as google-services.json is in project/android folder, QT_ANDROID_PACKAGE_SOURCE_DIR is set in CMake and xxxx is set in build.gradle
				#if defined(Q_OS_ANDROID)
					//firebase->setAppId("1:933253518766:android:eed9b7067b6d595e69a43f");
					//firebase->setApiKey("AIzaSyCaq57_-QpB5nGJsWhzO-eAZNSKR8onqEM");
					//firebase->setDatabaseUrl("https://filmtorocz-default-rtdb.europe-west1.firebasedatabase.app");
					//firebase->setMessagingSenderId("933253518766");
					//firebase->setStorageBucket("filmtorocz.appspot.com");
					//firebase->setProjectId("filmtorocz");

					// package name		"com.filmtoro.appMobile"
					//firebase->setAuthDomain("");
					//firebase->setNotificationKey("");
					//firebase->setNotificationUrl("");
					//firebase->setPublicVapidKey("");
				#else
					//firebase->setAppId("1:933253518766:ios:b7d10f5749ef66a269a43f");
					//firebase->setApiKey("AIzaSyDnv1oBfm6-o5hqJWZpX-KSBpsnNsf4x0o");
					//firebase->setDatabaseUrl("https://filmtorocz-default-rtdb.europe-west1.firebasedatabase.app");
					//firebase->setMessagingSenderId("933253518766");
					//firebase->setStorageBucket("filmtorocz.appspot.com");
					//firebase->setProjectId("filmtorocz");

					// package name		"com.filmtoro.appMobile"
					//firebase->setAuthDomain("");
					//firebase->setNotificationKey("");
					//firebase->setNotificationUrl("");
					//firebase->setPublicVapidKey("");
				#endif

				firebase->initialize();
			#endif
		}

		QString firebaseToken()		const { return m_firebaseToken; }		// no need to check myself from QML, when is changed, will provide onChanged signal directly to QML itself where store in Settings{}
		QString firebaseMessage()	const { return m_firebaseMessage; }		// no need to check myself from QML, when is changed, will provide onChanged signal directly to QML itself


		void tokenReceived(const QByteArray &token)
		{
			if (QString(token) != m_firebaseToken) {
				qDebug() << "FIREBASE_MESSAGING: Got Firebase Messaging Token:" << QString(token);
				m_firebaseToken = QString(token);
				Q_EMIT firebaseTokenChanged();
			}
		}

		void messageReceived(const firebase::messaging::Message &message)
		{
			QString result = "";

			#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS)
				qDebug() << "FIREBASE_MESSAGING: Got a Push Notification when the app is running:" << QString::fromStdString(message.from) << QString::fromStdString(message.notification->title);
				result = QString::fromStdString(message.notification->title);
			#endif

			m_firebaseMessage = result;
			Q_EMIT firebaseMessageChanged();
		}


	Q_SIGNALS:
		void firebaseTokenChanged(/*QString*/);
		void firebaseMessageChanged(/*QString*/);


	private:
		QString m_firebaseToken;
		QString m_firebaseMessage;

};

#endif // FIREBASE_H
