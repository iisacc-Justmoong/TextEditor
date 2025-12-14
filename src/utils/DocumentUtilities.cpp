#include "utils/DocumentUtilities.h"

DocumentUtilities::DocumentUtilities(QObject* parent)
    : QObject(parent)
{
}

void DocumentUtilities::analyzeText(const QString& text)
{
    const TextMetrics metrics = TextMetrics::fromText(text);
    if (metrics == m_metrics)
    {
        return;
    }

    m_metrics = metrics;
    emit metricsChanged();
}

QString DocumentUtilities::makeTimestamp(const QString& option) const
{
    const TimestampFormat format = TimestampFormatter::fromOption(option);
    return m_timestampFormatter.format(format) + QLatin1Char('\n');
}

int DocumentUtilities::wordCount() const noexcept
{
    return m_metrics.wordCount;
}

int DocumentUtilities::paragraphCount() const noexcept
{
    return m_metrics.paragraphCount;
}

int DocumentUtilities::lineCount() const noexcept
{
    return m_metrics.lineCount;
}
