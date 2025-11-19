#include "TextDocument.h"

#include <QFile>
#include <QFileInfo>
#include <QTextStream>

#if defined(QT_FEATURE_textcodec) && QT_FEATURE_textcodec == 1
#define TEXTEDITOR_HAS_TEXTCODEC 1
#include <QStringConverter>
#else
#define TEXTEDITOR_HAS_TEXTCODEC 0
#endif

namespace
{
QString fallbackFileName(const QString& path)
{
    if (path.isEmpty())
    {
        return QStringLiteral("untitled");
    }
    return QFileInfo(path).fileName();
}
} // namespace

TextDocument::TextDocument(QObject* parent)
    : QObject(parent)
{
}

QString TextDocument::text() const
{
    return m_text;
}

void TextDocument::setText(const QString& text)
{
    if (text == m_text)
    {
        return;
    }

    m_text = text;
    emit textChanged();
}

QString TextDocument::filePath() const
{
    return m_filePath;
}

void TextDocument::clear()
{
    const bool hadText = !m_text.isEmpty();
    const bool hadPath = !m_filePath.isEmpty();

    m_text.clear();
    m_filePath.clear();

    if (hadText)
    {
        emit textChanged();
    }
    if (hadPath)
    {
        emit filePathChanged();
    }

    emit statusMessage(tr("Started a new document"));
}

bool TextDocument::loadFromFile(const QUrl& url)
{
    const QString localPath = toLocalFile(url);
    if (localPath.isEmpty())
    {
        emit errorOccurred(tr("Select a readable text file."));
        return false;
    }

    QFile file(localPath);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
    {
        emit errorOccurred(tr("Failed to open %1").arg(localPath));
        return false;
    }

    QTextStream stream(&file);
#if TEXTEDITOR_HAS_TEXTCODEC
    stream.setEncoding(QStringConverter::Utf8);
#endif
    const QString contents = stream.readAll();
    file.close();

    setText(contents);
    if (m_filePath != localPath)
    {
        m_filePath = localPath;
        emit filePathChanged();
    }

    emit statusMessage(tr("Loaded %1").arg(fallbackFileName(localPath)));
    return true;
}

bool TextDocument::saveToFile(const QUrl& url)
{
    const QString localPath = toLocalFile(url);
    if (localPath.isEmpty())
    {
        emit errorOccurred(tr("Choose a destination path."));
        return false;
    }

    if (!writeToFile(localPath))
    {
        emit errorOccurred(tr("Failed to save %1").arg(localPath));
        return false;
    }

    if (m_filePath != localPath)
    {
        m_filePath = localPath;
        emit filePathChanged();
    }

    emit statusMessage(tr("Saved %1").arg(fallbackFileName(localPath)));
    return true;
}

bool TextDocument::saveCurrent()
{
    if (m_filePath.isEmpty())
    {
        emit errorOccurred(tr("No file path associated with this document."));
        return false;
    }

    if (!writeToFile(m_filePath))
    {
        emit errorOccurred(tr("Failed to save %1").arg(m_filePath));
        return false;
    }

    emit statusMessage(tr("Saved %1").arg(fallbackFileName(m_filePath)));
    return true;
}

bool TextDocument::insertText(int position, const QString& value)
{
    const int insertPos = qBound(0, position, m_text.size());
    if (value.isEmpty())
    {
        return false;
    }

    m_text.insert(insertPos, value);
    emit textChanged();
    return true;
}

bool TextDocument::removeText(int position, int length)
{
    if (position < 0 || length <= 0 || position >= m_text.size())
    {
        return false;
    }

    const int clampedLength = qBound(0, length, m_text.size() - position);
    m_text.remove(position, clampedLength);
    emit textChanged();
    return true;
}

QString TextDocument::toLocalFile(const QUrl& url) const
{
    if (!url.isEmpty())
    {
        if (url.isLocalFile())
        {
            return url.toLocalFile();
        }
        return url.toString(QUrl::PreferLocalFile);
    }
    return QString();
}

bool TextDocument::writeToFile(const QString& path)
{
    QFile file(path);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text))
    {
        return false;
    }

    QTextStream stream(&file);
#if TEXTEDITOR_HAS_TEXTCODEC
    stream.setEncoding(QStringConverter::Utf8);
#endif
    stream << m_text;
    file.close();
    return true;
}
