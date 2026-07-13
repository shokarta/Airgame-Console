#ifndef OAUTH2_H
#define OAUTH2_H

#include <QObject>
#include <QQuickItem>
#include <QQmlComponent>
#include <QQmlApplicationEngine>
#include <QOAuth2AuthorizationCodeFlow>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QUrl>
#include <QUrlQuery>
#include <QOAuthHttpServerReplyHandler>
#include <QAbstractOAuth>
#include <QHostAddress>

#include <QSsl>
#include <QSslKey>

#include <QtWebView>


//#define REPLYMESSAGE "<!DOCTYPE html><html><body bgcolor=#107C10><br><p id=text1 align=center><font color=#FFFFFF style=\ "font-size:1.5em; font-weight:bold;\">Login in progress</font>'; <p id=text2 align=center><font color=#CCCCCC style=\ "font-size:1.5em; font-style:italic;\"></font>'; <br><br><p id=text3 align=center><font color=#CCCCCC style=\ "font-size:1.5em;\">proceed with login.</font>'; <br><br><br><center><img src=https://assets.xboxservices.com/assets/33/7f/337f5943-9338-47d1-be7e-fb7c099cfcc8.svg?n=Redeem_Content-Placement-0_03_788x444_01.svg width=60%></center><script> window.onload = function() { checkOauthFinished(); }; window.addEventListener(popstate, function(event) { checkOauthFinished(); }); function checkOauthFinished() { const urlParams = new URLSearchParams(window.location.search); if (urlParams.has('error')) { document.getElementById('text1').innerHTML = '<font color=#FFFFFF style=\"font-size:1.5em; font-weight:bold;\">Error during login:</font>'; document.getElementById('text2').innerHTML = '<font color=#CCCCCC style=\"font-size:1.5em; font-style:italic;\">' + urlParams.get('error') + '</font>'; document.getElementById('text3').innerHTML = '<font color=#CCCCCC style=\"font-size:1.5em;\">close this window and try again.</font>'; } else { document.getElementById('text1').innerHTML = '<font color=#FFFFFF style=\"font-size:1.5em; font-weight:bold;\">Succesfully logged in,</font>'; document.getElementById('text2').innerHTML = '<font color=#CCCCCC style=\"font-size:1.5em; font-style:italic;\"></font>'; document.getElementById('text3').innerHTML = '<font color=#CCCCCC style=\"font-size:1.5em;\">you can close this window and return to application.</font>'; } } </script></body></html>";
#define REPLYMESSAGE "<!DOCTYPE html>\n<html>\n<body bgcolor=#107C10>\n<br>\n<p id=text1 align=center><font color=#FFFFFF style=\"font-size:1.5em; font-weight:bold;\">Login in progress</font>';\n<p id=text2 align=center><font color=#CCCCCC style=\"font-size:1.5em; font-style:italic;\"></font>';\n<br><br>\n<p id=text3 align=center><font color=#CCCCCC style=\"font-size:1.5em;\">proceed with login.</font>';\n<br><br><br>\n<center><img src=https://assets.xboxservices.com/assets/33/7f/337f5943-9338-47d1-be7e-fb7c099cfcc8.svg?n=Redeem_Content-Placement-0_03_788x444_01.svg width=60%></center>\n<script>\nwindow.onload = function() { checkOauthFinished(); };\nwindow.addEventListener(popstate, function(event) { checkOauthFinished(); });\nfunction checkOauthFinished() {\nconst urlParams = new URLSearchParams(window.location.search);\nif (urlParams.has('error')) {\ndocument.getElementById('text1').innerHTML = '<font color=#FFFFFF style=\"font-size:1.5em; font-weight:bold;\">Error during login:</font>';\ndocument.getElementById('text2').innerHTML = '<font color=#CCCCCC style=\"font-size:1.5em; font-style:italic;\">' + urlParams.get('error') + '</font>';\ndocument.getElementById('text3').innerHTML = '<font color=#CCCCCC style=\"font-size:1.5em;\">close this window and try again.</font>';\n}\nelse {\ndocument.getElementById('text1').innerHTML = '<font color=#FFFFFF style=\"font-size:1.5em; font-weight:bold;\">Succesfully logged in,</font>';\ndocument.getElementById('text2').innerHTML = '<font color=#CCCCCC style=\"font-size:1.5em; font-style:italic;\"></font>';\ndocument.getElementById('text3').innerHTML = '<font color=#CCCCCC style=\"font-size:1.5em;\">you can close this window and return to application.</font>';\n}\n}\n</script>\n</body>\n</html>"



class QQmlApplicationEngine;


class LiveSSO : public QObject
{
	Q_OBJECT
	Q_PROPERTY(QByteArray liveLoginData READ liveLoginData WRITE setLiveLoginData NOTIFY liveLoginDataChanged)


	public:
		explicit LiveSSO(QQmlApplicationEngine *engine, QObject *parent = nullptr);
		virtual ~LiveSSO();

		// triggered by QML (only ready)
		QByteArray liveLoginData() const { return m_liveLoginData; }

		// triggered by QML: liveLoginData = ""; // or by C++: setLiveLoginData(string)
		void setLiveLoginData(const QByteArray &newData) {
			//if (m_liveLoginData == newData) return;     // error code can be same as before, therefore it must be sent even when its the very same
			m_liveLoginData = newData;
			emit liveLoginDataChanged();     // emit signal, because when we set it from QML, we dont want to receive signal onErrorInfoQMLChanged
		}


	public slots:
		Q_INVOKABLE void authenticate(QObject *root = nullptr);


	private:
		QString REDIRECT_URI = "http://localhost:5476/";
		QString CLIENT_ID = "0c10aad4-3a8f-4257-bbdb-64f46217db8e";
		QString DIRECTORY_ID = "4abfc7b2-5eaa-49b8-aca5-938e4e320bc3";
		QString SCOPE = "xboxlive.signin openid profile offline_access";
		QString RESPONSE_TYPE = "code";
		QString CLIENT_SECRET = "liH8Q~3PMPkMi5hI1m2UqF0tb1s1IdIUApLYHdj4";
		QString AUTHORIZATION_URL = "https://login.microsoftonline.com/consumers/oauth2/v2.0/devicecode";
		QString ACCESSTOKEN_URL = "https://login.microsoftonline.com/consumers/oauth2/v2.0/token";


		QQmlApplicationEngine *m_engine = nullptr;
		QObject *webViewLoader = nullptr;
		QOAuth2AuthorizationCodeFlow *live;
		QByteArray m_liveLoginData;
		QHostAddress hostAddress = QHostAddress(QHostAddress::LocalHost);		// works since 6.9.0, alternative (also since 6.8.0) is QHostAddress(redirectUri.scheme() + "://" + redirectUri.host());
		QOAuthHttpServerReplyHandler *replyHandler;


		void findWebViewLoader(QObject *obj = nullptr) {
			if (!obj) { obj = m_engine->rootObjects().constFirst(); }
			QList<QObject*> children = obj->children();
			for (int i = 0; i < children.size(); i++) {
				QObject *child = children.at(i);
				if (child->objectName() == "loader_webView") {	// oauth2content
					//qDebug() << "WebView Loader found:" << child;
					webViewLoader = child;
					return;
				}
				if (qobject_cast<QQuickItem*>(child) || qobject_cast<QQmlComponent*>(child)) { findWebViewLoader(child); }
			}
		}

		QString randomizeState() {
			QString result;
			for (int i = 0; i < 10; ++i) {
				int index = rand() % QString("abcdefghijklmnopqrstuvwxyz0123456789").size();
				result.append(QString("abcdefghijklmnopqrstuvwxyz0123456789").at(index));
			}
			return result;
		}

		QByteArray keyFileContent() {
			QByteArray result;
			QFile keyFile(QStringLiteral(":/airgame-console/resources/ssl/localhost_oauth.pem"));
			if (keyFile.open(QIODevice::ReadOnly)) {
				result = keyFile.readAll();
				keyFile.close();
			}
			else { qCritical() << "Could not find key: " << QFileInfo(keyFile).absoluteFilePath(); }
			return result;
		}



	signals:
		void liveLoginDataChanged(/*QByteArray*/);


};

#endif // OAUTH2_H
