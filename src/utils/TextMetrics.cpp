#include "utils/TextMetrics.h"

#include <QStringView>

namespace
{
constexpr int INITIAL_LINE_COUNT = 1;
}

TextMetrics TextMetrics::fromText(const QString& text) noexcept
{
    TextMetrics metrics;
    if (text.isEmpty())
    {
        return metrics;
    }

    const QStringView view(text);
    metrics.lineCount = INITIAL_LINE_COUNT;
    bool inWord = false;
    bool inParagraph = false;
    bool currentLineHasContent = false;

    auto handleLineBreak = [&]()
    {
        if (currentLineHasContent && !inParagraph)
        {
            ++metrics.paragraphCount;
            inParagraph = true;
        }
        else if (!currentLineHasContent)
        {
            inParagraph = false;
        }

        currentLineHasContent = false;
        inWord = false;
        ++metrics.lineCount;
    };

    qsizetype i = 0;
    while (i < view.size())
    {
        const QChar ch = view.at(i);
        if (ch == u'\r')
        {
            const bool nextIsLf = (i + 1 < view.size()) && (view.at(i + 1) == u'\n');
            handleLineBreak();
            i += nextIsLf ? 2 : 1;
            continue;
        }

        if (ch == u'\n')
        {
            handleLineBreak();
            ++i;
            continue;
        }

        if (!ch.isSpace())
        {
            currentLineHasContent = true;
            if (!inWord)
            {
                ++metrics.wordCount;
                inWord = true;
            }
        }
        else
        {
            inWord = false;
        }

        ++i;
    }

    if (currentLineHasContent && !inParagraph)
    {
        ++metrics.paragraphCount;
    }

    return metrics;
}
