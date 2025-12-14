#include "utils/TimestampFormatter.h"

#include <QDateTime>
#include <cstdlib>

QString TimestampFormatter::format(TimestampFormat format) const
{
    const QDateTime now = QDateTime::currentDateTime();

    switch (format)
    {
    case TimestampFormat::LocalShort:
        return now.toString(QStringLiteral("yyyy-MM-dd HH:mm:ss t"));
    case TimestampFormat::LocalLong:
        return now.toString(QStringLiteral("dddd, dd MMM yyyy HH:mm:ss t"));
    case TimestampFormat::LocalIso:
        return now.toString(Qt::ISODateWithMs);
    case TimestampFormat::UtcIso:
        return now.toUTC().toString(Qt::ISODateWithMs);
    case TimestampFormat::GmtOffset: {
        const int minutesFromUtc = now.offsetFromUtc() / 60;
        return now.toString(QStringLiteral("yyyy-MM-dd HH:mm:ss 'GMT'")) + formatGmtOffset(minutesFromUtc);
    }
    case TimestampFormat::Default:
    default:
        return now.toString(QStringLiteral("yyyy-MM-dd HH:mm:ss"));
    }
}

TimestampFormat TimestampFormatter::fromOption(const QString& option)
{
    if (option == QStringLiteral("localShort"))
    {
        return TimestampFormat::LocalShort;
    }
    if (option == QStringLiteral("localLong"))
    {
        return TimestampFormat::LocalLong;
    }
    if (option == QStringLiteral("localIso"))
    {
        return TimestampFormat::LocalIso;
    }
    if (option == QStringLiteral("utcIso"))
    {
        return TimestampFormat::UtcIso;
    }
    if (option == QStringLiteral("gmtOffset"))
    {
        return TimestampFormat::GmtOffset;
    }

    return TimestampFormat::Default;
}

QString TimestampFormatter::formatGmtOffset(int minutesFromUtc)
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
