#ifndef TABLEMODEL_H
#define TABLEMODEL_H

#include <QAbstractTableModel>
#include <QVector>
#include <QStringList>
#include <QVariantMap>
#include <QVariantList>

class DatabaseManager;

class TableModel : public QAbstractTableModel
{
    Q_OBJECT
    Q_PROPERTY(QString tableName READ tableName WRITE setTableName NOTIFY tableNameChanged)
    Q_PROPERTY(DatabaseManager *database READ database WRITE setDatabase NOTIFY databaseChanged)
    Q_PROPERTY(QString filterColumn READ filterColumn WRITE setFilterColumn NOTIFY filterChanged)
    Q_PROPERTY(QVariant filterValue READ filterValue WRITE setFilterValue NOTIFY filterChanged)
    Q_PROPERTY(QString orderBy READ orderBy WRITE setOrderBy NOTIFY orderByChanged)
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    Q_PROPERTY(int revision READ revision NOTIFY revisionChanged)

public:
    explicit TableModel(QObject *parent = nullptr);

    QString tableName() const;
    void setTableName(const QString &tableName);

    DatabaseManager *database() const;
    void setDatabase(DatabaseManager *db);

    QString filterColumn() const;
    void setFilterColumn(const QString &column);
    QVariant filterValue() const;
    void setFilterValue(const QVariant &value);
    QString orderBy() const;
    void setOrderBy(const QString &order);
    Q_INVOKABLE void setFilter(const QString &column, const QVariant &value);

    int rowCount(const QModelIndex &parent = {}) const override;
    int columnCount(const QModelIndex &parent = {}) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QVariant headerData(int section, Qt::Orientation orientation, int role = Qt::DisplayRole) const override;

    int revision() const { return m_revision; }

    Q_INVOKABLE void refresh();
    Q_INVOKABLE void create(const QVariantMap &data);
    Q_INVOKABLE void update(int row, const QVariantMap &data);
    Q_INVOKABLE void remove(int row);
    Q_INVOKABLE QVariantMap get(int row) const;
    Q_INVOKABLE int columnCountForTable() const;
    Q_INVOKABLE QString columnName(int col) const;

signals:
    void tableNameChanged();
    void databaseChanged();
    void filterChanged();
    void orderByChanged();
    void countChanged();
    void revisionChanged();

private:
    int m_revision = 0;
    QString m_tableName;
    QString m_filterColumn;
    QString m_orderBy;
    QVariant m_filterValue;
    DatabaseManager *m_db = nullptr;
    QStringList m_columns;
    QString m_pkColumn;
    QVector<QVariantList> m_rows;
    int m_requestSeq = 0;
};

#endif
