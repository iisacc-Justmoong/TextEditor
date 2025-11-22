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

    readonly property int wordCount: documentUtilities.wordCount
    readonly property int paragraphCount: documentUtilities.paragraphCount
    readonly property int lineCount: documentUtilities.lineCount
    readonly property int viewerTextOnly: 0
    readonly property int viewerMarkdownOnly: 1
    readonly property int viewerSplit: 2
    property int viewerMode: viewerTextOnly
    property string renderedMarkdown: ""
    property var availableFonts: Qt.fontFamilies()
    property string editorFontFamily: {
        var fonts = window.availableFonts || []
        var preferred = ["Menlo", "Consolas", "DejaVu Sans Mono", "Monospace"]
        for (var i = 0; i < preferred.length; ++i) {
            if (fonts.indexOf(preferred[i]) >= 0) {
                return preferred[i]
            }
        }
        return fonts.length > 0 ? fonts[0] : "Sans Serif"
    }
    property int editorFontPixelSize: 16
    Component.onCompleted: {
        documentUtilities.analyzeText(document.text)
        renderedMarkdown = markdownBridge.render(document.text)
    }

    function openFile() {
        openDialog.open()
    }

    function saveFile() {
        if (!document.saveCurrent()) {
            saveDialog.open()
        }
    }

    function insertTimestamp(option) {
        const payload = documentUtilities.makeTimestamp(option)
        if (!viewerStack.insertAtCursor(payload)) {
            document.insertText(document.text.length, payload)
        }
    }

    TextDocument {
        id: document
        onStatusMessage: console.info(description)
        onErrorOccurred: console.warn(description)
        onTextChanged: {
            documentUtilities.analyzeText(text)
            window.renderedMarkdown = markdownBridge.render(text)
        }
    }

    MarkdownRenderBridge {
        id: markdownBridge
    }

    DocumentUtilities {
        id: documentUtilities
    }

    header: AppToolbar {
        characterCount: document.text.length
        wordCount: window.wordCount
        paragraphCount: window.paragraphCount
        lineCount: window.lineCount
        fontOptions: window.availableFonts
        selectedFontFamily: window.editorFontFamily
        selectedFontSize: window.editorFontPixelSize
        onNewRequested: document.clear()
        onOpenRequested: window.openFile()
        onSaveRequested: window.saveFile()
        onInsertTimestampRequested: timestampMenu.popup()
        onFontFamilyChanged: function(family) {
            if (family && family.length > 0) {
                window.editorFontFamily = family
            }
        }
        onFontSizeChanged: function(size) {
            if (size > 4) {
                window.editorFontPixelSize = size
            }
        }
    }

    ViewerStack {
        id: viewerStack
        anchors.fill: parent
        document: document
        viewerMode: window.viewerMode
        renderedMarkdown: window.renderedMarkdown
        fontFamily: window.editorFontFamily
        fontPixelSize: window.editorFontPixelSize
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
