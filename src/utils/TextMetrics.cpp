#include "utils/TextMetrics.h"

#include <QStringView>

TextMetrics TextMetrics::fromText(const QString& text) noexcept
{
    TextMetrics metrics;
    const QString trimmed = text.trimmed();

    if (!trimmed.isEmpty())
    {
        metrics.wordCount = computeWordCount(trimmed);
        metrics.paragraphCount = computeParagraphCount(trimmed);
    }

    metrics.lineCount = text.isEmpty() ? 0 : text.count(u'\n') + 1;
    return metrics;
}

int TextMetrics::computeWordCount(const QString& text) noexcept
{
    bool inWord = false;
    int count = 0;

    for (const QChar ch : text)
    {
        if (ch.isSpace())
        {
            inWord = false;
            continue;
        }

        if (!inWord)
        {
            ++count;
            inWord = true;
        }
    }

    return count;
}

int TextMetrics::computeParagraphCount(const QString& text) noexcept
{
    int paragraphs = 0;
    bool inParagraph = false;
    const QStringView view(text);

    qsizetype start = 0;
    for (qsizetype i = 0; i <= view.size(); ++i)
    {
        const bool atEnd = (i == view.size());
        const QChar current = atEnd ? QChar(u'\n') : view.at(i);
        if (current != u'\n' && !atEnd)
        {
            continue;
        }

        const qsizetype length = i - start;
        const QStringView line = view.sliced(start, length);
        const bool hasContent = !line.trimmed().isEmpty();

        if (hasContent)
        {
            if (!inParagraph)
            {
                ++paragraphs;
                inParagraph = true;
            }
        }
        else
        {
            inParagraph = false;
        }

        start = i + 1;
    }

    return paragraphs;
}
