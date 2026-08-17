#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QPalette>
#include <QColor>
#include <QtQuickControls2/QQuickStyle>
#include "DatabaseManager.h"
#include "TableModel.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setOrganizationName("CriticidadeApp");
    app.setApplicationName("MatrizCriticidade");

    QQuickStyle::setStyle("Material");

    QPalette palette = app.palette();
    palette.setColor(QPalette::Window, QColor("#f5f5f5"));
    palette.setColor(QPalette::WindowText, QColor("#212121"));
    palette.setColor(QPalette::Highlight, QColor("#2e7d32"));
    palette.setColor(QPalette::HighlightedText, QColor("#ffffff"));
    palette.setColor(QPalette::Button, QColor("#e0e0e0"));
    palette.setColor(QPalette::ButtonText, QColor("#212121"));
    app.setPalette(palette);

    QQmlApplicationEngine engine;
    DatabaseManager dbManager(&engine);
    dbManager.setBaseUrl(qEnvironmentVariable("CRITICIDADE_API_URL", "http://localhost:8000"));
    if (!dbManager.initialize())
        return -1;

    qmlRegisterSingletonInstance("CriticidadeApp", 1, 0, "Database", &dbManager);
    qmlRegisterType<TableModel>("CriticidadeApp", 1, 0, "TableModel");

    const QUrl url("qrc:/CriticidadeApp/App.qml");
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
        &app, []() { QCoreApplication::exit(-1); });
    engine.load(url);

    return app.exec();
}
