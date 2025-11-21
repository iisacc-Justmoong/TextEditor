#include "utils/DocumentUtilities.h"

#include <QDateTime>
#include <QStringView>
#include <cstdlib>

DocumentUtilities::DocumentUtilities(QObject* parent)
    : QObject(parent)
{
}

void DocumentUtilities::analyzeText(const QString& text)
{
    const QString trimmed = text.trimmed();
    const int newWordCount = trimmed.isEmpty() ? 0 : computeWordCount(trimmed);
    const int newParagraphCount = trimmed.isEmpty() ? 0 : computeParagraphCount(trimmed);
    const int newLineCount = text.isEmpty() ? 0 : text.count(u'\n') + 1;

    if (m_wordCount == newWordCount && m_paragraphCount == newParagraphCount && m_lineCount == newLineCount)
    {
        return;
    }

    m_wordCount = newWordCount;
    m_paragraphCount = newParagraphCount;
    m_lineCount = newLineCount;
    emit metricsChanged();
}

QString DocumentUtilities::makeTimestamp(const QString& option) const
{
    const QDateTime now = QDateTime::currentDateTime();
    QString stamp;

    if (option == QStringLiteral("localShort"))
    {
        stamp = now.toString(QStringLiteral("yyyy-MM-dd HH:mm:ss t"));
    }
    else if (option == QStringLiteral("localLong"))
    {
        stamp = now.toString(QStringLiteral("dddd, dd MMM yyyy HH:mm:ss t"));
    }
    else if (option == QStringLiteral("localIso"))
    {
        stamp = now.toString(Qt::ISODateWithMs);
    }
    else if (option == QStringLiteral("utcIso"))
    {
        stamp = now.toUTC().toString(Qt::ISODateWithMs);
    }
    else if (option == QStringLiteral("gmtOffset"))
    {
        const int minutesFromUtc = now.offsetFromUtc() / 60;
        stamp = now.toString(QStringLiteral("yyyy-MM-dd HH:mm:ss 'GMT'")) + formatGmtOffset(minutesFromUtc);
    }
    else
    {
        stamp = now.toString(QStringLiteral("yyyy-MM-dd HH:mm:ss"));
    }

    return stamp + QLatin1Char('\n');
}

int DocumentUtilities::wordCount() const noexcept
{
    return m_wordCount;
}

int DocumentUtilities::paragraphCount() const noexcept
{
    return m_paragraphCount;
}

int DocumentUtilities::lineCount() const noexcept
{
    return m_lineCount;
}

int DocumentUtilities::computeWordCount(const QString& text) noexcept
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

int DocumentUtilities::computeParagraphCount(const QString& text) noexcept
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

QString DocumentUtilities::formatGmtOffset(int minutesFromUtc)
{
    const QString sign = minutesFromUtc >= 0 ? QStringLiteral("+") : QStringLiteral("-");
    const int totalMinutes = std::abs(minutesFromUtc);
    const int hours = totalMinutes / 60;
    const int minutes = totalMinutes % 60;
    return QStringLiteral("%1%2:%3")
        .arg(sign)
        .arg(hours, 2, 10, QLatin1Char('0'))
        .arg(minutes, 2, 10, QLatin1Char('0'));
}
