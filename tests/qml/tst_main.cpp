#include <QtQuickTest>
#include <QQmlEngine>

class Setup : public QObject
{
    Q_OBJECT

public:
    Setup() {}

public slots:
    void qmlEngineAvailable(QQmlEngine *engine)
    {
        // Registrar módulos se necessário, ou configurar algo na engine antes dos testes.
        Q_UNUSED(engine);
    }
};

QUICK_TEST_MAIN_WITH_SETUP(qml_test, Setup)

#include "tst_main.moc"
