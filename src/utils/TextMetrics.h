#pragma once

#include <QString>

struct TextMetrics
{
    int wordCount = 0;
    int paragraphCount = 0;
    int lineCount = 0;

    bool operator==(const TextMetrics& other) const noexcept = default;
    bool operator!=(const TextMetrics& other) const noexcept = default;

    [[nodiscard]] static TextMetrics fromText(const QString& text) noexcept;

private:
    [[nodiscard]] static int computeWordCount(const QString& text) noexcept;
    [[nodiscard]] static int computeParagraphCount(const QString& text) noexcept;
};
