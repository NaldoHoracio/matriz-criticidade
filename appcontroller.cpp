#include "appcontroller.h"

AppController::AppController(QObject *parent)
    : QObject(parent)
{
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
