#include "appcontroller.h"

AppController::AppController(QObject *parent)
    : QObject(parent)

{
}

void AppController::setupDatabase()
{
    QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE");
    db.setDatabaseName("CriticalityDB.db");
    bool ok=db.open();
    if(ok){
        QSqlQuery q;
        QString sqlInstituicao =
            "CREATE TABLE IF NOT EXISTS instituicao ("
            "id_instituicao INTEGER PRIMARY KEY AUTOINCREMENT, "
            "nome TEXT UNIQUE NOT NULL, "
            "cnpj TEXT UNIQUE NOT NULL"
            ");";
        if (!q.exec(sqlInstituicao)) {
            qCritical() << "Falha ao criar tabela 'instituicao':" << q.lastError().text();
        }
        QString sqlSetor =
            "CREATE TABLE IF NOT EXISTS setor ("
            "id_setor INTEGER PRIMARY KEY AUTOINCREMENT, "
            "nome TEXT NOT NULL, "
            "id_instituicao INTEGER NOT NULL, "
            "CONSTRAINT fk_setor_instituicao FOREIGN KEY (id_instituicao) REFERENCES instituicao(id_instituicao) ON DELETE CASCADE"
            ");";
        if (!q.exec(sqlSetor)) {
            qCritical() << "Falha ao criar tabela 'setor':" << q.lastError().text();
        }
        QString sqlTipoEquipamento =
            "CREATE TABLE IF NOT EXISTS tipo_equipamento ("
            "id_tipo_equipamento INTEGER PRIMARY KEY AUTOINCREMENT, "
            "nome TEXT NOT NULL, "
            "descricao TEXT"
            ");";
        if (!q.exec(sqlTipoEquipamento)) {
            qCritical() << "Falha ao criar tabela 'tipo_equipamento':" << q.lastError().text();
        }
        QString sqlEquipamento =
            "CREATE TABLE IF NOT EXISTS equipamento ("
            "id_equipmento INTEGER PRIMARY KEY AUTOINCREMENT, "
            "patrimonio TEXT NOT NULL, "
            "modelo TEXT NOT NULL, "
            "fabricante TEXT NOT NULL, "
            "data_aquisicao TEXT NOT NULL, "
            "id_setor INTEGER NOT NULL, "
            "id_tipo_equipamento INTEGER NOT NULL, "
            "FOREIGN KEY (id_setor) REFERENCES setor(id_setor) ON DELETE CASCADE, "
            "FOREIGN KEY (id_tipo_equipamento) REFERENCES tipo_equipamento(id_tipo_equipamento) ON DELETE RESTRICT"
            ");";
        if (!q.exec(sqlEquipamento)) {
            qCritical() << "Falha ao criar tabela 'equipamento':" << q.lastError().text();
        }
    }
    else{
        qApp->quit();
    }
}

void AppController::insertIntoInstitutions(QString nome, QString cnpj)
{
    qDebug() << "Salvo" << nome << cnpj;
    QSqlQuery query;
    query.prepare("INSERT INTO instituicao(nome,cnpj) VALUES(:nome,:cnpj);");
    query.bindValue(":nome",nome);
    query.bindValue(":cnpj",cnpj);
    bool ok=query.exec();
    if(ok){
        qDebug() << "saved";
    }else {
        qDebug() << "Erro ao salvar equipamento:" << query.lastError().text();
    }
}

void AppController::insertIntoSectors(QString nome,int id_instituicao)
{
    QSqlQuery query;
    query.prepare("INSERT INTO setor(nome,id_instituicao) VALUES(:nome,:id_instituicao);");
    query.bindValue(":nome",nome);
    query.bindValue(":id_instituicao",id_instituicao);
    bool ok=query.exec();
    if(ok){
        qDebug() << "saved" << nome;
    }else {
        qDebug() << "Erro ao salvar equipamento:" << query.lastError().text();
    }
}

void AppController::insertIntoEquipments(QString patrimonio, QString modelo, QString fabricante, QString data_aquisição, int id_setor,int id_tipo_equipamento)
{
    QSqlQuery query;
    query.prepare("INSERT INTO equipamento(patrimonio,modelo,fabricante,data_aquisicao,id_setor,id_tipo_equipamento) VALUES(:patrimonio,:modelo,:fabricante,:data_aquisicao,:id_setor,:id_tipo_equipamento);");
    query.bindValue(":patrimonio",patrimonio);
    query.bindValue(":modelo",modelo);
    query.bindValue(":fabricante",fabricante);
    query.bindValue(":data_aquisicao",data_aquisição);
    query.bindValue(":id_setor",1);
    query.bindValue(":id_tipo_equipamento",1);
    bool ok=query.exec();
    if(ok){
        qDebug() << "saved" << patrimonio << modelo << fabricante << data_aquisição << id_setor << id_tipo_equipamento;
    }else {
        qDebug() << "Erro ao salvar equipamento:" << query.lastError().text();
    }
}

void AppController::insertIntoTipoEquipamentos(QString nome, QString descricao)
{
    QSqlQuery query;
    query.prepare("INSERT INTO tipo_equipamento(nome,descricao) VALUES(:nome,:decricao);");
    query.bindValue(":nome",nome);
    query.bindValue(":descricao",descricao);
    bool ok=query.exec();
    if(ok){
        qDebug() << "saved"<< nome;
    }else {
        qDebug() << "Erro ao salvar equipamento:" << query.lastError().text();
    }
}

void AppController::updateInstitutions(int id_instituicao, QString nome, QString cnpj)
{
    QSqlQuery query;
    query.prepare("UPDATE instituicao SET nome=:nome,cnpj=:cnpj WHERE id_instituicao=:id_instituicao");
    query.bindValue(":nome",nome);
    query.bindValue(":cnpj",cnpj);
    query.bindValue(":id_instituicao",id_instituicao);
    query.exec();
}

void AppController::updateSectors(int id_setor, QString nome, int id_instituicao)
{
    QSqlQuery query;
    query.prepare("UPDATE setor SET nome=:nome,id_instituicao=:id_instituicao WHERE id_setor=:id_setor");
    query.bindValue(":nome",nome);
    query.bindValue(":id_instituicao",id_instituicao);
    query.bindValue(":id_setor",id_setor);
    query.exec();
}

void AppController::updateEquipments(int id_equipamento, QString patrimonio, QString modelo, QString fabricante, QString data_aquisição, int id_setor, int id_tipo_equipamento)
{
    QSqlQuery query;
    query.prepare("UPDATE equipamento SET patrimonio=:patrimonio,modelo=:modelo,fabricante=:fabricante,data_aquisicao=:data_aquisicao,id_setor=:id_setor,id_tipo_equipamentos=:id_tipo_equipamentos WHERE id_equipamento=:id_equipamento");
    query.bindValue(":patrimonio",patrimonio);
    query.bindValue(":modelo",modelo);
    query.bindValue(":fabricante",fabricante);
    query.bindValue(":data_aquisição",data_aquisição);
    query.bindValue(":id_setor",id_setor);
    query.bindValue("id_tipo_equipamento",id_tipo_equipamento);
    query.exec();
}

void AppController::updateTipoEquipamentos(int id_tipo_equipamento, QString nome, QString descricao)
{
    QSqlQuery query;
    query.prepare("UPDATE tipo_equipamento SET nome=:nome,descricao=:descricao WHERE id_tipo_equipamento=:id_tipo_equipamento");
    query.bindValue(":nome",nome);
    query.bindValue(":descricao",descricao);
    query.bindValue(":id_tipo_equipamento",id_tipo_equipamento);
    query.exec();
}

void AppController::deleteInstitutions(int id_instituicao)
{
    QSqlQuery query;
    query.prepare("DELETE FROM instituicao WHERE id_instituicao=:id_instituicao");
    query.bindValue(":id_instituicao",id_instituicao);
    query.exec();
}

void AppController::deleteSectors(int id_setor)
{
    QSqlQuery query;
    query.prepare("DELETE FROM setor WHERE id_instituicao=:id_setor");
    query.bindValue(":id_instituicao",id_setor);
    query.exec();
}

void AppController::deleteEquipments(int id_equipamento)
{
    QSqlQuery query;
    query.prepare("DELETE FROM equipamento WHERE id_equipamento=:id_equipamento");
    query.bindValue(":id_equipamento",id_equipamento);
    query.exec();
}

void AppController::deleteTipoEquipamentos(int id_tipo_equipamento)
{
    QSqlQuery query;
    query.prepare("DELETE FROM tipo_equipamento WHERE id_tipo_equipamento=:id_tipo_equipamento");
    query.bindValue(":id_tipo_equipamento",id_tipo_equipamento);
    query.exec();
}

void AppController::searchInstitutions()
{
    QSqlQuery query;
    query.prepare("SELECT * FROM instituicao;");
    query.exec();
    while (query.next()) {
        int id_instituicao=query.value(0).toInt();
        QString nome=query.value(1).toString();
        QString cnpj=query.value(2).toString();
    }
}

void AppController::searchSectors()
{
    QSqlQuery query;
    query.prepare("SELECT * FROM setor;");
    query.exec();
    while (query.next()) {
        int id_setor=query.value(0).toInt();
        QString nome_setor=query.value(1).toString();
    }
}

void AppController::searchEquipments()
{
    QSqlQuery query;
    query.prepare("SELECT * FROM equipamento;");
    query.exec();
    while (query.next()) {
        int id_equipamento=query.value(0).toInt();
        QString patrimonio=query.value(1).toString();
        QString modelo=query.value(2).toString();
        QString fabricante=query.value(3).toString();
        QString data_de_aquisicao=query.value(4).toString();
        int fk_id_setor=query.value(5).toInt();
        int fk_id_tipo_equipamento=query.value(6).toInt();
    }
}

void AppController::searchTipoEquipamentos()
{
    QSqlQuery query;
    query.prepare("SELECT * FROM tipo_equipamento;");
    query.exec();
    while (query.next()) {
        int id_tipo_equipamento=query.value(0).toInt();
        QString nome=query.value(1).toString();
        QString descricao=query.value(2).toString();
    }
}

QString AppController::instituicao() const
{
    return m_instituicao;
}

void AppController::setInstituicao(const QString &value)
{
    if (m_instituicao != value) {
        m_instituicao = value;
        emit instituicaoChanged();
    }
}
QString AppController::setor() const
{
    return m_setor;
}

void AppController::setSetor(const QString &newSetor)
{
    if (m_setor == newSetor)
        return;
    m_setor = newSetor;
    emit setorChanged();
}

QString AppController::equipamento() const
{
    return m_equipamento;
}

void AppController::setEquipamento(const QString &newEquipamento)
{
    if (m_equipamento == newEquipamento)
        return;
    m_equipamento = newEquipamento;
    emit equipamentoChanged();
}
