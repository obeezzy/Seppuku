#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDebug>
#include <QThread>
#include <QDir>
#include <QtQml>
#include <QIcon>
#include "seppuku.h"

void registerTypes();

int main(int argc, char *argv[])
{
#if defined(Q_OS_WIN) || defined(Q_OS_ANDROID)
    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
    QGuiApplication app(argc, argv);
    app.setWindowIcon(QIcon("../Seppuku/icons/seppuku.png"));

    registerTypes();
    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("../Seppuku/qml/main.qml")));

    return app.exec();
}

void registerTypes()
{
    qmlRegisterSingletonType<Seppuku>("Seppuku", 1, 0, "Seppuku", seppuku_provider);
}
