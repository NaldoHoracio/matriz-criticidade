#ifndef APPCONTROLLER_H
#define APPCONTROLLER_H

#include <QObject>

class AppController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString instituicao READ instituicao WRITE setInstituicao NOTIFY instituicaoChanged)
    Q_PROPERTY(QString setor READ setor WRITE setSetor NOTIFY setorChanged FINAL)
    Q_PROPERTY(QString equipamento READ equipamento WRITE setEquipamento NOTIFY equipamentoChanged FINAL)

public:
    explicit AppController(QObject *parent = nullptr);

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