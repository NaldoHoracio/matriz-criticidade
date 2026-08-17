#include "DatabaseManager.h"

#include <QDebug>
#include <QJSEngine>
#include <QJsonDocument>
#include <QJsonObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QUrl>
#include <QUrlQuery>

DatabaseManager::DatabaseManager(QObject *parent)
    : QObject(parent)
{
    m_engine = qobject_cast<QJSEngine *>(parent);
    m_nam = new QNetworkAccessManager(this);
}

DatabaseManager::~DatabaseManager() = default;

QString DatabaseManager::baseUrl() const
{
    return m_baseUrl;
}

void DatabaseManager::setBaseUrl(const QString &url)
{
    QString clean = url;
    while (clean.endsWith(QLatin1Char('/')))
        clean.chop(1);
    if (m_baseUrl != clean) {
        m_baseUrl = clean;
        emit baseUrlChanged();
    }
}

bool DatabaseManager::busy() const
{
    return m_busy;
}

QUrl DatabaseManager::apiUrl(const QString &path) const
{
    return QUrl(m_baseUrl + path);
}

void DatabaseManager::setBusy(bool busy)
{
    if (m_busy != busy) {
        m_busy = busy;
        emit busyChanged();
    }
}

bool DatabaseManager::initialize()
{
    QUrl url = apiUrl(QStringLiteral("/api/health"));
    get(url, [this](const QVariant &result) {
        if (!result.isValid())
            qWarning() << "[DatabaseManager] API indisponível em" << m_baseUrl;
        else
            qInfo() << "[DatabaseManager] API conectada em" << m_baseUrl;
    });
    return true;
}

QNetworkReply *DatabaseManager::get(const QUrl &url, const JsonCb &cb)
{
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, QStringLiteral("application/json"));
    QNetworkReply *reply = m_nam->get(request);
    ++m_pending;
    setBusy(true);
    connect(reply, &QNetworkReply::finished, this, [this, reply, cb]() { onReply(reply, cb); });
    return reply;
}

QNetworkReply *DatabaseManager::send(const QString &verb, const QUrl &url,
                                     const QJsonObject &body, const JsonCb &cb)
{
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, QStringLiteral("application/json"));
    const QByteArray payload = QJsonDocument(body).toJson(QJsonDocument::Compact);

    QNetworkReply *reply = nullptr;
    if (verb == QLatin1String("POST"))
        reply = m_nam->post(request, payload);
    else if (verb == QLatin1String("PUT"))
        reply = m_nam->put(request, payload);
    else
        reply = m_nam->deleteResource(request);

    ++m_pending;
    setBusy(true);
    connect(reply, &QNetworkReply::finished, this, [this, reply, cb]() { onReply(reply, cb); });
    return reply;
}

void DatabaseManager::onReply(QNetworkReply *reply, const JsonCb &cb)
{
    const QString url = reply->url().toString();
    const QNetworkReply::NetworkError err = reply->error();
    const QByteArray body = reply->readAll();
    reply->deleteLater();

    --m_pending;
    setBusy(m_pending > 0);

    if (err != QNetworkReply::NoError) {
        emit errorOccurred(url + QStringLiteral(" -> ") + reply->errorString());
        if (cb)
            cb(QVariant());
        return;
    }

    QJsonParseError parseError;
    const QJsonDocument doc = QJsonDocument::fromJson(body, &parseError);
    if (parseError.error != QJsonParseError::NoError || doc.isNull()) {
        emit errorOccurred(QStringLiteral("JSON inválido de %1").arg(url));
        if (cb)
            cb(QVariant());
        return;
    }

    if (cb)
        cb(doc.toVariant());
}

void DatabaseManager::invokeJs(const QJSValue &callback, const QVariant &result)
{
    if (!m_engine || !callback.isCallable())
        return;
    QJSValueList args;
    args << m_engine->toScriptValue(result);
    callback.call(args);
}

// ------------------------------------------------------------------ fetch

void DatabaseManager::fetchAll(const QString &table, const QJSValue &callback)
{
    fetchAll(table, QString(), [this, callback](const QVariant &result) {
        invokeJs(callback, result);
    });
}

void DatabaseManager::fetchAll(const QString &table, const QString &orderBy, const JsonCb &cb)
{
    QUrl url = apiUrl(QStringLiteral("/api/tables/") + QUrl::toPercentEncoding(table));
    if (!orderBy.isEmpty()) {
        QUrlQuery query;
        query.addQueryItem(QStringLiteral("order_by"), orderBy);
        url.setQuery(query);
    }
    get(url, cb);
}

void DatabaseManager::fetchWhere(const QString &table, const QString &column,
                                 const QVariant &value, const QJSValue &callback)
{
    fetchWhere(table, column, value, QString(), [this, callback](const QVariant &result) {
        invokeJs(callback, result);
    });
}

void DatabaseManager::fetchWhere(const QString &table, const QString &column,
                                 const QVariant &value, const QString &orderBy,
                                 const JsonCb &cb)
{
    QUrlQuery query;
    query.addQueryItem(QStringLiteral("column"), column);
    query.addQueryItem(QStringLiteral("value"), value.toString());
    if (!orderBy.isEmpty())
        query.addQueryItem(QStringLiteral("order_by"), orderBy);

    QUrl url = apiUrl(QStringLiteral("/api/tables/") + QUrl::toPercentEncoding(table)
                      + QStringLiteral("/where"));
    url.setQuery(query);
    get(url, cb);
}

void DatabaseManager::fetchById(const QString &table, int id, const QJSValue &callback)
{
    fetchById(table, id, [this, callback](const QVariantMap &result) {
        invokeJs(callback, result);
    });
}

void DatabaseManager::fetchById(const QString &table, int id,
                                const std::function<void(const QVariantMap &)> &cb)
{
    QUrl url = apiUrl(QStringLiteral("/api/tables/") + QUrl::toPercentEncoding(table)
                      + QStringLiteral("/") + QString::number(id));
    get(url, [cb](const QVariant &result) { cb(result.toMap()); });
}

// ----------------------------------------------------------------- write

void DatabaseManager::createRecord(const QString &table, const QVariantMap &data,
                                   const QJSValue &callback)
{
    createRecord(table, data, [this, callback](int id) { invokeJs(callback, id); });
}

void DatabaseManager::createRecord(const QString &table, const QVariantMap &data,
                                   const std::function<void(int)> &cb)
{
    QUrl url = apiUrl(QStringLiteral("/api/tables/") + QUrl::toPercentEncoding(table));
    send(QStringLiteral("POST"), url, QJsonObject::fromVariantMap(data),
         [this, table, cb](const QVariant &result) {
             const int id = result.toMap().value(QStringLiteral("id"), -1).toInt();
             if (id >= 0)
                 emit dataChanged(table);
             if (cb)
                 cb(id);
         });
}

void DatabaseManager::updateRecord(const QString &table, int id, const QVariantMap &data,
                                   const QJSValue &callback)
{
    updateRecord(table, id, data, [this, callback](bool ok) { invokeJs(callback, ok); });
}

void DatabaseManager::updateRecord(const QString &table, int id, const QVariantMap &data,
                                   const std::function<void(bool)> &cb)
{
    QUrl url = apiUrl(QStringLiteral("/api/tables/") + QUrl::toPercentEncoding(table)
                      + QStringLiteral("/") + QString::number(id));
    send(QStringLiteral("PUT"), url, QJsonObject::fromVariantMap(data),
         [this, table, cb](const QVariant &result) {
             const bool ok = result.toMap().value(QStringLiteral("ok"), false).toBool();
             if (ok)
                 emit dataChanged(table);
             if (cb)
                 cb(ok);
         });
}

void DatabaseManager::deleteRecord(const QString &table, int id, const QJSValue &callback)
{
    deleteRecord(table, id, [this, callback](bool ok) { invokeJs(callback, ok); });
}

void DatabaseManager::deleteRecord(const QString &table, int id,
                                   const std::function<void(bool)> &cb)
{
    QUrl url = apiUrl(QStringLiteral("/api/tables/") + QUrl::toPercentEncoding(table)
                      + QStringLiteral("/") + QString::number(id));
    send(QStringLiteral("DELETE"), url, {},
         [this, table, cb](const QVariant &result) {
             const bool ok = result.toMap().value(QStringLiteral("ok"), false).toBool();
             if (ok) {
                 emit dataChanged(table);
                 // ON DELETE CASCADE also removes child rows server-side.
                 if (table == QLatin1String("empresa")) {
                     emit dataChanged(QStringLiteral("setor"));
                     emit dataChanged(QStringLiteral("equipamento"));
                     emit dataChanged(QStringLiteral("criticidade"));
                     emit dataChanged(QStringLiteral("historico_manutencao"));
                 } else if (table == QLatin1String("setor")) {
                     emit dataChanged(QStringLiteral("equipamento"));
                     emit dataChanged(QStringLiteral("criticidade"));
                     emit dataChanged(QStringLiteral("historico_manutencao"));
                 } else if (table == QLatin1String("equipamento")) {
                     emit dataChanged(QStringLiteral("criticidade"));
                     emit dataChanged(QStringLiteral("historico_manutencao"));
                 }
             }
             if (cb)
                 cb(ok);
         });
}

// --------------------------------------------------------------- options

void DatabaseManager::foreignOptions(const QString &table, const QString &displayColumn,
                                     const QJSValue &callback)
{
    QUrlQuery query;
    query.addQueryItem(QStringLiteral("display"), displayColumn);

    QUrl url = apiUrl(QStringLiteral("/api/tables/") + QUrl::toPercentEncoding(table)
                      + QStringLiteral("/options"));
    url.setQuery(query);
    get(url, [this, callback](const QVariant &result) { invokeJs(callback, result); });
}

void DatabaseManager::distinctValues(const QString &table, const QString &column,
                                     const QJSValue &callback)
{
    QUrlQuery query;
    query.addQueryItem(QStringLiteral("column"), column);

    QUrl url = apiUrl(QStringLiteral("/api/tables/") + QUrl::toPercentEncoding(table)
                      + QStringLiteral("/distinct"));
    url.setQuery(query);
    get(url, [this, callback](const QVariant &result) { invokeJs(callback, result); });
}

void DatabaseManager::columnNames(const QString &table, const QJSValue &callback)
{
    columnNames(table, [this, callback](const QStringList &cols) {
        invokeJs(callback, QVariant(cols));
    });
}

void DatabaseManager::columnNames(const QString &table,
                                  const std::function<void(const QStringList &)> &cb)
{
    QUrl url = apiUrl(QStringLiteral("/api/tables/") + QUrl::toPercentEncoding(table)
                      + QStringLiteral("/columns"));
    get(url, [cb](const QVariant &result) {
        QStringList cols;
        const QVariantList list = result.toList();
        for (const QVariant &v : list)
            cols << v.toString();
        cb(cols);
    });
}

void DatabaseManager::pkColumn(const QString &table, const QJSValue &callback)
{
    pkColumn(table, [this, callback](const QString &pk) { invokeJs(callback, pk); });
}

void DatabaseManager::pkColumn(const QString &table,
                               const std::function<void(const QString &)> &cb)
{
    QUrl url = apiUrl(QStringLiteral("/api/tables/") + QUrl::toPercentEncoding(table)
                      + QStringLiteral("/pk"));
    get(url, [cb](const QVariant &result) {
        cb(result.toMap().value(QStringLiteral("pk")).toString());
    });
}

// ------------------------------------------------------------ criticidade

void DatabaseManager::saveCriticidade(int equipamentoId, int funcao, int risco,
                                      int riscoAbc, int perdaAbc, int tempo,
                                      int interrupcao, int mttf, int mttr,
                                      int criticidadeFinal, const QJSValue &callback)
{
    QJsonObject body;
    body.insert(QStringLiteral("equipamentoId"), equipamentoId);
    body.insert(QStringLiteral("funcao"), funcao);
    body.insert(QStringLiteral("risco"), risco);
    body.insert(QStringLiteral("riscoAbc"), riscoAbc);
    body.insert(QStringLiteral("perdaAbc"), perdaAbc);
    body.insert(QStringLiteral("tempo"), tempo);
    body.insert(QStringLiteral("interrupcao"), interrupcao);
    body.insert(QStringLiteral("mttf"), mttf);
    body.insert(QStringLiteral("mttr"), mttr);
    body.insert(QStringLiteral("criticidadeFinal"), criticidadeFinal);

    QUrl url = apiUrl(QStringLiteral("/api/criticidade/save"));
    send(QStringLiteral("POST"), url, body, [this, callback](const QVariant &result) {
        if (result.toMap().value(QStringLiteral("ok"), false).toBool())
            emit dataChanged(QStringLiteral("criticidade"));
        invokeJs(callback, result);
    });
}

void DatabaseManager::fetchCriticidadeByEquipamento(int equipamentoId,
                                                    const QJSValue &callback)
{
    QUrl url = apiUrl(QStringLiteral("/api/criticidade/equipamento/")
                      + QString::number(equipamentoId));
    get(url, [this, callback](const QVariant &result) { invokeJs(callback, result); });
}
