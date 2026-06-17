#include <QtTest>
#include "../../header/appcontroller.h"

class TestAppController : public QObject
{
    Q_OBJECT

private slots:
    void initTestCase();
    void testSetInstituicao();
    void cleanupTestCase();
};

void TestAppController::initTestCase()
{
    // Código de inicialização (executado uma vez antes do primeiro teste)
}

void TestAppController::testSetInstituicao()
{
    AppController controller;
    
    // Testa o valor padrão
    QCOMPARE(controller.instituicao(), QString("IFAL ARAPIRACA"));
    
    // Testa a modificação do valor
    controller.setInstituicao("NOVA INSTITUICAO");
    QCOMPARE(controller.instituicao(), QString("NOVA INSTITUICAO"));
}

void TestAppController::cleanupTestCase()
{
    // Código de limpeza (executado após todos os testes)
}

QTEST_MAIN(TestAppController)
#include "tst_appcontroller.moc"
