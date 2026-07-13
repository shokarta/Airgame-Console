#include "../XboxFunctions.h"
#include <QGuiApplication>
#include <QQuickWindow>
#include <QtConcurrent>
#include <QtConcurrentRun>


TitleFunctions::TitleFunctions(QObject *parent) : QObject(parent)
{
}


void TitleFunctions::getFullList()
{
	if (!qmlFullGameListModel || !qmlFilterecGameListModel || !qmlCategoryListModel) { initializeModels(); }	// first try to assign
	if (!qmlFullGameListModel || !qmlFilterecGameListModel || !qmlCategoryListModel) { qWarning() << "models not found"; return; }		// stop if models are not known

	// QSetitngs xcloudToken to JSON:
	QJsonDocument xcloudToken = QJsonDocument::fromVariant(settings.value("xcloudToken"));


	// first clear the model	- onCountChanged triggers once (after clear)
	QMetaObject::invokeMethod(qmlFullGameListModel, "clear", Qt::QueuedConnection);


	// default region from offering
	QJsonArray regions = xcloudToken["offeringSettings"].toObject()["regions"].toArray();
	QString baseUri;
	for (const auto &v : regions) {
		auto region = v.toObject();
		if (region["isDefault"].toBool()) {
			baseUri = region["baseUri"].toString();
			break;
		}
	}

	QNetworkRequest req;
		req.setUrl(baseUri + "/v2/titles");
		req.setRawHeader("Authorization", xcloudToken["tokenType"].toString().toUtf8() + " " + xcloudToken["gsToken"].toString().toUtf8());	// settings.value("xcloudToken").toMap().value("gsToken").toByteArray()
		req.setRawHeader("Content-Type", "application/json");
		if (settings.value("preferredforceIp").toString() != "") { req.setRawHeader("X-Forwarded-For", settings.value("preferredforceIp").toByteArray()); }
	QNetworkAccessManager *manager = new QNetworkAccessManager();
		manager->get(req);


	// REPLY RECEIVED
	QObject::connect(manager, &QNetworkAccessManager::finished, this, [this](QNetworkReply *reply) {

		QByteArray serverReply = reply->readAll();
		reply->deleteLater();

		QtConcurrent::run([=] {		// QtConcurrent::run([=] {

			QVariantList list;

	//		qDebug() << serverReply;
			QJsonDocument replyDocument = QJsonDocument::fromJson(serverReply);
			QJsonArray results = replyDocument["results"].toArray();


			for (const QJsonValue &singleValue : std::as_const(results)) {
				QJsonObject details = singleValue.toObject().value("details").toObject();
					QString storeId = details["productId"].toString();
					QJsonArray userPrograms = details["userPrograms"].toArray();

				// Build the QVariantMap that QML understands
				QVariantMap item;
					item["storeId"] = storeId;
					item["userPrograms"] = userPrograms.toVariantList();
					item["visible"] = true;

				list.append(item);
				//QMetaObject::invokeMethod(qmlFullGameListModel, "append", Qt::QueuedConnection, Q_ARG(QVariant, QVariant(item)));
			}


			// All data is prepared → send to GUI
			QMetaObject::invokeMethod(
				this,
				this, list {
					replaceQmlModel(list);
				},
				Qt::QueuedConnection
			);
		});
	});

}


void TitleFunctions::initializeModels()
{
	// Find QML window
	QQuickWindow *window = qobject_cast<QQuickWindow*>(qApp->allWindows().first());
	if (!window) { qWarning() << "Window is not a QQuickWindow!"; return; }

	// Find models by objectName
	qmlFullGameListModel = window->findChild<QObject*>("fullGameList", Qt::FindChildrenRecursively);
	qmlFilterecGameListModel = window->findChild<QObject*>("filteredGameList", Qt::FindChildrenRecursively);
	qmlCategoryListModel = window->findChild<QObject*>("categoryList", Qt::FindChildrenRecursively);

	//qDebug() << "fullGameList =" << qmlFullGameListModel;
	//qDebug() << "filteredGameList =" << qmlFilterecGameListModel;
	//qDebug() << "categoryList =" << qmlCategoryListModel;

	if (!qmlFullGameListModel) { qWarning() << "fullGameList Model not found!"; }
	if (!qmlFilterecGameListModel) { qWarning() << "filteredGameList Model not found!"; }
	if (!qmlCategoryListModel) { qWarning() << "categoryList Model not found!"; }
}


// Destroy
// TitleFunctions::~TitleFunctions()
// {
	// do i need somehting here?
// }