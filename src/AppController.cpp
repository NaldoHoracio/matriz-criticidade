#include "AppController.h"

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