#include "MarkdownRenderBridge.h"

MarkdownRenderBridge::MarkdownRenderBridge(QObject* parent)
    : QObject(parent)
{
}

QString MarkdownRenderBridge::render(const QString& markdown) const
{
    return m_engine.render(markdown);
}
