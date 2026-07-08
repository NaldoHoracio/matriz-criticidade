#include "DatabaseManager.h"
#include <QSqlQuery>
#include <QSqlError>
#include <QSqlRecord>
#include <QDebug>
#include <QDir>
#include <QStandardPaths>

DatabaseManager::DatabaseManager(QObject *parent)
    : QObject(parent)
{
}

DatabaseManager::~DatabaseManager()
{
    if (m_db.isOpen())
        m_db.close();
}

QString DatabaseManager::databasePath() const
{
    return m_databasePath;
}

void DatabaseManager::setDatabasePath(const QString &path)
{
    if (m_databasePath != path) {
        m_databasePath = path;
        emit databasePathChanged();
    }
}

bool DatabaseManager::initialize()
{
    if (m_databasePath.isEmpty()) {
        QString dir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
        QDir().mkpath(dir);
        m_databasePath = dir + "/criticidade.db";
    }

    if (m_db.isOpen())
        m_db.close();

    if (QSqlDatabase::contains("QSQLITE"))
        QSqlDatabase::removeDatabase("QSQLITE");

    m_db = QSqlDatabase::addDatabase("QSQLITE");
    m_db.setDatabaseName(m_databasePath);

    if (!m_db.open()) {
        qWarning() << "Failed to open database:" << m_db.lastError().text();
        return false;
    }

    QSqlQuery(m_db).exec("PRAGMA journal_mode=WAL");
    QSqlQuery(m_db).exec("PRAGMA foreign_keys=ON");

    createTables();
    return true;
}

void DatabaseManager::execOrWarn(const QString &sql)
{
    QSqlQuery q(m_db);
    if (!q.exec(sql))
        qWarning() << "SQL Error:" << q.lastError().text() << "\nSQL:" << sql;
}

void DatabaseManager::createTables()
{
    execOrWarn(R"(
        CREATE TABLE IF NOT EXISTS empresa (
            id_empresa INTEGER PRIMARY KEY AUTOINCREMENT,
            nome VARCHAR(200) NOT NULL,
            cnpj VARCHAR(18) UNIQUE NOT NULL
        )
    )");
    execOrWarn(R"(
        CREATE TABLE IF NOT EXISTS setor (
            id_setor INTEGER PRIMARY KEY AUTOINCREMENT,
            nome VARCHAR(150) NOT NULL,
            id_empresa INTEGER NOT NULL,
            FOREIGN KEY (id_empresa) REFERENCES empresa(id_empresa) ON DELETE CASCADE
        )
    )");
    execOrWarn(R"(
        CREATE TABLE IF NOT EXISTS tipo_equipamento (
            id_tipo_equipamento INTEGER PRIMARY KEY AUTOINCREMENT,
            nome VARCHAR(200) NOT NULL UNIQUE,
            descricao TEXT,
            valor INTEGER DEFAULT 0
        )
    )");
    {
        QSqlQuery dedup(m_db);
        dedup.exec("DELETE FROM tipo_equipamento WHERE rowid NOT IN (SELECT MIN(rowid) FROM tipo_equipamento GROUP BY nome)");
        QStringList fixos = {"Apoio", "Análise", "Diagnóstico", "Terapia", "Sistema de Suporte à Vida"};
        QList<int> valores = {1, 2, 3, 4, 5};
        for (int i = 0; i < fixos.size(); ++i) {
            QSqlQuery ins(m_db);
            ins.prepare("INSERT INTO tipo_equipamento (nome, valor) SELECT ?, ? WHERE NOT EXISTS (SELECT 1 FROM tipo_equipamento WHERE nome = ?)");
            ins.addBindValue(fixos[i]);
            ins.addBindValue(valores[i]);
            ins.addBindValue(fixos[i]);
            ins.exec();
            QSqlQuery upd(m_db);
            upd.prepare("UPDATE tipo_equipamento SET valor = ? WHERE nome = ? AND valor <> ?");
            upd.addBindValue(valores[i]);
            upd.addBindValue(fixos[i]);
            upd.addBindValue(valores[i]);
            upd.exec();
        }
    }

    execOrWarn(R"(
        CREATE TABLE IF NOT EXISTS equipamento (
            id_equipamento INTEGER PRIMARY KEY AUTOINCREMENT,
            patrimonio VARCHAR(100),
            modelo VARCHAR(200),
            fabricante VARCHAR(200),
            data_aquisicao DATE,
            id_setor INTEGER NOT NULL,
            id_tipo_equipamento INTEGER NOT NULL,
            FOREIGN KEY (id_setor) REFERENCES setor(id_setor) ON DELETE CASCADE,
            FOREIGN KEY (id_tipo_equipamento) REFERENCES tipo_equipamento(id_tipo_equipamento) ON DELETE CASCADE
        )
    )");
    execOrWarn(R"(
        CREATE TABLE IF NOT EXISTS criticidade (
            id_criticidade INTEGER PRIMARY KEY AUTOINCREMENT,
            Funcao INTEGER DEFAULT 0,
            Risco INTEGER DEFAULT 0,
            RiscoAbc INTEGER DEFAULT 0,
            PerdaAbc INTEGER DEFAULT 0,
            Tempo INTEGER DEFAULT 0,
            Interrupcao INTEGER DEFAULT 0,
            Mttf INTEGER DEFAULT 0,
            Mttr INTEGER DEFAULT 0,
            criticidade_final INTEGER DEFAULT 0,
            id_equipamento INTEGER UNIQUE NOT NULL,
            FOREIGN KEY (id_equipamento) REFERENCES equipamento(id_equipamento) ON DELETE CASCADE
        )
    )");
    {
        QStringList critCols = {"Funcao","Risco","RiscoAbc","PerdaAbc","Tempo","Interrupcao","Mttf","Mttr","criticidade_final"};
        QStringList existingCritCols = columnNames("criticidade");
        for (const QString &col : critCols) {
            bool found = false;
            for (const QString &e : existingCritCols) {
                if (e.compare(col, Qt::CaseInsensitive) == 0) { found = true; break; }
            }
            if (!found)
                execOrWarn(QString("ALTER TABLE criticidade ADD COLUMN %1 INTEGER DEFAULT 0").arg(col));
        }
    }
    execOrWarn(R"(
        CREATE TABLE IF NOT EXISTS historico_manutencao (
            id_manutencao INTEGER PRIMARY KEY AUTOINCREMENT,
            data_manutencao DATE NOT NULL,
            tipo_manutencao VARCHAR(100),
            descricao TEXT,
            custo REAL DEFAULT 0,
            responsavel VARCHAR(200),
            observacoes TEXT,
            id_equipamento INTEGER NOT NULL,
            FOREIGN KEY (id_equipamento) REFERENCES equipamento(id_equipamento) ON DELETE CASCADE
        )
    )");
}

QVariantList DatabaseManager::fetchAll(const QString &table, const QString &orderBy)
{
    QVariantList result;
    QString sql = "SELECT * FROM " + table;
    if (!orderBy.isEmpty())
        sql += " ORDER BY " + orderBy;

    QSqlQuery q(m_db);
    q.exec(sql);

    while (q.next()) {
        QVariantMap row;
        for (int i = 0; i < q.record().count(); ++i)
            row.insert(q.record().fieldName(i), q.value(i));
        result.append(row);
    }
    return result;
}

QVariantList DatabaseManager::fetchWhere(const QString &table, const QString &column, const QVariant &value, const QString &orderBy)
{
    QVariantList result;
    QString sql = "SELECT * FROM " + table + " WHERE " + column + " = ?";
    if (!orderBy.isEmpty())
        sql += " ORDER BY " + orderBy;

    QSqlQuery q(m_db);
    q.prepare(sql);
    q.addBindValue(value);
    if (!q.exec()) {
        qWarning() << "fetchWhere error:" << q.lastError().text();
        return result;
    }

    while (q.next()) {
        QVariantMap row;
        for (int i = 0; i < q.record().count(); ++i)
            row.insert(q.record().fieldName(i), q.value(i));
        result.append(row);
    }
    return result;
}

QVariantMap DatabaseManager::fetchById(const QString &table, int id)
{
    QString pk = pkColumn(table);
    QSqlQuery q(m_db);
    q.prepare("SELECT * FROM " + table + " WHERE " + pk + " = ?");
    q.addBindValue(id);
    q.exec();

    if (q.next()) {
        QVariantMap row;
        for (int i = 0; i < q.record().count(); ++i)
            row.insert(q.record().fieldName(i), q.value(i));
        return row;
    }
    return {};
}

int DatabaseManager::createRecord(const QString &table, const QVariantMap &data)
{
    QString pk = pkColumn(table);
    QStringList cols, ph;
    QVariantList vals;

    if (table == "tipo_equipamento" && data.contains("nome")) {
        QSqlQuery dup(m_db);
        dup.prepare("SELECT COUNT(*) FROM tipo_equipamento WHERE nome = ?");
        dup.addBindValue(data.value("nome"));
        if (dup.exec() && dup.next() && dup.value(0).toInt() > 0)
            return -1;
    }

    for (auto it = data.begin(); it != data.end(); ++it) {
        if (it.key() == pk)
            continue;
        cols << it.key();
        ph << "?";
        vals << it.value();
    }

    if (cols.isEmpty())
        return -1;

    QString sql = "INSERT INTO " + table + " (" + cols.join(", ") + ") VALUES (" + ph.join(", ") + ")";
    QSqlQuery q(m_db);
    q.prepare(sql);
    for (const QVariant &v : vals)
        q.addBindValue(v);

    if (q.exec()) {
        int id = q.lastInsertId().toInt();
        emit dataChanged(table);
        return id;
    }
    return -1;
}

bool DatabaseManager::updateRecord(const QString &table, int id, const QVariantMap &data)
{
    QString pk = pkColumn(table);

    if (table == "tipo_equipamento" && data.contains("nome")) {
        QSqlQuery dup(m_db);
        dup.prepare("SELECT COUNT(*) FROM tipo_equipamento WHERE nome = ? AND " + pk + " <> ?");
        dup.addBindValue(data.value("nome"));
        dup.addBindValue(id);
        if (dup.exec() && dup.next() && dup.value(0).toInt() > 0)
            return false;
    }

    QStringList sets;
    QVariantList vals;

    for (auto it = data.begin(); it != data.end(); ++it) {
        if (it.key() == pk)
            continue;
        sets << it.key() + " = ?";
        vals << it.value();
    }

    if (sets.isEmpty())
        return false;

    QString sql = "UPDATE " + table + " SET " + sets.join(", ") + " WHERE " + pk + " = ?";
    QSqlQuery q(m_db);
    q.prepare(sql);
    for (const QVariant &v : vals)
        q.addBindValue(v);
    q.addBindValue(id);

    if (q.exec()) {
        emit dataChanged(table);
        return true;
    }
    qWarning() << "Update error:" << q.lastError().text();
    return false;
}

bool DatabaseManager::deleteRecord(const QString &table, int id)
{
    QString pk = pkColumn(table);

    QSqlQuery q(m_db);

    if (table == "empresa") {
        q.prepare("SELECT id_setor FROM setor WHERE id_empresa = ?");
        q.addBindValue(id);
        q.exec();
        QList<int> setorIds;
        while (q.next()) setorIds << q.value(0).toInt();
        for (int sid : setorIds) {
            q.prepare("DELETE FROM historico_manutencao WHERE id_equipamento IN (SELECT id_equipamento FROM equipamento WHERE id_setor = ?)");
            q.addBindValue(sid); q.exec();
            q.prepare("DELETE FROM criticidade WHERE id_equipamento IN (SELECT id_equipamento FROM equipamento WHERE id_setor = ?)");
            q.addBindValue(sid); q.exec();
            q.prepare("DELETE FROM equipamento WHERE id_setor = ?");
            q.addBindValue(sid); q.exec();
        }
        q.prepare("DELETE FROM setor WHERE id_empresa = ?");
        q.addBindValue(id); q.exec();
        q.prepare("DELETE FROM empresa WHERE id_empresa = ?");
        q.addBindValue(id);
        if (q.exec()) {
            emit dataChanged("empresa");
            emit dataChanged("setor");
            emit dataChanged("equipamento");
            emit dataChanged("criticidade");
            emit dataChanged("historico_manutencao");
            return true;
        }
    } else if (table == "setor") {
        q.prepare("DELETE FROM historico_manutencao WHERE id_equipamento IN (SELECT id_equipamento FROM equipamento WHERE id_setor = ?)");
        q.addBindValue(id); q.exec();
        q.prepare("DELETE FROM criticidade WHERE id_equipamento IN (SELECT id_equipamento FROM equipamento WHERE id_setor = ?)");
        q.addBindValue(id); q.exec();
        q.prepare("DELETE FROM equipamento WHERE id_setor = ?");
        q.addBindValue(id); q.exec();
        q.prepare("DELETE FROM setor WHERE id_setor = ?");
        q.addBindValue(id);
        if (q.exec()) {
            emit dataChanged("setor");
            emit dataChanged("equipamento");
            emit dataChanged("criticidade");
            emit dataChanged("historico_manutencao");
            return true;
        }
    } else if (table == "equipamento") {
        q.prepare("DELETE FROM historico_manutencao WHERE id_equipamento = ?");
        q.addBindValue(id); q.exec();
        q.prepare("DELETE FROM criticidade WHERE id_equipamento = ?");
        q.addBindValue(id); q.exec();
        q.prepare("DELETE FROM equipamento WHERE id_equipamento = ?");
        q.addBindValue(id);
        if (q.exec()) {
            emit dataChanged("equipamento");
            emit dataChanged("criticidade");
            emit dataChanged("historico_manutencao");
            return true;
        }
    } else {
        q.prepare("DELETE FROM " + table + " WHERE " + pk + " = ?");
        q.addBindValue(id);
        if (q.exec()) {
            emit dataChanged(table);
            return true;
        }
    }

    qWarning() << "Delete error:" << q.lastError().text();
    return false;
}

QVariantList DatabaseManager::foreignOptions(const QString &table, const QString &displayColumn)
{
    QVariantList result;
    QString pk = pkColumn(table);
    QString orderCol = (table == "tipo_equipamento") ? "valor" : displayColumn;
    QString sql = "SELECT " + pk + ", " + displayColumn + " FROM " + table + " ORDER BY " + orderCol;

    QSqlQuery q(m_db);
    q.exec(sql);
    while (q.next()) {
        QVariantMap item;
        item["id"] = q.value(0);
        item["display"] = q.value(1);
        result.append(item);
    }
    return result;
}

QStringList DatabaseManager::distinctValues(const QString &table, const QString &column)
{
    QStringList result;
    QSqlQuery q(m_db);
    q.prepare("SELECT DISTINCT " + column + " FROM " + table + " WHERE " + column + " IS NOT NULL AND " + column + " <> '' ORDER BY " + column);
    if (q.exec()) {
        while (q.next())
            result << q.value(0).toString();
    }
    return result;
}

QStringList DatabaseManager::columnNames(const QString &table)
{
    QStringList cols;
    QSqlQuery q(m_db);
    q.exec("PRAGMA table_info(" + table + ")");
    while (q.next())
        cols << q.value(1).toString();
    return cols;
}

int DatabaseManager::saveCriticidade(int equipamentoId, int funcao, int risco, int riscoAbc, int perdaAbc, int tempo, int interrupcao, int mttf, int mttr, int criticidadeFinal)
{
    qWarning() << "saveCriticidade params:" << equipamentoId << funcao << risco << riscoAbc << perdaAbc << tempo << interrupcao << mttf << mttr << criticidadeFinal;

    QSqlQuery check(m_db);
    check.prepare("SELECT id_criticidade FROM criticidade WHERE id_equipamento = ?");
    check.addBindValue(equipamentoId);
    if (!check.exec()) {
        qWarning() << "saveCriticidade check error:" << check.lastError().text();
        return -1;
    }

    if (check.next()) {
        QSqlQuery upd(m_db);
        upd.prepare(
            "UPDATE criticidade SET Funcao=?,Risco=?,RiscoAbc=?,PerdaAbc=?,Tempo=?,Interrupcao=?,Mttf=?,Mttr=?,criticidade_final=? "
            "WHERE id_equipamento=?"
        );
        upd.addBindValue(funcao);
        upd.addBindValue(risco);
        upd.addBindValue(riscoAbc);
        upd.addBindValue(perdaAbc);
        upd.addBindValue(tempo);
        upd.addBindValue(interrupcao);
        upd.addBindValue(mttf);
        upd.addBindValue(mttr);
        upd.addBindValue(criticidadeFinal);
        upd.addBindValue(equipamentoId);
        if (!upd.exec()) {
            qWarning() << "saveCriticidade UPDATE error:" << upd.lastError().text();
            return -1;
        }
        qWarning() << "saveCriticidade: UPDATE sucesso equipamento" << equipamentoId;
    } else {
        QSqlQuery ins(m_db);
        ins.prepare(
            "INSERT INTO criticidade (Funcao,Risco,RiscoAbc,PerdaAbc,Tempo,Interrupcao,Mttf,Mttr,criticidade_final,id_equipamento) "
            "VALUES (?,?,?,?,?,?,?,?,?,?)"
        );
        ins.addBindValue(funcao);
        ins.addBindValue(risco);
        ins.addBindValue(riscoAbc);
        ins.addBindValue(perdaAbc);
        ins.addBindValue(tempo);
        ins.addBindValue(interrupcao);
        ins.addBindValue(mttf);
        ins.addBindValue(mttr);
        ins.addBindValue(criticidadeFinal);
        ins.addBindValue(equipamentoId);
        if (!ins.exec()) {
            qWarning() << "saveCriticidade INSERT error:" << ins.lastError().text();
            return -1;
        }
        qWarning() << "saveCriticidade: INSERT sucesso equipamento" << equipamentoId;
    }

    emit dataChanged("criticidade");
    return 1;
}

QVariantMap DatabaseManager::fetchCriticidadeByEquipamento(int equipamentoId)
{
    QSqlQuery q(m_db);
    q.prepare("SELECT * FROM criticidade WHERE id_equipamento = ?");
    q.addBindValue(equipamentoId);
    if (q.exec() && q.next()) {
        QVariantMap row;
        for (int i = 0; i < q.record().count(); ++i)
            row.insert(q.record().fieldName(i), q.value(i));
        qDebug() << "fetchCriticidadeByEquipamento(" << equipamentoId << "): found id_criticidade=" << row.value("id_criticidade").toInt();
        return row;
    }
    qDebug() << "fetchCriticidadeByEquipamento(" << equipamentoId << "): NOT FOUND";
    return {};
}

QString DatabaseManager::pkColumn(const QString &table)
{
    QSqlQuery q(m_db);
    q.exec("PRAGMA table_info(" + table + ")");
    if (q.next())
        return q.value(1).toString();
    return "id";
}
