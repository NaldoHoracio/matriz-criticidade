#ifndef APPCONTROLLER_H
#define APPCONTROLLER_H

#include <QObject>
#include <QQmlEngine>
#include <QGuiApplication>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>

class AppController : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
    Q_PROPERTY(QString instituicao READ instituicao WRITE setInstituicao NOTIFY instituicaoChanged)
    Q_PROPERTY(QString setor READ setor WRITE setSetor NOTIFY setorChanged FINAL)
    Q_PROPERTY(QString equipamento READ equipamento WRITE setEquipamento NOTIFY equipamentoChanged FINAL)

public:
    explicit AppController(QObject *parent = nullptr);
    Q_INVOKABLE void setupDatabase();
    Q_INVOKABLE void insertIntoInstitutions(QString nome,QString cnpj);
    Q_INVOKABLE void insertIntoSectors(QString nome,int id_instituicao);
    Q_INVOKABLE void insertIntoEquipments(QString patrimonio,QString modelo,QString fabricante,QString data_aquisição,int id_setor,int id_tipo_equipamento);
    Q_INVOKABLE void insertIntoTipoEquipamentos(QString nome, QString descricao);
    Q_INVOKABLE void updateInstitutions(QString nome,QString cnpj);
    Q_INVOKABLE void updateSectors(QString nome,int id_instituicao);
    Q_INVOKABLE void updateEquipments(QString patrimonio,QString modelo,QString fabricante,QString data_aquisição,int id_setor,int id_tipo_equipamento);
    Q_INVOKABLE void updateTipoEquipamentos(QString nome, QString descricao);
    Q_INVOKABLE void deleteInstitutions(QString nome,QString cnpj);
    Q_INVOKABLE void deleteSectors(QString nome,int id_instituicao);
    Q_INVOKABLE void deleteEquipments(QString patrimonio,QString modelo,QString fabricante,QString data_aquisição,int id_setor,int id_tipo_equipamento);
    Q_INVOKABLE void deleteTipoEquipamentos(QString nome, QString descricao);
    QString instituicao() const;
    void setInstituicao(const QString &value);

    QString setor() const;
    void setSetor(const QString &newSetor);

    QString equipamento() const;
    void setEquipamento(const QString &newEquipamento);

signals:
    void instituicaoChanged();

    void setorChanged();

    void equipamentoChanged();

private:
    QString m_instituicao = "IFAL ARAPIRACA";
    QString m_setor;
    QString m_equipamento;
};

#endif