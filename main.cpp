#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <appcontroller.h>
#include <qqmlcontext.h>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;
    AppController controller;
    engine.rootContext()->setContextProperty("AppController", &controller);
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("MatrizCriticidade", "Main");

    return QCoreApplication::exec();
}
