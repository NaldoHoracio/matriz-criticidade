#ifndef DATABASEMANAGER_H
#define DATABASEMANAGER_H

#include <QObject>
#include <QJSValue>
#include <QVariantMap>
#include <QVariantList>
#include <functional>

class QJSEngine;
class QNetworkAccessManager;
class QNetworkReply;
class QJsonObject;

class DatabaseManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString baseUrl READ baseUrl WRITE setBaseUrl NOTIFY baseUrlChanged)
    Q_PROPERTY(bool busy READ busy NOTIFY busyChanged)

public:
    explicit DatabaseManager(QObject *parent = nullptr);
    ~DatabaseManager() override;

    QString baseUrl() const;
    void setBaseUrl(const QString &url);
    bool busy() const;

    Q_INVOKABLE bool initialize();

    // QML-facing async API: last argument is an optional JS callback
    // receiving the result (QVariantList / QVariantMap / int / bool).
    Q_INVOKABLE void fetchAll(const QString &table, const QJSValue &callback = QJSValue());
    Q_INVOKABLE void fetchWhere(const QString &table, const QString &column,
                                const QVariant &value,
                                const QJSValue &callback = QJSValue());
    Q_INVOKABLE void fetchById(const QString &table, int id,
                               const QJSValue &callback = QJSValue());
    Q_INVOKABLE void createRecord(const QString &table, const QVariantMap &data,
                                  const QJSValue &callback = QJSValue());
    Q_INVOKABLE void updateRecord(const QString &table, int id, const QVariantMap &data,
                                  const QJSValue &callback = QJSValue());
    Q_INVOKABLE void deleteRecord(const QString &table, int id,
                                  const QJSValue &callback = QJSValue());
    Q_INVOKABLE void foreignOptions(const QString &table, const QString &displayColumn,
                                    const QJSValue &callback = QJSValue());
    Q_INVOKABLE void distinctValues(const QString &table, const QString &column,
                                    const QJSValue &callback = QJSValue());
    Q_INVOKABLE void columnNames(const QString &table,
                                 const QJSValue &callback = QJSValue());
    Q_INVOKABLE void pkColumn(const QString &table,
                              const QJSValue &callback = QJSValue());
    Q_INVOKABLE void saveCriticidade(int equipamentoId, int funcao, int risco,
                                     int riscoAbc, int perdaAbc, int tempo,
                                     int interrupcao, int mttf, int mttr,
                                     int criticidadeFinal,
                                     const QJSValue &callback = QJSValue());
    Q_INVOKABLE void fetchCriticidadeByEquipamento(int equipamentoId,
                                                   const QJSValue &callback = QJSValue());

    // C++-side async API (used by TableModel).
    using JsonCb = std::function<void(const QVariant &)>;
    void fetchAll(const QString &table, const QString &orderBy, const JsonCb &cb);
    void fetchWhere(const QString &table, const QString &column, const QVariant &value,
                    const QString &orderBy, const JsonCb &cb);
    void fetchById(const QString &table, int id,
                   const std::function<void(const QVariantMap &)> &cb);
    void createRecord(const QString &table, const QVariantMap &data,
                      const std::function<void(int)> &cb);
    void updateRecord(const QString &table, int id, const QVariantMap &data,
                      const std::function<void(bool)> &cb);
    void deleteRecord(const QString &table, int id,
                      const std::function<void(bool)> &cb);
    void columnNames(const QString &table,
                     const std::function<void(const QStringList &)> &cb);
    void pkColumn(const QString &table,
                  const std::function<void(const QString &)> &cb);

signals:
    void baseUrlChanged();
    void busyChanged();
    void dataChanged(const QString &table);
    void errorOccurred(const QString &message);

private:
    QNetworkReply *get(const QUrl &url, const JsonCb &cb);
    QNetworkReply *send(const QString &verb, const QUrl &url, const QJsonObject &body,
                        const JsonCb &cb);
    void onReply(QNetworkReply *reply, const JsonCb &cb);
    QUrl apiUrl(const QString &path) const;
    void invokeJs(const QJSValue &callback, const QVariant &result);
    void setBusy(bool busy);

    QJSEngine *m_engine = nullptr;
    QNetworkAccessManager *m_nam = nullptr;
    QString m_baseUrl = QStringLiteral("http://localhost:8000");
    int m_pending = 0;
    bool m_busy = false;
};

#endif
