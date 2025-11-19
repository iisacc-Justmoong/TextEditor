#include "MarkdownParser.h"

#include <QRegularExpression>
#include <QStringList>

namespace
{
QString wrapParagraph(const QString& content)
{
    if (content.isEmpty())
    {
        return QString();
    }
    return QStringLiteral("<p>%1</p>\n").arg(content);
}
} // namespace

QString MarkdownParser::toHtml(const QString& markdown) const
{
    if (markdown.isEmpty())
    {
        return QString();
    }

    QString normalized = markdown;
    normalized.replace("\r\n", "\n");

    const QStringList lines = normalized.split('\n');
    QString html;
    bool inList = false;

    auto closeList = [&]()
    {
        if (inList)
        {
            html += QStringLiteral("</ul>\n");
            inList = false;
        }
    };

    const QRegularExpression headingRegex(QStringLiteral("^(#{1,6})\\s+(.*)$"));
    const QRegularExpression listRegex(QStringLiteral("^[-*]\\s+(.*)$"));

    for (const QString& line : lines)
    {
        const QString trimmed = line.trimmed();
        if (trimmed.isEmpty())
        {
            closeList();
            html += QStringLiteral("<br/>\n");
            continue;
        }

        QRegularExpressionMatch headingMatch = headingRegex.match(trimmed);
        if (headingMatch.hasMatch())
        {
            closeList();
            const int level = headingMatch.captured(1).size();
            const QString content = formatInline(headingMatch.captured(2));
            html += QStringLiteral("<h%1>%2</h%1>\n").arg(level).arg(content);
            continue;
        }

        QRegularExpressionMatch listMatch = listRegex.match(trimmed);
        if (listMatch.hasMatch())
        {
            if (!inList)
            {
                html += QStringLiteral("<ul>\n");
                inList = true;
            }
            html += QStringLiteral("<li>%1</li>\n").arg(formatInline(listMatch.captured(1)));
            continue;
        }

        closeList();
        html += wrapParagraph(formatInline(trimmed));
    }

    closeList();
    return html.trimmed();
}

QString MarkdownParser::formatInline(const QString& text) const
{
    QString safe = text.toHtmlEscaped();

    static const QRegularExpression codeRegex(QStringLiteral("`([^`]+)`"));
    static const QRegularExpression boldRegex(QStringLiteral("\\*\\*(.+?)\\*\\*"));
    static const QRegularExpression italicRegex(QStringLiteral("(?<!\\*)\\*(?!\\*)(.+?)(?<!\\*)\\*(?!\\*)"));
    static const QRegularExpression underlineRegex(QStringLiteral("__(.+?)__"));
    static const QRegularExpression linkRegex(QStringLiteral("\\[(.+?)\\]\\((.+?)\\)"));

    safe.replace(codeRegex, QStringLiteral("<code>\\1</code>"));
    safe.replace(boldRegex, QStringLiteral("<strong>\\1</strong>"));
    safe.replace(underlineRegex, QStringLiteral("<u>\\1</u>"));
    safe.replace(italicRegex, QStringLiteral("<em>\\1</em>"));
    safe.replace(linkRegex, QStringLiteral("<a href=\"\\2\">\\1</a>"));

    return safe;
}
