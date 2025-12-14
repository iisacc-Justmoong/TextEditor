#pragma once

#include <QString>

enum class TimestampFormat
{
    LocalShort,
    LocalLong,
    LocalIso,
    UtcIso,
    GmtOffset,
    Default
};

class TimestampFormatter
{
public:
    [[nodiscard]] QString format(TimestampFormat format) const;
    [[nodiscard]] static TimestampFormat fromOption(const QString& option);

private:
    [[nodiscard]] static QString formatGmtOffset(int minutesFromUtc);
};
