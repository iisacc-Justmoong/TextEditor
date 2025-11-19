#include "MarkdownRenderEngine.h"

MarkdownRenderEngine::MarkdownRenderEngine() = default;

QString MarkdownRenderEngine::render(const QString& markdown) const
{
    return m_parser.toHtml(markdown);
}
