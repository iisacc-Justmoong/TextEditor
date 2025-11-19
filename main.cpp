#include "editor/TextDocument.h"

#include <QCoreApplication>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtQml/qqml.h>

using namespace Qt::StringLiterals;

int main(int argc, char* argv[])
{
    QGuiApplication app(argc, argv);
    app.setOrganizationName("TextEditor");
    app.setApplicationName("TextEditor");

    qmlRegisterType<TextDocument>("TextEditor.Backend", 1, 0, "TextDocument");

    QQmlApplicationEngine engine;
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreated,
        &app,
        [](QObject* obj)
        {
            if (!obj)
            {
                QCoreApplication::exit(-1);
            }
        },
        Qt::QueuedConnection);

    engine.loadFromModule("TextEditor"_L1, "Main"_L1);
    if (engine.rootObjects().isEmpty())
    {
        return -1;
    }

    return app.exec();
}
