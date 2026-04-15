#ifndef APPCONTROLLER_H
#define APPCONTROLLER_H

#include <QObject>

class AppController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString instituicao READ instituicao WRITE setInstituicao NOTIFY instituicaoChanged)

public:
    explicit AppController(QObject *parent = nullptr);

    QString instituicao() const;
    void setInstituicao(const QString &value);

signals:
    void instituicaoChanged();

private:
    QString m_instituicao = "IFAL ARAPIRACA";
};

#endif