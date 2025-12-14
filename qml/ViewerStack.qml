import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQml
import TextEditor.Backend 1.0

Item {
    id: root
    required property TextDocument document
    property int viewerMode: 0
    property string renderedMarkdown: ""
    property string fontFamily: "Menlo"
    property int fontPixelSize: 16
    onRenderedMarkdownChanged: updateMarkdownCaret()
    onViewerModeChanged: updateMarkdownCaret()

    function insertAtCursor(value) {
        let target = null
        if (viewerMode === 0) {
            target = textEditor
        } else if (viewerMode === 1) {
            target = markdownEditor
        } else if (viewerMode === 2) {
            target = splitEditor
        }

        if (target) {
            const pos = target.cursorPosition
            target.insert(pos, value)
            target.cursorPosition = pos + value.length
            return true
        }
        return false
    }

    function updateMarkdownCaret() {
        if (!markdownPreview || !markdownEditor) {
            return
        }
        const maxPos = markdownPreview.length ? markdownPreview.length : markdownEditor.length
        const pos = Math.max(0, Math.min(markdownEditor.cursorPosition, maxPos))
        const rect = markdownPreview.positionToRectangle(pos)
        markdownCaret.x = rect.x
        markdownCaret.y = rect.y
        markdownCaret.height = rect.height > 0 ? rect.height : markdownEditor.cursorRectangle.height
        markdownCaret.visible = root.viewerMode === 1 && markdownEditor.cursorVisible;
    }

    StackLayout {
        anchors.fill: parent
        currentIndex: root.viewerMode

        Item {
            ScrollView {
                anchors.fill: parent
                clip: true

                DocumentTextArea {
                    id: textEditor
                    document: root.document
                    width: parent ? parent.width : undefined
                    height: parent ? parent.height : undefined
                    padding: 0
                    leftPadding: 0
                    rightPadding: 0
                    topPadding: 0
                    bottomPadding: 0
                    color: "white"
                    placeholderText: qsTr("Start typing...")
                    font.family: root.fontFamily
                    font.pixelSize: root.fontPixelSize
                    background: null
                }
            }
        }

        Item {
            anchors.fill: parent
            clip: true

            Flickable {
                id: markdownFlickable
                anchors.fill: parent
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                flickableDirection: Flickable.VerticalFlick
                ScrollBar.vertical: ScrollBar {}
                contentWidth: width
                contentHeight: Math.max(markdownPreview.contentHeight, markdownEditor.contentHeight)

                Item {
                    id: markdownOverlay
                    width: markdownFlickable.width
                    height: Math.max(markdownPreview.contentHeight, markdownEditor.contentHeight)

                    TextEdit {
                        id: markdownPreview
                        anchors.fill: parent
                        textFormat: TextEdit.RichText
                        wrapMode: TextEdit.Wrap
                        font.family: root.fontFamily
                        font.pixelSize: root.fontPixelSize
                        text: root.renderedMarkdown
                        readOnly: true
                        enabled: false
                        focus: false
                        color: "#f1f1f1"
                        cursorVisible: false
                        selectByMouse: false
                        persistentSelection: false
                        z: 0
                        opacity: 0.96
                        Component.onCompleted: root.updateMarkdownCaret()
                        onTextChanged: root.updateMarkdownCaret()
                    }

                    Rectangle {
                        id: markdownCaret
                        width: 2
                        height: markdownEditor.cursorRectangle.height
                        color: "#ffffff"
                        z: 1
                        opacity: 0.9
                        visible: root.viewerMode === 1 && markdownEditor.cursorVisible
                        radius: 1
                        enabled: false
                    }

                    DocumentTextArea {
                        id: markdownEditor
                        document: root.document
                        anchors.fill: parent
                        color: Qt.rgba(0, 0, 0, 0)
                        selectionColor: Qt.rgba(79 / 255, 195 / 255, 247 / 255, 0.35)
                        cursorVisible: false
                        font.family: root.fontFamily
                        font.pixelSize: root.fontPixelSize
                        focus: root.viewerMode === 1
                        background: null
                        Component.onCompleted: root.updateMarkdownCaret()
                        onTextChanged: root.updateMarkdownCaret()
                        onCursorPositionChanged: root.updateMarkdownCaret()
                        onCursorVisibleChanged: root.updateMarkdownCaret()
                    }
                }
            }
        }

        Item {
            RowLayout {
                anchors.fill: parent
                spacing: 1

                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    DocumentTextArea {
                        id: splitEditor
                        document: root.document
                        width: parent ? parent.width : undefined
                        height: parent ? parent.height : undefined
                        padding: 0
                        leftPadding: 0
                        rightPadding: 0
                        topPadding: 0
                        bottomPadding: 0
                        color: "white"
                        placeholderText: qsTr("Start typing...")
                        font.family: root.fontFamily
                        font.pixelSize: root.fontPixelSize
                        background: null
                    }
                }

                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    TextArea {
                        readOnly: true
                        width: parent ? parent.width : undefined
                        height: parent ? parent.height : undefined
                        wrapMode: TextEdit.Wrap
                        textFormat: TextEdit.RichText
                        text: root.renderedMarkdown
                        font.family: root.fontFamily
                        font.pixelSize: root.fontPixelSize
                        color: "#f1f1f1"
                        selectionColor: "#444444"
                        cursorVisible: false
                    }
                }
            }
        }
    }
}
