#pragma once

#include <QString>

#include "parser/MarkdownParser.h"

class MarkdownRenderEngine
{
public:
    MarkdownRenderEngine();

    QString render(const QString& markdown) const;

private:
    MarkdownParser m_parser;
};
