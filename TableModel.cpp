#include "TableModel.h"
#include "DatabaseManager.h"

TableModel::TableModel(QObject *parent)
    : QAbstractTableModel(parent)
{
}

QString TableModel::tableName() const { return m_tableName; }

void TableModel::setTableName(const QString &tableName)
{
    if (m_tableName != tableName) {
        m_tableName = tableName;
        emit tableNameChanged();
        refresh();
    }
}

DatabaseManager *TableModel::database() const { return m_db; }

void TableModel::setDatabase(DatabaseManager *db)
{
    if (m_db != db) {
        m_db = db;
        emit databaseChanged();
        refresh();
    }
}

QString TableModel::filterColumn() const { return m_filterColumn; }

void TableModel::setFilterColumn(const QString &column)
{
    if (m_filterColumn != column) {
        m_filterColumn = column;
        emit filterChanged();
        refresh();
    }
}

QVariant TableModel::filterValue() const { return m_filterValue; }

void TableModel::setFilterValue(const QVariant &value)
{
    m_filterValue = value;
    emit filterChanged();
    refresh();
}

void TableModel::setFilter(const QString &column, const QVariant &value)
{
    m_filterColumn = column;
    m_filterValue = value;
    emit filterChanged();
    refresh();
}

QString TableModel::orderBy() const { return m_orderBy; }

void TableModel::setOrderBy(const QString &order)
{
    if (m_orderBy != order) {
        m_orderBy = order;
        emit orderByChanged();
        refresh();
    }
}

int TableModel::rowCount(const QModelIndex &) const { return m_rows.size(); }

int TableModel::columnCount(const QModelIndex &) const { return m_columns.size(); }

QVariant TableModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_rows.size() || index.column() >= m_columns.size())
        return {};

    if (role == Qt::DisplayRole)
        return m_rows[index.row()][index.column()];

    return {};
}

QVariant TableModel::headerData(int section, Qt::Orientation orientation, int role) const
{
    if (orientation == Qt::Horizontal && role == Qt::DisplayRole && section < m_columns.size()) {
        QString name = m_columns[section];
        return name.replace("_", " ").replace(0, 1, name[0].toUpper());
    }
    return {};
}

void TableModel::refresh()
{
    if (m_tableName.isEmpty() || !m_db)
        return;

    beginResetModel();
    m_columns = m_db->columnNames(m_tableName);
    QVariantList rows;
    if (m_filterColumn.isEmpty())
        rows = m_db->fetchAll(m_tableName, m_orderBy);
    else
        rows = m_db->fetchWhere(m_tableName, m_filterColumn, m_filterValue, m_orderBy);
    m_rows.clear();
    for (const QVariant &row : rows) {
        QVariantMap map = row.toMap();
        QVariantList values;
        for (const QString &col : m_columns)
            values.append(map.value(col));
        m_rows.append(values);
    }
    endResetModel();
    m_revision++;
    emit revisionChanged();
    emit countChanged();
}

bool TableModel::create(const QVariantMap &data)
{
    if (!m_db)
        return false;
    int id = m_db->createRecord(m_tableName, data);
    if (id >= 0) {
        refresh();
        return true;
    }
    return false;
}

bool TableModel::update(int row, const QVariantMap &data)
{
    if (!m_db || row < 0 || row >= m_rows.size())
        return false;

    QVariantMap rowData = get(row);
    QString pk = m_db->pkColumn(m_tableName);
    int id = rowData.value(pk).toInt();

    if (m_db->updateRecord(m_tableName, id, data)) {
        refresh();
        return true;
    }
    return false;
}

bool TableModel::remove(int row)
{
    if (!m_db || row < 0 || row >= m_rows.size())
        return false;

    QVariantMap rowData = get(row);
    QString pk = m_db->pkColumn(m_tableName);
    int id = rowData.value(pk).toInt();

    if (m_db->deleteRecord(m_tableName, id)) {
        refresh();
        return true;
    }
    return false;
}

QVariantMap TableModel::get(int row) const
{
    QVariantMap result;
    if (row < 0 || row >= m_rows.size())
        return result;

    for (int i = 0; i < m_columns.size(); ++i)
        result.insert(m_columns[i], m_rows[row][i]);

    return result;
}

int TableModel::columnCountForTable() const { return m_columns.size(); }

QString TableModel::columnName(int col) const
{
    if (col >= 0 && col < m_columns.size())
        return m_columns[col];
    return {};
}
