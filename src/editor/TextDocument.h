#pragma once

#include <QObject>
#include <QString>
#include <QUrl>

class TextDocument : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString text READ text WRITE setText NOTIFY textChanged FINAL)
    Q_PROPERTY(QString filePath READ filePath NOTIFY filePathChanged FINAL)

public:
    explicit TextDocument(QObject* parent = nullptr);

    QString text() const;
    void setText(const QString& text);

    QString filePath() const;

    Q_INVOKABLE void clear();
    Q_INVOKABLE bool loadFromFile(const QUrl& url);
    Q_INVOKABLE bool saveToFile(const QUrl& url);
    Q_INVOKABLE bool saveCurrent();
    Q_INVOKABLE bool insertText(int position, const QString& value);
    Q_INVOKABLE bool removeText(int position, int length);

signals:
    void textChanged();
    void filePathChanged();
    void errorOccurred(const QString& description);
    void statusMessage(const QString& description);

private:
    QString toLocalFile(const QUrl& url) const;
    bool writeToFile(const QString& path);

    QString m_text;
    QString m_filePath;
};
