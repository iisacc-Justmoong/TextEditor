#pragma once

#include <QObject>
#include <QString>

#include "utils/TextMetrics.h"
#include "utils/TimestampFormatter.h"

class DocumentUtilities : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int wordCount READ wordCount NOTIFY metricsChanged FINAL)
    Q_PROPERTY(int paragraphCount READ paragraphCount NOTIFY metricsChanged FINAL)
    Q_PROPERTY(int lineCount READ lineCount NOTIFY metricsChanged FINAL)

public:
    explicit DocumentUtilities(QObject* parent = nullptr);

    Q_INVOKABLE void analyzeText(const QString& text);
    Q_INVOKABLE QString makeTimestamp(const QString& option) const;

    int wordCount() const noexcept;
    int paragraphCount() const noexcept;
    int lineCount() const noexcept;

signals:
    void metricsChanged();

private:
    TextMetrics m_metrics;
    TimestampFormatter m_timestampFormatter;
};
