#ifndef DATABASEMANAGER_H
#define DATABASEMANAGER_H

#include <QObject>
#include <QSqlDatabase>
#include <QVariantMap>
#include <QVariantList>

class DatabaseManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString databasePath READ databasePath WRITE setDatabasePath NOTIFY databasePathChanged)

public:
    explicit DatabaseManager(QObject *parent = nullptr);
    ~DatabaseManager();

    QString databasePath() const;
    void setDatabasePath(const QString &path);

    Q_INVOKABLE bool initialize();
    Q_INVOKABLE QVariantList fetchAll(const QString &table, const QString &orderBy = QString());
    Q_INVOKABLE QVariantList fetchWhere(const QString &table, const QString &column, const QVariant &value, const QString &orderBy = QString());
    Q_INVOKABLE QVariantMap fetchById(const QString &table, int id);
    Q_INVOKABLE int createRecord(const QString &table, const QVariantMap &data);
    Q_INVOKABLE bool updateRecord(const QString &table, int id, const QVariantMap &data);
    Q_INVOKABLE bool deleteRecord(const QString &table, int id);
    Q_INVOKABLE QVariantList foreignOptions(const QString &table, const QString &displayColumn);
    Q_INVOKABLE QStringList distinctValues(const QString &table, const QString &column);
    Q_INVOKABLE QStringList columnNames(const QString &table);
    Q_INVOKABLE QString pkColumn(const QString &table);
    Q_INVOKABLE int saveCriticidade(int equipamentoId, int funcao, int risco, int riscoAbc, int perdaAbc, int tempo, int interrupcao, int mttf, int mttr, int criticidadeFinal);
    Q_INVOKABLE QVariantMap fetchCriticidadeByEquipamento(int equipamentoId);

signals:
    void databasePathChanged();
    void dataChanged(const QString &table);

private:
    void createTables();
    void execOrWarn(const QString &sql);
    QSqlDatabase m_db;
    QString m_databasePath;
};

#endif
