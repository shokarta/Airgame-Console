#pragma once

#include <QObject>
#include <QAbstractListModel>
#include <QJsonObject>
#include <QJsonArray>
#include <QtConcurrent>
#include <QCoreApplication>
#include <QtConcurrentRun>
#include <QTimer>
#include <QSettings>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QElapsedTimer>
#include <QSortFilterProxyModel>


// =============================================================
// Model #1 — Full Game List Model
// =============================================================
class GameListModelFull : public QAbstractListModel
{
    Q_OBJECT

    //Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(bool titleListSimpleFinished     READ titleListSimpleFinished    NOTIFY titleListSimpleFinishedChanged)
    Q_PROPERTY(bool titleListModerateFinished   READ titleListModerateFinished  NOTIFY titleListModerateFinishedChanged)
    Q_PROPERTY(bool titleListComplexFinished    READ titleListComplexFinished   NOTIFY titleListComplexFinishedChanged)
    Q_PROPERTY(QVariantList categories          READ categories                 NOTIFY categoriesChanged)


    public:
        explicit GameListModelFull(QObject *parent = nullptr) : QAbstractListModel(parent), m_network(this) {
            connect(this, &QAbstractItemModel::rowsInserted, this, &GameListModelFull::onRowCountChanged);
            connect(this, &QAbstractItemModel::rowsRemoved, this, &GameListModelFull::onRowCountChanged);
            connect(this, &QAbstractItemModel::modelReset, this, &GameListModelFull::onRowCountChanged);
        }


    void onRowCountChanged() {
        qDebug() << "m_gameListModelFull size changed:" << m_gameListModelFull.size();
    }


        Q_INVOKABLE QVariantList rawData() const { return m_gameListModelFull; }

        //int count() const { return m_gameListModelFull.size(); }
        bool titleListSimpleFinished() const { return m_titleListSimpleFinished; }
        bool titleListModerateFinished() const { return m_titleListModerateFinished; }
        bool titleListComplexFinished() const { return m_titleListComplexFinished; }
        QVariantList categories() const { return m_categories; }


        // Roles
        enum Roles {
            StoreIdRole = Qt::UserRole + 1,
            UserProgramsRole,
            ProductTitleRole,
            XCloudTitleIdRole,
            XboxTitleIdRole,
            ProductDescriptionRole,
            ProductDescriptionShortRole,
            PublisherNameRole,
            DeveloperNameRole,
            Image_TileRole,
            Image_PosterRole,
            Image_HeroRole,
            Image_TitledHeroRole,
            ScreenshotsRole,
            TrailersRole,
            IsDemoRole,
            InputsRole,
            HasControllerRole,
            HasMouseAndKeyboardRole,
            CategoriesRole,
            LocalizedCategoriesRole,
            AttributesRole,
            ContentRatingRole,
            XCloudOfferingsRole,
            RequiresGoldDisclaimerRole,
            RequiresGoldForMultiplayerDisclaimerRole,
            OriginalReleaseDateRole,
            ConsoleComingSoonDate,
            LanguageSupportRole,
            RegularPriceRole,
            SalePriceRole,
            IsFreeRole,
            DiscountRole,
            ReviewScoreRole,
            ReviewCountRole,
            XPAEnabledRole,
            AvailablePlatformsRole,
            AddedGamePassEssentialRole,
            AddedGamePassPremiumRole,
            AddedGamePassUltimateRole,
            AddedEAPlayRole,
            AddedUbisoftPlusRole,
            LastTimePlayedRole,
            IsFavouritedRole
        };
        Q_ENUM(Roles)

        // =========================================================================
        // REQUIRED: rowCount() — otherwise model is abstract
        // =========================================================================
        int rowCount(const QModelIndex &parent = QModelIndex()) const override {
            Q_UNUSED(parent)
            return m_gameListModelFull.size();
        }

        // =========================================================================
        // REQUIRED: data() — otherwise model is abstract
        // =========================================================================
        Q_INVOKABLE QVariant data(const QModelIndex &index, int role) const override {
            const QVariantMap &row = m_gameListModelFull[index.row()].toMap();

            switch (role) {
                case StoreIdRole:                               return row["storeId"];
                case UserProgramsRole:                          return row["userPrograms"];
                case ProductTitleRole:                          return row["productTitle"];
                case XCloudTitleIdRole:                         return row["xcloudTitleId"];
                case XboxTitleIdRole:                           return row["xboxTitleId"];
                case ProductDescriptionRole:                    return row["productDescription"];
                case ProductDescriptionShortRole:               return row["productDescriptionShort"];
                case PublisherNameRole:                         return row["publisherName"];
                case DeveloperNameRole:                         return row["developerName"];
                case Image_TileRole:                            return row["image_Tile"];
                case Image_PosterRole:                          return row["image_Poster"];
                case Image_HeroRole:                            return row["image_Hero"];
                case Image_TitledHeroRole:                      return row["image_TitledHero"];
                case ScreenshotsRole:                           return row["screenshots"];
                case TrailersRole:                              return row["trailers"];
                case IsDemoRole:                                return row["isDemo"];
                case InputsRole:                                return row["inputs"];
                case HasControllerRole:                         return row["hasController"];
                case HasMouseAndKeyboardRole:                   return row["hasMouseAndKeyboard"];
                case CategoriesRole:                            return row["categories"];
                case LocalizedCategoriesRole:                   return row["localizedCategories"];
                case AttributesRole:                            return row["attributes"];
                case ContentRatingRole:                         return row["contentRating"];
                case XCloudOfferingsRole:                       return row["xCloudOfferings"];
                case RequiresGoldDisclaimerRole:                return row["requiresGoldDisclaimer"];
                case RequiresGoldForMultiplayerDisclaimerRole:  return row["requiresGoldForMultiplayerDisclaimer"];
                case OriginalReleaseDateRole:                   return row["originalReleaseDate"];
                case ConsoleComingSoonDate:                     return row["consoleComingSoonDate"];
                case LanguageSupportRole:                       return row["languageSupport"];
                case RegularPriceRole:                          return row["regularPrice"];
                case SalePriceRole:                             return row["salePrice"];
                case IsFreeRole:                                return row["isFree"];
                case DiscountRole:                              return row["discount"];
                case ReviewScoreRole:                           return row["reviewScore"];
                case ReviewCountRole:                           return row["reviewCount"];
                case XPAEnabledRole:                            return row["xPAEnabled"];
                case AvailablePlatformsRole:                    return row["availablePlatforms"];
                case AddedGamePassEssentialRole:                return row["addedGamePassEssential"];
                case AddedGamePassPremiumRole:                  return row["addedGamePassPremium"];
                case AddedGamePassUltimateRole:                 return row["addedGamePassUltimate"];
                case AddedEAPlayRole:                           return row["addedEAPlay"];
                case AddedUbisoftPlusRole:                      return row["addedUbisoftPlus"];
                case LastTimePlayedRole:                        return row["lastTimePlayed"];
                case IsFavouritedRole:                          return row["isFavourited"];
            }
            return {};
        }

        // =========================================================================
        // list of roles
        // =========================================================================
        QHash<int, QByteArray> roleNames() const override {
            QHash<int, QByteArray> roles;
                roles[StoreIdRole] = "storeId";
                roles[UserProgramsRole] = "userPrograms";
                roles[ProductTitleRole] = "productTitle";
                roles[XCloudTitleIdRole] = "xcloudTitleId";
                roles[XboxTitleIdRole] = "xboxTitleId";
                roles[ProductDescriptionRole] = "productDescription";
                roles[ProductDescriptionShortRole] = "productDescriptionShort";
                roles[PublisherNameRole] = "publisherName";
                roles[DeveloperNameRole] = "developerName";
                roles[Image_TileRole] = "image_Tile";
                roles[Image_PosterRole] = "image_Poster";
                roles[Image_HeroRole] = "image_Hero";
                roles[Image_TitledHeroRole] = "image_TitledHero";
                roles[ScreenshotsRole] = "screenshots";
                roles[TrailersRole] = "trailers";
                roles[IsDemoRole] = "isDemo";
                roles[InputsRole] = "inputs";
                roles[HasControllerRole] = "hasController";
                roles[HasMouseAndKeyboardRole] = "hasMouseAndKeyboard";
                roles[CategoriesRole] = "categories";
                roles[LocalizedCategoriesRole] = "localizedCategories";
                roles[AttributesRole] = "attributes";
                roles[ContentRatingRole] = "contentRating";
                roles[XCloudOfferingsRole] = "xCloudOfferings";
                roles[RequiresGoldDisclaimerRole] = "requiresGoldDisclaimer";
                roles[RequiresGoldForMultiplayerDisclaimerRole] = "requiresGoldForMultiplayerDisclaimer";
                roles[OriginalReleaseDateRole] = "originalReleaseDate";
                roles[ConsoleComingSoonDate] = "consoleComingSoonDate";
                roles[LanguageSupportRole] = "languageSupport";
                roles[RegularPriceRole] = "regularPrice";
                roles[SalePriceRole] = "salePrice";
                roles[IsFreeRole] = "isFree";
                roles[DiscountRole] = "discount";
                roles[ReviewScoreRole] = "reviewScore";
                roles[ReviewCountRole] = "reviewCount";
                roles[XPAEnabledRole] = "xPAEnabled";
                roles[AvailablePlatformsRole] = "availablePlatforms";
                roles[AddedGamePassEssentialRole] = "addedGamePassEssential";
                roles[AddedGamePassPremiumRole] = "addedGamePassPremium";
                roles[AddedGamePassUltimateRole] = "addedGamePassUltimate";
                roles[AddedEAPlayRole] = "addedEAPlay";
                roles[AddedUbisoftPlusRole] = "addedUbisoftPlus";
                roles[LastTimePlayedRole] = "lastTimePlayed";
                roles[IsFavouritedRole] = "isFavourited";
            return roles;
        }


        // get index of storeId
        Q_INVOKABLE int getIndex(const QString &storeId = nullptr) {
            if (storeId == nullptr) { return -1; }

            for (int i=0; i<m_gameListModelFull.size(); i++) {
                QVariantMap entry = m_gameListModelFull.at(i).toMap();
                if (entry.value("storeId").toString() == storeId) { return i; }
            }
            return -1;
        }

        // get data of storeId
        Q_INVOKABLE QVariant getData(const QString &storeId = nullptr) {
            if (storeId == nullptr) { return {}; }

            for (int i=0; i<m_gameListModelFull.size(); i++) {
                QVariantMap entry = m_gameListModelFull.at(i).toMap();
                if (entry.value("storeId").toString() == storeId) { return entry; }
            }
            return {};
        }

        // Reset model entirely
        Q_INVOKABLE void createCategories(const QVariantList &items) {
            QVariantList result;
                result.reserve(m_categories.size() + items.size());

            QSet<QString> seen;
                seen.reserve(m_categories.size() + items.size());

            auto processList = [&](const QVariantList &list) {
                for (const QVariant &v : list) {
                    QVariantMap map = v.toMap();
                    const QString category = map.value("categoryName").toString();

                    if (!seen.contains(category)) {
                        seen.insert(category);
                        result.append(map);
                    }
                }
            };

            processList(m_categories);
            processList(items);


            // sort
            std::sort(result.begin(), result.end(), [](const QVariant &a, const QVariant &b) {
                QVariantMap ma = a.toMap();
                QVariantMap mb = b.toMap();

                QString nameA = ma.value("categoryNameLocalized").toString();
                QString nameB = mb.value("categoryNameLocalized").toString();

                QString keyA = ma.value("categoryName").toString();
                QString keyB = mb.value("categoryName").toString();

                // Force "other" to the end
                if (keyA == "Other") { return false; }  // a should go AFTER b
                if (keyB == "Other") { return true; }   // b should go AFTER a

                // Normal alphabetical sort
                return nameA.localeAwareCompare(nameB) < 0;
            });

            // return
            if (m_categories != result) {
                m_categories = result;
                emit categoriesChanged();
            }
        }

        // Reset model entirely
        Q_INVOKABLE void setModel(const QVariantList &items) {

            beginResetModel();
            if (items.size() > 0) { m_gameListModelFull = items; }
            endResetModel();

            updateFullList("simple");
//            updateFullList("moderate");
//            updateFullList("complex");

//            resetTemporaryList();
        }

        // add roles
        Q_INVOKABLE void updateModel(const QString complexity, const QVariantList &items) {

            //beginResetModel();
            m_gameListModelFull = items;
            //endResetModel();

            QVector<int> changedRoles;
                if (complexity == "simple") { changedRoles = {ProductTitleRole, XCloudTitleIdRole, XboxTitleIdRole, PublisherNameRole, Image_TileRole, Image_PosterRole, CategoriesRole, LocalizedCategoriesRole, IsDemoRole}; }
                else if (complexity == "moderate") { changedRoles = {ProductDescriptionRole, ProductDescriptionShortRole, DeveloperNameRole, Image_HeroRole, Image_TitledHeroRole, ScreenshotsRole, TrailersRole, AttributesRole, ContentRatingRole, XCloudOfferingsRole, RequiresGoldDisclaimerRole, RequiresGoldForMultiplayerDisclaimerRole, LanguageSupportRole, AvailablePlatformsRole, InputsRole, HasControllerRole, HasMouseAndKeyboardRole, AddedGamePassEssentialRole, AddedGamePassPremiumRole, AddedGamePassUltimateRole, AddedEAPlayRole, AddedUbisoftPlusRole }; }
                else if (complexity == "complex") { changedRoles = {OriginalReleaseDateRole, ConsoleComingSoonDate, ReviewScoreRole, ReviewCountRole, XPAEnabledRole, RegularPriceRole, SalePriceRole, IsFreeRole, DiscountRole}; }
            emit dataChanged(index(0, 0), index(rowCount()-1, 0), changedRoles);

            //emit modelChanged();
            //emit countChanged();

            if (complexity == "simple") { m_titleListSimpleFinished = true; emit titleListSimpleFinishedChanged(); }
            else if (complexity == "moderate") { m_titleListModerateFinished = true; emit titleListModerateFinishedChanged(); }
            else if (complexity == "complex") { m_titleListComplexFinished = true; emit titleListComplexFinishedChanged(); }
        }


        // get array of storeId
        Q_INVOKABLE QStringList storeIdList() const {
            QStringList ids;
            for (const QVariant &v : m_gameListModelFull) {
                QVariantMap map = v.toMap();
                ids.append(map.value("storeId").toString());
            }
            return ids;
        }

        // list of storeId which is included in full main model
        Q_INVOKABLE void setUpdateList(QVariantList inputList = QVariantList()) {
            if (inputList.size() == 0) { return; }

            QStringList temporaryOutput;

            for (int i=0; i<inputList.size(); i++) {
                QVariantMap updateItem = inputList.at(i).toMap();
                QString storeId = updateItem.value("storeId").toString();

                for (int j=0; j<m_gameListModelFull.size(); j++) {
                    QVariantMap fullItem = m_gameListModelFull.at(j).toMap();

                    if (fullItem.value("storeId").toString() == storeId) {
                        QVector<int> changedRoles;

                        fullItem["userPrograms"] = QVariantList();
                        if (updateItem.contains("lastTimePlayed"))  { fullItem["lastTimePlayed"] = updateItem.value("lastTimePlayed");  changedRoles.append(LastTimePlayedRole); }
                        if (updateItem.contains("isFavourited"))    { fullItem["isFavourited"] = updateItem.value("isFavourited");      changedRoles.append(IsFavouritedRole); }

                        m_gameListModelFull[j] = fullItem;    // save updated row back into m_gameListModelFull

                        emit dataChanged(index(j, 0), index(j, 0), changedRoles);

                        break; // stop searching
                    }
                }

                temporaryOutput.append(storeId);
            }

            m_gameListModelTemporary = temporaryOutput;
            setModel(QVariantList());
        }

        // list of storeId which is not included in full main model
        Q_INVOKABLE void setTemporaryList(QVariantList inputList = QVariantList()) {
            if (inputList.size() == 0) { return; }

            QVariantList copyOfFullList = m_gameListModelFull;
            QStringList temporaryOutput = {};

            for (int i=0; i<inputList.size(); i++) {
                QVariantMap inputItem = inputList.at(i).toMap();
                    inputItem["storeId"] = inputItem.value("storeId", "");
                    inputItem["userPrograms"] = inputItem.value("userPrograms", QVariantList());
                    inputItem["lastTimePlayed"] = inputItem.value("lastTimePlayed", QDateTime());
                    inputItem["isFavourited"] = inputItem.value("isFavourited", false);
                inputList[i] = inputItem;       // save back to inputList

                temporaryOutput.append(inputItem["storeId"].toString());        // append to temporaryOutput

                copyOfFullList.append(inputItem);       // append to copyOfFullList
            }

            m_gameListModelTemporary = temporaryOutput;
            setModel(copyOfFullList);
        }

        // reset temporary list of extra storeId(s)
        Q_INVOKABLE void resetTemporaryList() {
            m_gameListModelTemporary = {};
        }

        // get full initial list
        Q_INVOKABLE void getFullList() {

            // QSetitngs xcloudToken to JSON:
            QJsonDocument xcloudToken = QJsonDocument::fromVariant(settings.value("xcloudToken"));

            // default region from offering
            QJsonArray regions = xcloudToken["offeringSettings"].toObject()["regions"].toArray();
            QString baseUri;
            for (const auto &v : std::as_const(regions)) {
                auto region = v.toObject();
                if (region["isDefault"].toBool()) {
                    baseUri = region["baseUri"].toString();
                    break;
                }
            }

            QNetworkRequest req;
                req.setUrl(baseUri + "/v2/titles");
                req.setRawHeader("Authorization", xcloudToken["tokenType"].toString().toUtf8() + " " + xcloudToken["gsToken"].toString().toUtf8());
                req.setRawHeader("Content-Type", "application/json");
                if (settings.value("preferredforceIp").toString() != "") { req.setRawHeader("X-Forwarded-For", settings.value("preferredforceIp").toByteArray()); }
            QNetworkAccessManager *manager = new QNetworkAccessManager();
                manager->get(req);

            // Reply received from QNetworkRequest
            QObject::connect(manager, &QNetworkAccessManager::finished, this, [this](QNetworkReply *reply) {
                QByteArray serverReply = reply->readAll();
                reply->deleteLater();

                QFutureWatcher<GetListResult> *watcher = new QFutureWatcher<GetListResult>(this);     // watcher

                // this runs in QtConcurent background thread
                QFuture<GetListResult> futureGetList = QtConcurrent::run([serverReply, this]() -> GetListResult {
                    GetListResult sendResult;

                    QJsonParseError jsonError;
                    QJsonDocument replyDocument = QJsonDocument::fromJson(serverReply, &jsonError);
                    if (jsonError.error != QJsonParseError::NoError) {
                        qWarning() << "JSON parse failed in getFullList():" << jsonError.errorString();
                        qWarning() << "Raw reply:" << serverReply;
                        qWarning() << "-------------------------------------------------------------------";
                        return sendResult;
                    }

                    QJsonArray results = replyDocument["results"].toArray();

                    QVariantList list;
                        list.reserve(results.size());

                    for (int i=0; i<results.size(); i++) {
                        QJsonObject details = results.at(i).toObject().value("details").toObject();

                        QVariantMap item;
                            item["storeId"] = details["productId"].toString().toUpper();

                        // Convert userPrograms into QStringList
                        QVariantList userPrograms;
                        QJsonArray userProgramsArray = details["userPrograms"].toArray();
                        for (int i=0; i<userProgramsArray.size(); i++) {
                            userPrograms.append(userProgramsArray.at(i).toString());
                        }
                        item["userPrograms"] = userPrograms;
                        item["lastTimePlayed"] = QDateTime();
                        list.append(item);
                    }

                    sendResult.list = list;
                    return sendResult;
                });

                // in here to continue on main UI after QFuture finished
                QObject::connect(watcher, &QFutureWatcher<GetListResult>::finished, this, [this, watcher]() {
                    GetListResult resultGetList = watcher->result();
                    watcher->deleteLater();

                    setModel(resultGetList.list);
                });

                watcher->setFuture(futureGetList);
            });
        }

        Q_INVOKABLE void updateFullList(QString complexity = nullptr) {
            if (complexity == nullptr) { qWarning() << "unexpected complexity:" << complexity; return; }

            // Hydration (TODO: BaysideLowTopaz0)
            QString hydration = [&]{
                if (complexity == "simple")     return QString("RemoteLowJade0");
                if (complexity == "moderate")   return QString("RemoteHighSapphire0");
                if (complexity == "complex")    return QString("MobileDetailsForConsole");
                return QString();
            }();

            // POST Data
            QStringList modelData;
                if (m_gameListModelTemporary.size() > 0) { modelData = m_gameListModelTemporary; }
                else { modelData = storeIdList(); }
            QByteArray postData;
                if (m_gameListModelTemporary.size() > 0) { postData = QJsonDocument(QJsonObject{{"Products", QJsonArray::fromStringList(modelData)}}).toJson(QJsonDocument::Compact); }
                else { postData = QJsonDocument(QJsonObject{{"Products", QJsonArray::fromStringList(modelData)}}).toJson(QJsonDocument::Compact); }

            QNetworkRequest req;
                req.setUrl("https://catalog.gamepass.com/v3/products?market=" + settings.value("preferredMarket").toString() + "&language=" + settings.value("preferredLanguage").toString() + "&hydration=" + hydration);
                req.setRawHeader("Content-Type", "application/json");
                req.setRawHeader("ms-cv", settings.value("preferredCorrelationVector").toByteArray());
                req.setRawHeader("calling-app-name", settings.value("preferredCallingAppName").toByteArray());
                req.setRawHeader("calling-app-version", settings.value("preferredCallingAppVersion").toByteArray());
                if (settings.value("preferredforceIp").toString() != "") { req.setRawHeader("X-Forwarded-For", settings.value("preferredforceIp").toByteArray()); }

            QNetworkReply *reply = m_network.post(req, postData);

            // Reply received from QNetworkRequest
            QObject::connect(reply, &QNetworkReply::finished, this, [this, reply, complexity, req, postData] {
                QByteArray serverReply = reply->readAll();
                reply->deleteLater();

                QVariantList modelSnapshot = m_gameListModelFull;               // snapshot
                QFutureWatcher<UpdatedListResult> *watcher = new QFutureWatcher<UpdatedListResult>(this);     // watcher

                // this runs in QtConcurent background thread
                QFuture<UpdatedListResult> futureUpdatedList = QtConcurrent::run([serverReply, modelSnapshot, complexity, this, req, postData] () -> UpdatedListResult {
                    UpdatedListResult sendResult;
                    sendResult.merged = modelSnapshot;
                    sendResult.categories = {};
                    sendResult.complexity = complexity;

                    QJsonParseError jsonError;
                    QJsonDocument replyDocument = QJsonDocument::fromJson(serverReply, &jsonError);
                    if (jsonError.error != QJsonParseError::NoError) {
                        qWarning() << "JSON parse failed in updateFullList(" << complexity << "):" << req.url() << jsonError.errorString() << postData;
                        qWarning() << "Raw reply:" << serverReply;
                        sendResult.error = true;
                        return sendResult;
                    }


                    QJsonObject products = replyDocument["Products"].toObject();

                    // Step 1 — build lookup table
                    QHash<QString, QVariantMap> updatedData;
                    updatedData.reserve(products.size());
                    for (auto it = products.begin(); it != products.end(); it++) {
                        updatedData.insert(it.key().toUpper(), it.value().toObject().toVariantMap());
                    }

                    // Step 2 — merge into model
                    for (QVariant &rowVar : sendResult.merged) {
                        QVariantMap row = rowVar.toMap();
                        QString storeId = row["storeId"].toString();

                        // skipping existing m_gameListModelFull data which does not have existing storeId in serverReply
                        if (!updatedData.contains(storeId)) {
                            //qWarning() << storeId << not found in serverReply;         // this triggers upon update with new storeId(s)... which is not desired
                            continue;           // goes to next irretation
                        }

                        const QVariantMap &extra = updatedData[storeId];

//if (extra.value("StoreId", "").toString() == "9P42CF3NF4K3") {
//if (storeId == "9P42LWGMC7K4") {
//    qDebug() << complexity;

//    QJsonObject jsonObj = QJsonObject::fromVariantMap(extra);
//    QJsonDocument jsonDoc(jsonObj);
//    qDebug().noquote() << jsonDoc.toJson(QJsonDocument::Compact);
//}

                        // COMPLEXITY SPECIFIC MERGE LOGIC
                        if (complexity == "simple") {

                            // Product Title
                            row["productTitle"] = extra.value("ProductTitle", "").toString().remove(" (Game Preview)");

                            // XCloud Title Id
                            row["xcloudTitleId"] = extra.value("XCloudTitleId", "").toString();

                            // Xbox Title Id
                            row["xboxTitleId"] = extra.value("XboxTitleId", "").toString();

                            // Publisher Name
                            row["publisherName"] = extra.value("PublisherName", "").toString().trimmed();

                            // Image Tile
                            const QString image_tile = extra.value("Image_Tile").toMap().value("URL").toString();
                            row["image_Tile"] = image_tile.isEmpty() ? "" : "https:" + image_tile;

                            // Image Poster
                            const QString image_poster = extra.value("Image_Poster").toMap().value("URL").toString();
                            row["image_Poster"] = image_poster.isEmpty() ? "" : "https:" + image_poster;

                            // Categories
                            row["categories"] = extra.value("Categories", QStringList{}).toStringList();

                            // Localized Categories
                            row["localizedCategories"] = extra.value("LocalizedCategories", QStringList{}).toStringList();

                            // Demo
                            row["isDemo"] = extra.value("ProductTitle").toString().endsWith("(Game Preview)", Qt::CaseSensitive);



                            // Categories
                            for (int i=0; i<row["categories"].toStringList().size(); i++) {
                                const QString cat = row["categories"].toStringList()[i];

                                bool alreadyExists = false;

                                // Check if category already exists
                                for (int i=0; i<sendResult.categories.size(); i++) {
                                    QVariantMap existingItem = sendResult.categories.at(i).toMap();
                                    if (existingItem.value("categoryName").toString() == cat) {
                                        alreadyExists = true;
                                        break;
                                    }
                                }

                                // Create QVariantMap for this category
                                if (!alreadyExists) {
                                    QVariantMap newItem;
                                    newItem["categoryName"] = cat;
                                    newItem["categoryNameLocalized"] = row["localizedCategories"].toStringList()[i];
                                    newItem["available"] = true;
                                    newItem["selected"] = true;
                                    sendResult.categories.append(newItem);
                                }
                            }
                        }

                        else if (complexity == "moderate") {

                            // Product Description
                            row["productDescription"] = extra.value("ProductDescription", "").toString();

                            // Product Description Short
                            row["productDescriptionShort"] = extra.value("ProductDescriptionShort", "").toString();

                            // Developer Name
                            row["developerName"] = extra.value("DeveloperName", "").toString().trimmed();

                            // Image Hero
                            const QString image_hero = extra.value("Image_Hero").toMap().value("URL").toString();
                            row["image_Hero"] = image_hero.isEmpty() ? "" : "https:" + image_hero;

                            // Image TitledHero
                            const QString image_titledhero = extra.value("Image_TitledHero").toMap().value("URL").toString();
                            row["image_TitledHero"] = image_titledhero.isEmpty() ? "" : "https:" + image_titledhero;

                            // Screenshots
                            row["screenshots"] = extra.value("Screenshots", QVariantList{}).toList();
if (storeId == "9P8LR42PTRGJ") {
    QJsonArray jsonArray = QJsonArray::fromVariantList(extra.value("Screenshots").toList());
    QJsonDocument doc(jsonArray);
    //qDebug().noquote() << storeId << "screenshots:" << doc.toJson(QJsonDocument::Compact);
}

                            // Trailers
                            row["trailers"] = extra.value("Trailers", QVariantList{}).toList();
if (storeId == "9P8LR42PTRGJ") {
    QJsonArray jsonArray = QJsonArray::fromVariantList(extra.value("Trailers").toList());
    QJsonDocument doc(jsonArray);
    //qDebug().noquote() << storeId << "trailers:" << doc.toJson(QJsonDocument::Compact);
}

                            // Attributes
                            row["attributes"] = extra.value("Attributes", QVariantList{}).toList();

                            // Content Rating
                            row["contentRating"] = extra.value("ContentRating", QVariantMap{}).toMap();

                            // XCloud Offerings
                            row["xCloudOfferings"] = extra.value("XCloudOfferings", QVariantMap{}).toMap();

                            // Requires Gold Disclaimer
                            row["requiresGoldDisclaimer"] = extra.value("RequiresGoldDisclaimer", "").toString();

                            // Requires Gold For Multiplayer Disclaimer
                            row["requiresGoldForMultiplayerDisclaimer"] = extra.value("RequiresGoldForMultiplayerDisclaimer", "").toString();

                            // Language Support
                            row["languageSupport"] = extra.value("LanguageSupport", QVariantMap{}).toMap();

                            // Available Platforms
                            row["availablePlatforms"] = extra.value("AvailablePlatforms", QStringList{}).toStringList();

                            // INPUTS
                            row["inputs"] = row["xCloudOfferings"].toMap().value("XGPUWEB").toMap().value("SupportedInputTypes", QStringList{}).toStringList();

                            // Has Controller
                            row["hasController"] = row["inputs"].toStringList().contains("controller", Qt::CaseInsensitive);

                            // Has Mouse and Keyboard
                            row["hasMouseAndKeyboard"] = row["inputs"].toStringList().contains("mkb", Qt::CaseInsensitive);

                            // Added to GamePass Essential
                            row["addedGamePassEssential"] = QDateTime::fromString(extra.value("PassMetadataByPassProductId").toMap().value("CFQ7TTC0K5DJ").toMap().value("EntryDateUTC").toString(), Qt::ISODate);

                            // Added to GamePass Premium
                            row["addedGamePassPremium"] = QDateTime::fromString(extra.value("PassMetadataByPassProductId").toMap().value("CFQ7TTC0P85B").toMap().value("EntryDateUTC").toString(), Qt::ISODate);

                            // Added to GamePass Ultimate
                            row["addedGamePassUltimate"] = QDateTime();
                            if (extra.value("PassMetadataByPassProductId").toMap().contains("CFQ7TTC0K6L8")) { row["addedGamePassUltimate"] = QDateTime::fromString(extra.value("PassMetadataByPassProductId").toMap().value("CFQ7TTC0K6L8").toMap().value("EntryDateUTC").toString(), Qt::ISODate); }     // OLD
                            if (extra.value("PassMetadataByPassProductId").toMap().contains("CFQ7TTC0KHS0")) { row["addedGamePassUltimate"] = QDateTime::fromString(extra.value("PassMetadataByPassProductId").toMap().value("CFQ7TTC0KHS0").toMap().value("EntryDateUTC").toString(), Qt::ISODate); }     // NEW

                            // Added to GamePass EA Play
                            row["addedEAPlay"] = QDateTime::fromString(extra.value("PassMetadataByPassProductId").toMap().value("CFQ7TTC0K5DH").toMap().value("EntryDateUTC").toString(), Qt::ISODate);

                            // Added to GamePass Ubisoft+
                            row["addedUbisoftPlus"] = QDateTime::fromString(extra.value("PassMetadataByPassProductId").toMap().value("CFQ7TTC0QH5H").toMap().value("EntryDateUTC").toString(), Qt::ISODate);
                        }

                        else if (complexity == "complex") {

                            // Original Release Date
                            row["originalReleaseDate"] = QDateTime::fromString(extra.value("OriginalReleaseDate", "").toString(), Qt::ISODate);

                            // Console Coming Soon Date
                            row["consoleComingSoonDate"] = QDateTime::fromString(extra.value("ConsoleComingSoonDate", "").toString(), Qt::ISODate);

                            // Review Score
                            row["reviewScore"] = extra.value("ReviewScore", 0).toInt();

                            // Review Count
                            row["reviewCount"] = extra.value("ReviewCount", 0).toInt();

                            // Xpass Play Anywhere
                            row["xPAEnabled"] = extra.value("XPAEnabled", false).toBool();

                            // Is Free
                            if (extra.value("Price", QVariantMap()).toMap().contains("IsFree")) { row["isFree"] = extra.value("Price").toMap().value("IsFree", false).toBool(); }
                            else { row["isFree"] = false; }

                            // Regular Price
                            if (extra.value("Price", QVariantMap()).toMap().contains("MSRP")) { row["regularPrice"] = QLocale(settings.value("preferredLanguage").toString()).toDouble(extra.value("Price").toMap().value("MSRP", 0).toString().remove(QLocale(settings.value("preferredLanguage").toString()).currencySymbol()).trimmed()); }
                            else { row["regularPrice"] = 0; }

                            // Sale Price
                            if (extra.value("Price", QVariantMap()).toMap().contains("SalePrice")) { row["salePrice"] = QLocale(settings.value("preferredLanguage").toString()).toDouble(extra.value("Price").toMap().value("SalePrice", 0).toString().remove(QLocale(settings.value("preferredLanguage").toString()).currencySymbol()).trimmed()); }
                            else { row["salePrice"] = 0; }

                            // Discount
                            if (row["isFree"] == false && row["regularPrice"].toDouble() > 0 && row["salePrice"].toDouble() > 0) { row["discount"] = ((row["regularPrice"].toDouble() - row["salePrice"].toDouble()) / row["regularPrice"].toDouble()); }
                            else { row["discount"] = 0; }

//QJsonDocument doc(QJsonObject::fromVariantMap(extra.value("Price").toMap()));
//qDebug().noquote() << storeId << doc.toJson(QJsonDocument::Compact) << row["isFree"] << row["regularPrice"] << row["salePrice"] << row["discount"];
                        }

                        rowVar = row;
                    }
                    return sendResult;
                });

                // in here to continue on main UI after QFuture finished
                QObject::connect(watcher, &QFutureWatcher<UpdatedListResult>::finished, this, [this, watcher]() {
                    UpdatedListResult resultUpdatedList = watcher->result();
                    watcher->deleteLater();

                    if (resultUpdatedList.error == true) {
                        updateFullList(resultUpdatedList.complexity);
                    }
                    else {
                        updateModel(resultUpdatedList.complexity, resultUpdatedList.merged);

                        if (resultUpdatedList.complexity == "simple") {
                            createCategories(resultUpdatedList.categories);
                            updateFullList("moderate");
                        }
                        else if (resultUpdatedList.complexity == "moderate") {
                            updateFullList("complex");
                        }
                        else if (resultUpdatedList.complexity == "complex") {
                            resetTemporaryList();
                        }
                    }

                });

                watcher->setFuture(futureUpdatedList);
            });
        }


    signals:
        void modelChanged();
        //void countChanged();
        void titleListSimpleFinishedChanged();
        void titleListModerateFinishedChanged();
        void titleListComplexFinishedChanged();
        void categoriesChanged();


    private:
        QSettings settings;

        QVariantList m_gameListModelFull;
        QStringList m_gameListModelTemporary;
        QVariantList m_categories;

        bool m_titleListSimpleFinished = false;
        bool m_titleListModerateFinished = false;
        bool m_titleListComplexFinished = false;

        QNetworkAccessManager m_network;

        struct GetListResult {
            QVariantList list;
        };
        struct UpdatedListResult {
            QString complexity;
            QVariantList merged;
            QVariantList categories;
            bool error = false;
        };
};

// =============================================================
// Model #2 — Filtered Game List Model (different roles)
// =============================================================
class GameListModelFiltered : public QSortFilterProxyModel
{
    Q_OBJECT

    //Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(QString code                     READ code                   WRITE setCode                   NOTIFY codeChanged)
    Q_PROPERTY(QString sortingField             READ sortingField           WRITE setSortingField           NOTIFY sortingFieldChanged)
    Q_PROPERTY(int orderType                    READ orderType              WRITE setOrderType              NOTIFY orderTypeChanged)
    Q_PROPERTY(QString queryString              READ queryString            WRITE setQueryString            NOTIFY queryStringChanged)
    Q_PROPERTY(bool displayPlayableGames        READ displayPlayableGames   WRITE setDisplayPlayableGames   NOTIFY displayPlayableGamesChanged)
    Q_PROPERTY(QStringList availableCategories  READ availableCategories                                    NOTIFY availableCategoriesChanged)
    Q_PROPERTY(QStringList selectedCategories   READ selectedCategories                                     NOTIFY selectedCategoriesChanged)


    public:
        explicit GameListModelFiltered(QObject *parent = nullptr)
            : QSortFilterProxyModel(parent) {}


        // =======================
        // Getters
        // =======================
        //int count() const { return m_gameListModelFiltered.size(); }
        QString code() const { return m_code; }
        QString sortingField() const { return m_sortingField; }
        int orderType() const { return m_orderType; }
        QString queryString() const { return m_queryString; }
        bool displayPlayableGames() const { return m_displayPlayableGames; }
        QStringList availableCategories() const { return m_availableCategories; }
        QStringList selectedCategories() const { return m_selectedCategories; }


        // =======================
        // Setters
        // =======================
        void setCode(QString value) {
            if (m_code == value) { return; }
            m_code = value;
            emit codeChanged();
        }
        void setSortingField(QString value) {
            if (m_sortingField == value) { return; }
            m_sortingField = value;
            emit sortingFieldChanged();
        }
        void setOrderType(int value) {
            if (m_orderType == Qt::SortOrder(value)) { return; }
            m_orderType = Qt::SortOrder(value);
            emit orderTypeChanged();
        }
        void setQueryString(QString value) {
            if (m_queryString == value) { return; }
            m_queryString = value;
            emit queryStringChanged();
        }
        void setDisplayPlayableGames(bool value) {
            if (m_displayPlayableGames == value) { return; }
            m_displayPlayableGames = value;
            emit displayPlayableGamesChanged();
        }

        Q_INVOKABLE void setSelectedCategories(QStringList items) {
            if (m_selectedCategories == items) { return; }
            m_selectedCategories = items;
            emit selectedCategoriesChanged();
        }
        Q_INVOKABLE void setAvailableCategories(QStringList items) {
            if (m_availableCategories == items) { return; }
            m_availableCategories = items;
            emit availableCategoriesChanged();
        }


        QHash<int, QByteArray> roleNames() const override {
            return sourceModel() ? sourceModel()->roleNames() : QHash<int, QByteArray>();
        }


        Q_INVOKABLE void applyAsyncResult(const QVector<bool> &mask, const QVector<int> &sorted) {
            m_sortedOrder = sorted;
            m_acceptMask = mask;
            invalidate();
            emit modelChanged();
        }

        Q_INVOKABLE void refreshAsync() {
            if (m_code == "") { qWarning() << "unknown code"; return; }

            static QStringList allowedCodes = {"userSessionGames", "allGames", "favoriteGames", "newGames", "dealGames", "bestRatedGames", "comingSoonGames", "topFreeGames", "mostPlayedGames", "previewGames", "mouseAndKeyboardGames"};
            if (!allowedCodes.contains(m_code)) { qWarning() << "unconfigured code" << m_code; return; }

            AsyncResult sendResult;
                sendResult.code = m_code;

            QStringList replyList = {};
                if (m_code == "userSessionGames") { replyList = getLastplayedList(); }
                else if (m_code == "allGames") {}
                else if (m_code == "favoriteGames") { replyList = getFavouritedList(); }
                else if (m_code == "newGames") { replyList = getXboxList("eab7757c-ff70-45af-bfa6-79d3cfb2bf81"); }
                else if (m_code == "dealGames") {}
                else if (m_code == "bestRatedGames") {}
                else if (m_code == "comingSoonGames") { replyList = getXboxList("095bda36-f5cd-43f2-9ee1-0a72f371fb96"); }
                else if (m_code == "topFreeGames") {}
                else if (m_code == "mostPlayedGames") { replyList = getXboxList("eab7757c-ff70-45af-bfa6-79d3cfb2bf81"); }
                else if (m_code == "previewGames") {}
                else if (m_code == "mouseAndKeyboardGames") {}
            sendResult.replyList = replyList;

            auto *fullModel = qobject_cast<GameListModelFull*>(sourceModel());
            if (!fullModel) { qWarning() << "fullModel not reachable when calling"; return; }

            QVariantList modelSnapshot = fullModel->rawData();               // snapshot
            QFutureWatcher<AsyncResult> *watcher = new QFutureWatcher<AsyncResult>(this);     // watcher

            // this runs in QtConcurent background thread
            QFuture<AsyncResult> futureAsync = QtConcurrent::run([this, sendResult, modelSnapshot]() mutable -> AsyncResult {
                //AsyncResult sendResult;

                QVector<bool> accepted;
                    accepted.resize(modelSnapshot.size());
                    accepted.fill(true);

                if (m_code == "userSessionGames") {
                    for (int i=0; i<modelSnapshot.size(); i++) {
                        QVariantMap map = modelSnapshot.at(i).toMap();

                        // check if it belongs to the proper category accoridng to "code" to filter
                        if (!map["lastTimePlayed"].toDateTime().isValid()) { accepted[i] = false; continue; }
                        //if (!sendResult.replyList.contains(map["storeId"].toString(), Qt::CaseInsensitive)) { accepted[i] = false; continue; }

                        // check if Query Strings check passes
                        if (filterQueryString(map["productTitle"].toString()) == false) { accepted[i] = false; continue; }

                        // check if Playable Games check passes
                        if (filterPlayableGames(map["userPrograms"].toStringList()) == false) { accepted[i] = false; continue; }
                    }
                }
                else if (m_code == "allGames") {
                    for (int i=0; i < modelSnapshot.size(); i++) {
                        QVariantMap map = modelSnapshot.at(i).toMap();

                        // check if it belongs to the proper category accoridng to "code" to filter
                        // no need, all games shown here

                        // check if Query Strings check passes
                        if (filterQueryString(map["productTitle"].toString()) == false) { accepted[i] = false; continue; }

                        // check if Playable Games check passes
                        if (filterPlayableGames(map["userPrograms"].toStringList()) == false) { accepted[i] = false; continue; }
                    }
                }
                else if (m_code == "favoriteGames") {
                    for (int i=0; i < modelSnapshot.size(); i++) {
                        QVariantMap map = modelSnapshot.at(i).toMap();

                        // check if it belongs to the proper category accoridng to "code" to filter
                        if (map["isFavourited"].toBool() == false) { accepted[i] = false; continue; }
                        //if (!sendResult.replyList.contains(map["storeId"].toString(), Qt::CaseInsensitive)) { accepted[i] = false; continue; }

                        // check if Query Strings check passes
                        if (filterQueryString(map["productTitle"].toString()) == false) { accepted[i] = false; continue; }

                        // check if Playable Games check passes
                        if (filterPlayableGames(map["userPrograms"].toStringList()) == false) { accepted[i] = false; continue; }
                    }
                }
                else if (m_code == "newGames") {
                    for (int i=0; i < modelSnapshot.size(); i++) {
                        QVariantMap map = modelSnapshot.at(i).toMap();

                        // check if it belongs to the proper category accoridng to "code" to filter
                        if (!sendResult.replyList.contains(map["storeId"].toString(), Qt::CaseInsensitive)) { accepted[i] = false; continue; }

                        // check if Query Strings check passes
                        if (filterQueryString(map["productTitle"].toString()) == false) { accepted[i] = false; continue; }

                        // check if Playable Games check passes
                        if (filterPlayableGames(map["userPrograms"].toStringList()) == false) { accepted[i] = false; continue; }
                    }
                }
                else if (m_code == "dealGames") {
                    for (int i=0; i < modelSnapshot.size(); i++) {
                        QVariantMap map = modelSnapshot.at(i).toMap();

                        // check if it belongs to the proper category accoridng to "code" to filter
                        if (map["discount"].toInt() <= 0) { accepted[i] = false; continue; }

                        // check if Query Strings check passes
                        if (filterQueryString(map["productTitle"].toString()) == false) { accepted[i] = false; continue; }

                        // check if Playable Games check passes
                        if (filterPlayableGames(map["userPrograms"].toStringList()) == false) { accepted[i] = false; continue; }
                    }
                }
                else if (m_code == "bestRatedGames") {
                    for (int i=0; i < modelSnapshot.size(); i++) {
                        QVariantMap map = modelSnapshot.at(i).toMap();

                        // check if it belongs to the proper category accoridng to "code" to filter
                        if (map["reviewScore"].toInt() <= 0 || map["reviewCount"].toInt() <= 0) { }

                        // check if Query Strings check passes
                        if (filterQueryString(map["productTitle"].toString()) == false) { accepted[i] = false; continue; }

                        // check if Playable Games check passes
                        if (filterPlayableGames(map["userPrograms"].toStringList()) == false) { accepted[i] = false; continue; }
                    }
                }
                else if (m_code == "comingSoonGames") {
                    for (int i=0; i < modelSnapshot.size(); i++) {
                        QVariantMap map = modelSnapshot.at(i).toMap();

                        // check if it belongs to the proper category accoridng to "code" to filter
                        if (!sendResult.replyList.contains(map["storeId"].toString(), Qt::CaseInsensitive)) { accepted[i] = false; continue; }

                        // check if Query Strings check passes
                        if (filterQueryString(map["productTitle"].toString()) == false) { accepted[i] = false; continue; }

                        // check if Playable Games check passes
                        if (filterPlayableGames(map["userPrograms"].toStringList()) == false) { accepted[i] = false; continue; }
                    }
                }
                else if (m_code == "topFreeGames") {
                    for (int i=0; i < modelSnapshot.size(); i++) {
                        QVariantMap map = modelSnapshot.at(i).toMap();

                        // check if it belongs to the proper category accoridng to "code" to filter
                        if (map["isFree"].toBool() == false) { accepted[i] = false; continue; }

                        // check if Query Strings check passes
                        if (filterQueryString(map["productTitle"].toString()) == false) { accepted[i] = false; continue; }

                        // check if Playable Games check passes
                        if (filterPlayableGames(map["userPrograms"].toStringList()) == false) { accepted[i] = false; continue; }
                    }
                }
                else if (m_code == "mostPlayedGames") {
                    for (int i=0; i < modelSnapshot.size(); i++) {
                        QVariantMap map = modelSnapshot.at(i).toMap();

                        // check if it belongs to the proper category accoridng to "code" to filter
                        if (!sendResult.replyList.contains(map["storeId"].toString(), Qt::CaseInsensitive)) { accepted[i] = false; continue; }

                        // check if Query Strings check passes
                        if (filterQueryString(map["productTitle"].toString()) == false) { accepted[i] = false; continue; }

                        // check if Playable Games check passes
                        if (filterPlayableGames(map["userPrograms"].toStringList()) == false) { accepted[i] = false; continue; }
                    }
                }
                else if (m_code == "previewGames") {
                    for (int i=0; i < modelSnapshot.size(); i++) {
                        QVariantMap map = modelSnapshot.at(i).toMap();

                        // check if it belongs to the proper category accoridng to "code" to filter
                        if (map["isDemo"].toBool() == false) { accepted[i] = false; continue; }

                        // check if Query Strings check passes
                        if (filterQueryString(map["productTitle"].toString()) == false) { accepted[i] = false; continue; }

                        // check if Playable Games check passes
                        if (filterPlayableGames(map["userPrograms"].toStringList()) == false) { accepted[i] = false; continue; }
                    }
                }
                else if (m_code == "mouseAndKeyboardGames") {
                    for (int i=0; i < modelSnapshot.size(); i++) {
                        QVariantMap map = modelSnapshot.at(i).toMap();

                        // check if it belongs to the proper category accoridng to "code" to filter
                        if (map["hasMouseAndKeyboard"].toBool() == false) { accepted[i] = false; continue; }

                        // check if Query Strings check passes
                        if (filterQueryString(map["productTitle"].toString()) == false) { accepted[i] = false; continue; }

                        // check if Playable Games check passes
                        if (filterPlayableGames(map["userPrograms"].toStringList()) == false) { accepted[i] = false; continue; }
                    }
                }


                // Available Categories
                QStringList availableCategories;
                for (int i=0; i<modelSnapshot.size(); i++) {
                    if (!accepted[i]) { continue; }

                    const QVariantMap map = modelSnapshot.at(i).toMap();
                    const QStringList categories = map["categories"].toStringList();

                    for (const QString &cat : categories) {
                        if (!availableCategories.contains(cat)) { availableCategories.append(cat); }
                    }
                }
                sendResult.availableCategories = availableCategories;


                // ----------------------------------------------
                // Filter by selected categories
                // ----------------------------------------------
                if (!m_selectedCategories.isEmpty()) {
                    for (int i=0; i<modelSnapshot.size(); i++) {
                        if (accepted[i] == false) { continue; }     // skip already rejected rows

                        const QVariantMap map = modelSnapshot.at(i).toMap();
                        const QStringList categories = map["categories"].toStringList();

                        bool categoryMatch = false;
                        if (categories.size() == 0) { categoryMatch = true; }       // TODO: probably updateFullList() with this new storeId has not finished yet, so category is not know and better to display
                        else {
                            for (int j=0; j<m_selectedCategories.size(); j++) {
                                if (categories.contains(m_selectedCategories.at(j), Qt::CaseInsensitive)) {
                                    categoryMatch = true;
                                    break;
                                }
                            }
                        }
                        if (!categoryMatch) { accepted[i] = false; }
                    }
                }

                // ----------------------------------
                // BUILD SORT LIST
                // ----------------------------------
                QVector<int> sortedIndexes;
                sortedIndexes.reserve(modelSnapshot.size());
                for (int i = 0; i < modelSnapshot.size(); i++) {
                    if (accepted[i]) { sortedIndexes.append(i); }
                }
                // ----------------------------------
                // SORT (primary + secondary)
                // ----------------------------------
                std::sort(sortedIndexes.begin(), sortedIndexes.end(), [=](int a, int b) {
                    const QVariantMap ma = modelSnapshot[a].toMap();
                    const QVariantMap mb = modelSnapshot[b].toMap();

                    // Primary — case-insensitive compare
                    int cmp = 0;
                    if (m_sortingField == "productTitle") {
                        const QString sa = ma[m_sortingField].toString();
                        const QString sb = mb[m_sortingField].toString();

                        cmp = QString::compare(sa, sb, Qt::CaseInsensitive);
                    }
                    else {
                        const QVariant sa = ma[m_sortingField];
                        const QVariant sb = mb[m_sortingField];

                        bool okA, okB;
                        double da = sa.toDouble(&okA);
                        double db = sb.toDouble(&okB);

                        if (okA && okB) {
                            if (da < db) { cmp = -1; }
                            else if (da > db) { cmp = 1; }
                        }
                        else {
                            cmp = QString::compare(
                                sa.toString(),
                                sb.toString(),
                                Qt::CaseInsensitive
                            );
                        }
                    }
                    if (cmp != 0) { return (m_orderType == Qt::AscendingOrder) ? (cmp < 0) : (cmp > 0); }

                    // Secondary — ALWAYS productTitle ASC
                    const QString ta = ma["productTitle"].toString();
                    const QString tb = mb["productTitle"].toString();
                    return QString::compare(ta, tb, Qt::CaseInsensitive) < 0;
                });

                sendResult.accepted = accepted;
                sendResult.sortedIndexes = sortedIndexes;

                return sendResult;
            });

            // in here to continue on main UI after QFuture finished
            QObject::connect(watcher, &QFutureWatcher<AsyncResult>::finished, this, [this, watcher]() {
                AsyncResult resultAsync = watcher->result();
                watcher->deleteLater();

                setAvailableCategories(resultAsync.availableCategories);
                applyAsyncResult(resultAsync.accepted, resultAsync.sortedIndexes);  // including sorting
            });

            watcher->setFuture(futureAsync);
        }


    private:
        bool filterQueryString(const QString &productTitle = QString()) {
            if (productTitle.isNull()) { return true; }      // argument NOT provided by caller

            if (m_queryString.size() >= 1) {
                if (productTitle.contains(m_queryString, Qt::CaseInsensitive)) { return true; }
                else { return false; }
            }
            else { return true; }
        }

        bool filterPlayableGames(const QStringList &userPrograms = QStringList()) {
            if (m_displayPlayableGames == true) {
                if (userPrograms.size() > 0) { return true; }
                else { return false; }
            }
            else { return true; }
        }

        QStringList getXboxList(QString listId = nullptr) {
            if (listId == nullptr) { qWarning() << "listId invalid"; return {}; }

            QNetworkRequest req;
                req.setUrl("https://catalog.gamepass.com/sigls/v2?id=" + listId + "&market=" + settings.value("preferredMarket").toString() + "&language=" + settings.value("preferredLanguage").toString());
                if (settings.value("preferredforceIp").toString() != "") { req.setRawHeader("X-Forwarded-For", settings.value("preferredforceIp").toByteArray()); }
            QNetworkAccessManager *manager = new QNetworkAccessManager();
                manager->get(req);

            QEventLoop loop;
            QNetworkReply *reply = manager->get(req);

            QObject::connect(reply, &QNetworkReply::finished, &loop, &QEventLoop::quit);        // When reply finishes, quit the loop
            loop.exec();                // BLOCK HERE until finished

            // REPLY RECEIVED
            QByteArray serverReply = reply->readAll();
            reply->deleteLater();

            QJsonParseError jsonError;
            QJsonDocument replyDocument = QJsonDocument::fromJson(serverReply, &jsonError);
            if (jsonError.error != QJsonParseError::NoError) {
                qWarning() << "JSON parse failed in getFavouritedList():" << jsonError.errorString();
                //qWarning() << "Raw reply:" << serverReply;
                return {};
            }

            // Ensure it's an object and convert to QVariantMap
            QVariantList replyList = replyDocument.array().toVariantList();

            // Separate additional StoreId(s)
            auto *fullModel = qobject_cast<GameListModelFull*>(sourceModel());
            if (!fullModel) { qWarning() << "fullModel not reachable when calling"; return {}; }
            QStringList storeIdList = fullModel->storeIdList(); // copy
            QSet<QString> fullModelData = QSet<QString>(storeIdList.begin(), storeIdList.end());       // Convert the big list to a set for fast lookup

            // return variables
            QVariantList listToUpdate;
            QVariantList listToAdd;
            QStringList returnList;


            // list of all storeId from serverReply
            for (int i=1; i<replyList.size(); i++) {		// skip first index
                QVariantMap entry = replyList.at(i).toMap();

                QString productId = entry.value("id").toString().toUpper();

                // Create output object
                QVariantMap outputItem;
                    outputItem["storeId"] = productId;

                // append to returnList
                returnList.append(productId);

                // Decide which list
                if (fullModelData.contains(productId)) { listToUpdate.append(outputItem); }
                else { listToAdd.append(outputItem); }
            }

            fullModel->setUpdateList(listToUpdate);
            fullModel->setTemporaryList(listToAdd);

            return returnList;
        }

        QStringList getLastplayedList() {

            QVariantMap token = settings.value("xcloudToken").toMap();
            QVariantMap offering = token["offeringSettings"].toMap();
            QVariantList regions = offering["regions"].toList();

            QString baseUri;
            for (int i=0; i<regions.size(); i++) {
                QVariantMap region = regions.at(i).toMap();
                if (region["isDefault"].toBool()) {
                    baseUri = region["baseUri"].toString();
                    break;
                }
            }

            QNetworkRequest req;
                req.setUrl(baseUri + "/v2/titles/mru?mr=999");      // 999 is max amount of results
                req.setRawHeader("Authorization", settings.value("xcloudToken").toMap().value("tokenType").toString().toUtf8() + " " + settings.value("xcloudToken").toMap().value("gsToken").toString().toUtf8());
                req.setRawHeader("Content-Type", "application/json");
                if (settings.value("preferredforceIp").toString() != "") { req.setRawHeader("X-Forwarded-For", settings.value("preferredforceIp").toByteArray()); }
            QNetworkAccessManager *manager = new QNetworkAccessManager();
                manager->get(req);

            QEventLoop loop;
            QNetworkReply *reply = manager->get(req);

            QObject::connect(reply, &QNetworkReply::finished, &loop, &QEventLoop::quit);        // When reply finishes, quit the loop
            loop.exec();                // BLOCK HERE until finished

            // REPLY RECEIVED
            QByteArray serverReply = reply->readAll();
            reply->deleteLater();

            QJsonParseError jsonError;
            QJsonDocument replyDocument = QJsonDocument::fromJson(serverReply, &jsonError);
            if (jsonError.error != QJsonParseError::NoError) {
                qWarning() << "JSON parse failed in getLastplayedList():" << jsonError.errorString();
                //qWarning() << "Raw reply:" << serverReply;
                return {};
            }

            // Ensure it's an object and convert to QVariantMap
            QVariantMap replyMap = replyDocument.object().toVariantMap();
            QVariantList results = replyMap.value("results").toList();

            // Separate additional StoreId(s)
            auto *fullModel = qobject_cast<GameListModelFull*>(sourceModel());
            if (!fullModel) { qWarning() << "fullModel not reachable when calling"; return {}; }
            QStringList storeIdList = fullModel->storeIdList(); // copy
            QSet<QString> fullModelData = QSet<QString>(storeIdList.begin(), storeIdList.end());       // Convert the big list to a set for fast lookup

            // return variables
            QVariantList listToUpdate;
            QVariantList listToAdd;
            QStringList returnList;


            // list of all storeId from serverReply
            for (int i=0; i<results.size(); i++) {
                QVariantMap item = results.at(i).toMap();
                QVariantMap details = item.value("details").toMap();
                QVariantMap history = item.value("titleHistory").toMap();

                QString productId = details.value("productId").toString().toUpper();
                QDateTime lastPlayed = QDateTime::fromString(history.value("lastTimePlayed").toString(), Qt::ISODate);       // Parse ISO timestamp into QDateTime (optional but recommended)

                // Create output object
                QVariantMap outputItem;
                    outputItem["storeId"] = productId;
                    outputItem["lastTimePlayed"] = lastPlayed;

                // append to returnList
                returnList.append(productId);

                // Decide which list
                if (fullModelData.contains(productId)) { listToUpdate.append(outputItem); }
                else { listToAdd.append(outputItem); }
            }

            fullModel->setUpdateList(listToUpdate);
            fullModel->setTemporaryList(listToAdd);

           return returnList;
        }

        QStringList getFavouritedList() {

            QString xid = settings.value("xid").toString();
            QString uhs = settings.value("webToken").toMap()["DisplayClaims"].toMap()["xui"].toList()[0].toMap()["uhs"].toString();
            QString token = settings.value("webToken").toMap().value("token").toString();

            QNetworkRequest req;
                req.setUrl(QUrl("https://eplists.xboxlive.com/users/xuid(" + xid + ")/lists/PINS/PINS"));
                req.setRawHeader("Authorization", "XBL3.0 x=" + uhs.toUtf8() + ";" + token.toUtf8());
                req.setRawHeader("x-xbl-contract-version", "2");
                if (settings.value("preferredforceIp").toString() != "") { req.setRawHeader("X-Forwarded-For", settings.value("preferredforceIp").toByteArray()); }
            QNetworkAccessManager *manager = new QNetworkAccessManager();
                manager->get(req);

            QEventLoop loop;
            QNetworkReply *reply = manager->get(req);

            QObject::connect(reply, &QNetworkReply::finished, &loop, &QEventLoop::quit);        // When reply finishes, quit the loop
            loop.exec();                // BLOCK HERE until finished

            // REPLY RECEIVED
            QByteArray serverReply = reply->readAll();
            reply->deleteLater();

            QJsonParseError jsonError;
            QJsonDocument replyDocument = QJsonDocument::fromJson(serverReply, &jsonError);
            if (jsonError.error != QJsonParseError::NoError) {
                qWarning() << "JSON parse failed in getFavouritedList():" << jsonError.errorString();
                //qWarning() << "Raw reply:" << serverReply;
                return {};
            }

            // Ensure it's an object and convert to QVariantMap
            QVariantMap replyMap = replyDocument.object().toVariantMap();
            QVariantList results = replyMap.value("ListItems").toList();

            // Separate additional StoreId(s)
            auto *fullModel = qobject_cast<GameListModelFull*>(sourceModel());
            if (!fullModel) { qWarning() << "fullModel not reachable when calling"; return {}; }
            QStringList storeIdList = fullModel->storeIdList(); // copy
            QSet<QString> fullModelData = QSet<QString>(storeIdList.begin(), storeIdList.end());       // Convert the big list to a set for fast lookup

            // return variables
            QVariantList listToUpdate;
            QVariantList listToAdd;
            QStringList returnList;


            // list of all storeId from serverReply
            for (int i=0; i<results.size(); i++) {
                QVariantMap entry = results.at(i).toMap();
                QVariantMap item = entry.value("Item").toMap();

                QString productId = item.value("itemId").toString().toUpper();
                bool isFavourited = true;

                // Create output object
                QVariantMap outputItem;
                    outputItem["storeId"] = productId;
                    outputItem["isFavourited"] = isFavourited;

                // append to returnList
                returnList.append(productId);

                // Decide which list
                if (fullModelData.contains(productId)) { listToUpdate.append(outputItem); }
                else { listToAdd.append(outputItem); }
            }

            fullModel->setUpdateList(listToUpdate);
            fullModel->setTemporaryList(listToAdd);

            return returnList;
        }


    protected:
        // ----------------------------------------------------------
        // REAL Qt filtering logic
        // ----------------------------------------------------------
        bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const override {
            Q_UNUSED(sourceParent)
            if (m_acceptMask.isEmpty()) { return true; }
            if (sourceRow < 0 || sourceRow >= m_acceptMask.size()) { return true; }
            return m_acceptMask[sourceRow];
        }

        // -----------------------------------
        // MAP sorted rows async → source model
        // -----------------------------------
        QModelIndex mapToSource(const QModelIndex &proxyIndex) const override {
            if (!proxyIndex.isValid()) { return QModelIndex(); }

            int row = proxyIndex.row();
            if (row < 0 || row >= m_sortedOrder.size()) { return QModelIndex(); }

            int sourceRow = m_sortedOrder[row];
            return sourceModel()->index(sourceRow, proxyIndex.column());
        }
        QModelIndex mapFromSource(const QModelIndex &sourceIndex) const override {
            if (!sourceIndex.isValid()) { return QModelIndex(); }

            int sourceRow = sourceIndex.row();
            int row = m_sortedOrder.indexOf(sourceRow);

            if (row < 0) { return QModelIndex(); }
            return index(row, sourceIndex.column());
        }


    signals:
        void modelChanged();
        //void countChanged();
        void codeChanged();
        void sortingFieldChanged();
        void orderTypeChanged();
        void queryStringChanged();
        void displayPlayableGamesChanged();
        void availableCategoriesChanged();
        void selectedCategoriesChanged();


    private:
        QSettings settings;

        QString m_code = "allGames";
        QString m_sortingField = "productTitle";
        Qt::SortOrder m_orderType = Qt::AscendingOrder;
        QString m_queryString = "";
        bool m_displayPlayableGames = settings.value("displayPlayableGames").toBool();
        QStringList m_availableCategories = {};
        QStringList m_selectedCategories = {};

        QVector<bool> m_acceptMask;     // async filter mask
        QVector<int> m_sortedOrder;     // async sorted row order

        struct AsyncResult {
            QString code;
            QStringList replyList;
            QStringList availableCategories;
            QVector<bool> accepted;
            QVector<int> sortedIndexes;
        };
};


// =============================================================
// Controller — Exposes models & supports batched loading
// =============================================================
class GameListController : public QObject
{
    Q_OBJECT

    Q_PROPERTY(GameListModelFull*           fullGameList        READ fullGameList           NOTIFY fullGameListChanged)
    Q_PROPERTY(GameListModelFiltered*       filteredGameList    READ filteredGameList       NOTIFY filteredGameListChanged)

    public:
        explicit GameListController(QObject *parent = nullptr)
            : QObject(parent)
        {
            m_fullGameList = new GameListModelFull(this);
            m_filteredGameList = new GameListModelFiltered(this);

            // Connect filtered model to the full model
            // need to sourceModel in QML because QML creates is own instance and its replacing properties in Constructor
            // or alternativly i could change main.cpp qmlRegisterType to qmlRegisterSingletonInstance but i dont know how
            //m_filteredGameList->setSourceModel(m_fullGameList);

            connect(m_fullGameList, &GameListModelFull::modelChanged, this, &GameListController::fullGameListChanged);
            connect(m_filteredGameList, &GameListModelFiltered::modelChanged, this, &GameListController::filteredGameListChanged);
        }

        GameListModelFull *fullGameList() const { return m_fullGameList; }
        GameListModelFiltered *filteredGameList() const { return m_filteredGameList; }


    signals:
        void fullGameListChanged();
        void filteredGameListChanged();


    private:
        GameListModelFull *m_fullGameList = nullptr;
        GameListModelFiltered *m_filteredGameList = nullptr;
};