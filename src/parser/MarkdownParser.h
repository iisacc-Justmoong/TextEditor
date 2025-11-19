#pragma once

#include <QString>

class MarkdownParser
{
public:
    MarkdownParser() = default;

    QString toHtml(const QString& markdown) const;

private:
    QString formatInline(const QString& text) const;
};
