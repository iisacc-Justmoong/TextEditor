import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import TextEditor.Backend 1.0

ApplicationWindow {
    id: window
    width: 1024
    height: 720
    visible: true
    title: (document.filePath === "" ? qsTr("Untitled") : document.filePath.split("/").pop()) + qsTr(" - TextEditor")

    property int wordCount: 0
    property int paragraphCount: 0
    property int lineCount: 0

    function openFile() {
        openDialog.open()
    }

    function saveFile() {
        if (!document.saveCurrent()) {
            saveDialog.open()
        }
    }

    function insertTimestamp(option) {
        const now = new Date()
        let stamp = ""
        switch (option) {
        case "localShort":
            stamp = Qt.formatDateTime(now, "yyyy-MM-dd HH:mm:ss t")
            break
        case "localLong":
            stamp = Qt.formatDateTime(now, "dddd, dd MMM yyyy HH:mm:ss t")
            break
        case "localIso":
            stamp = Qt.formatDateTime(now, "yyyy-MM-dd'T'HH:mm:ss.zzz")
            break
        case "utcIso":
            stamp = now.toISOString()
            break
        case "gmtOffset":
            stamp = Qt.formatDateTime(now, "yyyy-MM-dd HH:mm:ss 'GMT'") + offsetString(-now.getTimezoneOffset())
            break
        default:
            stamp = Qt.formatDateTime(now, "yyyy-MM-dd HH:mm:ss")
            break
        }
        document.insertText(editor.cursorPosition, stamp + "\n")
    }

    function offsetString(minutesFromUtc) {
        const sign = minutesFromUtc >= 0 ? "+" : "-"
        const total = Math.abs(minutesFromUtc)
        const hours = Math.floor(total / 60)
        const minutes = total % 60
        return sign + padNumber(hours) + ":" + padNumber(minutes)
    }

    function padNumber(value) {
        return value < 10 ? "0" + value : value
    }

    function recomputeStats(text) {
        const trimmed = text.trim()
        wordCount = trimmed.length === 0 ? 0 : trimmed.split(/\s+/).length
        paragraphCount = trimmed.length === 0 ? 0 : trimmed.split(/\n\s*\n/).length
        lineCount = text.length === 0 ? 0 : text.split(/\n/).length
    }

    TextDocument {
        id: document
        onStatusMessage: console.info(description)
        onErrorOccurred: console.warn(description)
    }

    header: ToolBar {
        RowLayout {
            anchors.fill: parent
            spacing: 8

            ToolButton {
                text: qsTr("New")
                onClicked: document.clear()
            }

            ToolButton {
                text: qsTr("Open")
                onClicked: window.openFile()
            }

            ToolButton {
                text: qsTr("Save")
                onClicked: window.saveFile()
            }

            ToolButton {
                id: timestampButton
                text: qsTr("Insert Timestamp")
                onClicked: timestampMenu.popup(timestampButton)
            }

            Item {
                Layout.fillWidth: true
            }

            Label {
                text: qsTr("%1 chars | %2 words | %3 paras | %4 lines")
                      .arg(document.text.length)
                      .arg(window.wordCount)
                      .arg(window.paragraphCount)
                      .arg(window.lineCount)
                font.bold: true
            }
        }
    }

    ScrollView {
        anchors.fill: parent
        clip: true

        TextArea {
            id: editor
            anchors.fill: parent
            padding: 0
            leftPadding: 0
            rightPadding: 0
            topPadding: 0
            bottomPadding: 0
            text: document.text
            wrapMode: TextEdit.Wrap
            color: "white"
            placeholderText: qsTr("Start typing...")
            font.family: "Menlo"
            font.pixelSize: 16
            selectByMouse: true
            persistentSelection: true
            background: null
            onTextChanged: {
                if (document.text !== text) {
                    document.text = text
                }
                window.recomputeStats(text)
            }
        }
    }

    Menu {
        id: timestampMenu
        MenuItem {
            text: qsTr("Local 24h")
            onTriggered: window.insertTimestamp("localShort")
        }
        MenuItem {
            text: qsTr("Local long form")
            onTriggered: window.insertTimestamp("localLong")
        }
        MenuItem {
            text: qsTr("Local ISO 8601")
            onTriggered: window.insertTimestamp("localIso")
        }
        MenuItem {
            text: qsTr("UTC ISO 8601")
            onTriggered: window.insertTimestamp("utcIso")
        }
        MenuItem {
            text: qsTr("GMT with offset")
            onTriggered: window.insertTimestamp("gmtOffset")
        }
    }

    FileDialog {
        id: openDialog
        title: qsTr("Open Text File")
        fileMode: FileDialog.OpenFile
        nameFilters: [qsTr("Text files (*.txt *.md)"), qsTr("All files (*)")]
        onAccepted: document.loadFromFile(selectedFile)
    }

    FileDialog {
        id: saveDialog
        title: qsTr("Save Text File")
        fileMode: FileDialog.SaveFile
        nameFilters: [qsTr("Text files (*.txt *.md)"), qsTr("All files (*)")]
        onAccepted: document.saveToFile(selectedFile)
    }

    Shortcut {
        sequence: StandardKey.New
        onActivated: document.clear()
    }

    Shortcut {
        sequence: StandardKey.Open
        onActivated: window.openFile()
    }

    Shortcut {
        sequence: StandardKey.Save
        onActivated: window.saveFile()
    }
}
