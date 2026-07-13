#include "oauth2.h"


LiveSSO::LiveSSO(QQmlApplicationEngine *engine, QObject *parent) : QObject(parent), m_engine(engine)
{
	this->live = new QOAuth2AuthorizationCodeFlow(this);

	this->live->setClientIdentifier(CLIENT_ID);					// Application ID
	//this->live->setClientIdentifierSharedKey(CLIENT_SECRET);	// APPLICATION SECRET
	this->live->responseType() = RESPONSE_TYPE;					// RESPONSE TYPE
	this->live->setAuthorizationUrl(QUrl(AUTHORIZATION_URL));	// AUTHORIZATION URL
	this->live->setTokenUrl(QUrl(ACCESSTOKEN_URL));				// TOKEN URL

	// SCOPE
	QSet<QByteArray> scope;
	const QStringList &list = QString(SCOPE).split(" ");
	for (const QString &item : list) { scope.insert(item.toUtf8()); }
	this->live->setRequestedScopeTokens(scope);

	//this->live->setPkceMethod(QOAuth2AuthorizationCodeFlow::PkceMethod::S256);


	// Open native browser when url is built (triggered into authorizeWithBrowser)
	QObject::connect(this->live, &QOAuth2AuthorizationCodeFlow::authorizeWithBrowser, this, [&](const QUrl &url) {		// this to open webview
		qDebug() << "URL Built:" << url;
		webViewLoader->setProperty("url", url);
	});
	
	
	this->live->setModifyParametersFunction([this](QAbstractOAuth2::Stage stage, QMultiMap<QString, QVariant> *parameters) {
		if (parameters->contains("redirect_uri")) { parameters->replace("redirect_uri", REDIRECT_URI); }		// https://bugreports.qt.io/browse/QTBUG-133999 - to change "localhost" to "127.0.0.1"

		if (stage == QAbstractOAuth2::Stage::RequestingTemporaryCredentials)			// stage when building url just before opening the browser with the very first url
		{
			qDebug() << "STAGE: RequestingTemporaryCredentials";
			for (auto it = parameters->cbegin(), end = parameters->cend(); it != end; ++it) {
				qDebug().noquote() << it.key() << "=>" << it.value();
			}
			qDebug() << "--------------";
		}
		else if (stage == QAbstractOAuth2::Stage::RequestingAuthorization)			// stage when building url just before opening the browser with the very first url
		{
			// The only way to get refresh_token from Google Cloud
			parameters->insert("grant_type", "urn:ietf:params:oauth:grant-type:device_code");
			// 		parameters->insert("prompt", "consent");							// Param required to get data everytime
			qDebug() << "STAGE: RequestingAuthorization";
			for (auto it = parameters->cbegin(), end = parameters->cend(); it != end; ++it) {
				qDebug().noquote() << it.key() << "=>" << it.value();
			}
			qDebug() << "--------------";
		}
		else if (stage == QAbstractOAuth2::Stage::RequestingAccessToken)
		{
			// 		// Percent-decode the "code" parameter so Google can match it
			// 		QByteArray code = parameters->value("code").toByteArray();
			// 		parameters->replace("code", QUrl::fromPercentEncoding(code));		// need to fix the URL syntat to manage spaces
			qDebug() << "STAGE: RequestingAccessToken";
			for (auto it = parameters->cbegin(), end = parameters->cend(); it != end; ++it) {
				qDebug().noquote() << it.key() << "=>" << it.value();
			}
			qDebug() << "--------------";
		}
		if (stage == QAbstractOAuth2::Stage::RefreshingAccessToken)			// stage when building url just before opening the browser with the very first url
		{
			qDebug() << "STAGE: RefreshingAccessToken";
			for (auto it = parameters->cbegin(), end = parameters->cend(); it != end; ++it) {
				qDebug().noquote() << it.key() << "=>" << it.value();
			}
			qDebug() << "--------------";
		}
	});


	// Initial Callback Received
	QObject::connect(this->live, &QOAuth2AuthorizationCodeFlow::authorizationCallbackReceived, this, [&](const QVariantMap &data) {
		if (data.contains("error")) {
			//qCritical() << "ERROR:" << data.value("error");
			QJsonObject returnObject;
				returnObject.insert("status", "error");
				returnObject.insert("error", data.value("error").toString());
			QJsonDocument returnDocument(returnObject);
			setLiveLoginData(returnDocument.toJson(QJsonDocument::Compact));  // or QJsonDocument::Indented
			replyHandler->close();
		}
		else if (!data.contains("code")) {
			qCritical() << "Unexpected reply (should receive code, but does not):" << QJsonDocument::fromVariant(data).toJson(QJsonDocument::Indented);
			qCritical() << "therefore i HANG here";
			replyHandler->close();
		}
		else {
			// code exist, QOAuth2AuthorizationCodeFlow proceeds on its own to get token from code
		}
	});


	// SUCCESS LOGIN
	QObject::connect(this->live, &QOAuth2AuthorizationCodeFlow::granted, this, [this](){
		//qDebug() << "SUCCESS";
		QJsonObject returnObject;
			returnObject.insert("status", "success");
			returnObject.insert("token", this->live->token());
			returnObject.insert("refreshToken", this->live->refreshToken());
			returnObject.insert("expire", this->live->expirationAt().toMSecsSinceEpoch());
		QJsonDocument returnDocument(returnObject);
		setLiveLoginData(returnDocument.toJson(QJsonDocument::Compact));  // or QJsonDocument::Indented
		QMetaObject::invokeMethod(webViewLoader, "closeWebview");	// close WebView
		replyHandler->close();
	});
}

// Invoked externally to initiate
void LiveSSO::authenticate(QObject *root)
{
	// SSL Configuration - https://bugreports.qt.io/browse/QTBUG-137155
	// QSslConfiguration configuration(QSslConfiguration::defaultConfiguration());

	// 	// SSL Private Key
	// 	QString keyFileName = QStringLiteral(":/airgame-console/resources/ssl/localhost-privatekey.pem");
	// 	QFile keyFile(keyFileName);
	// 	QFileInfo keyFileInfo(keyFile);
	// 	if (keyFile.open(QIODevice::ReadOnly)) {
	// 		QSslKey key(keyFile.readAll(), QSsl::Rsa, QSsl::Pem, QSsl::PrivateKey);
	// 		if (!key.isNull()) { configuration.setPrivateKey(key); }
	// 		else { qCritical() << "Could not parse key: " << keyFileInfo.absoluteFilePath(); }
	// 	}
	// 	else { qCritical() << "Could not find key: " << keyFileInfo.absoluteFilePath(); }

	// 	// SSL Certificate
	// 	QString certificateFileName = QStringLiteral(":/airgame-console/resources/ssl/localhost-certificate.pem");
	// 	QFile certificateFile(certificateFileName);
	// 	QFileInfo certificateFileInfo(certificateFile);
	// 	QList<QSslCertificate> localCert = QSslCertificate::fromPath(certificateFileName);
	// 	if (!localCert.isEmpty() && !localCert.first().isNull()) { configuration.setLocalCertificate(localCert.first()); }
	// 	else { qCritical() << "Could not find certificate: " << certificateFileInfo.absoluteFilePath(); }



	// Reply Handler
	replyHandler = new QOAuthHttpServerReplyHandler(hostAddress, static_cast<quint16>(QUrl(REDIRECT_URI).port()), this);
	replyHandler->setCallbackText(REPLYMESSAGE);
	//replyHandler->setCallbackHost(QHostAddress(QStringLiteral("localhost")));
	this->live->setReplyHandler(replyHandler);

	// for reopening of WebView, i need to re-listen() - either with configuration for SSL, or without for TLS
	if (!replyHandler->isListening()) { replyHandler->listen(); }						// TLS
	//if (!replyHandler->isListening()) { replyHandler->listen(configuration, hostAddress, static_cast<quint16>(QUrl(REDIRECT_URI).port())); }		// SSL - https://bugreports.qt.io/browse/QTBUG-137155

	if (replyHandler->isListening()) {
		findWebViewLoader(root);
		this->live->setState(randomizeState());		// Random STATE
		this->live->grant();						// Initialize OAUTH2 Workflow
	}
	else { qDebug() << "ReplyHandler ERROR"; }
}


// Destroy
LiveSSO::~LiveSSO()
{
	delete this->live;
}
