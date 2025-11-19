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
    readonly property int viewerTextOnly: 0
    readonly property int viewerMarkdownOnly: 1
    readonly property int viewerSplit: 2
    property int viewerMode: viewerTextOnly
    property string renderedMarkdown: ""
    Component.onCompleted: renderedMarkdown = markdownBridge.render(document.text)

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
        const payload = stamp + "\n"
        if (!viewerStack.insertAtCursor(payload)) {
            document.insertText(document.text.length, payload)
        }
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
        onTextChanged: {
            window.recomputeStats(text)
            window.renderedMarkdown = markdownBridge.render(text)
        }
    }

    MarkdownRenderBridge {
        id: markdownBridge
    }

    header: AppToolbar {
        characterCount: document.text.length
        wordCount: window.wordCount
        paragraphCount: window.paragraphCount
        lineCount: window.lineCount
        onNewRequested: document.clear()
        onOpenRequested: window.openFile()
        onSaveRequested: window.saveFile()
        onInsertTimestampRequested: timestampMenu.popup()
    }

    ViewerStack {
        id: viewerStack
        anchors.fill: parent
        document: document
        viewerMode: window.viewerMode
        renderedMarkdown: window.renderedMarkdown
    }

    footer: ViewerFooter {
        viewerMode: window.viewerMode
        onModeSelected: function(mode) {
            window.viewerMode = mode
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
