#pragma once

#include <QObject>
#include <QString>

#include "render/MarkdownRenderEngine.h"

class MarkdownRenderBridge : public QObject
{
    Q_OBJECT

public:
    explicit MarkdownRenderBridge(QObject* parent = nullptr);

    Q_INVOKABLE QString render(const QString& markdown) const;

private:
    MarkdownRenderEngine m_engine;
};
