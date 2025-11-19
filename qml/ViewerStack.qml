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
    onRenderedMarkdownChanged: updateMarkdownCaret()
    onViewerModeChanged: updateMarkdownCaret()
    function updateDocument(text) {
        if (document.text !== text) {
            document.text = text
        }
    }

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
            return;
        }
        var maxPos = markdownPreview.length ? markdownPreview.length : markdownEditor.length;
        var pos = Math.max(0, Math.min(markdownEditor.cursorPosition, maxPos));
        var rect = markdownPreview.positionToRectangle(pos);
        markdownCaret.x = rect.x;
        markdownCaret.y = rect.y;
        markdownCaret.height = rect.height > 0 ? rect.height : markdownEditor.cursorRectangle.height;
        markdownCaret.visible = root.viewerMode === 1 && markdownEditor.cursorVisible;
    }

    StackLayout {
        anchors.fill: parent
        currentIndex: root.viewerMode

        Item {
            ScrollView {
                anchors.fill: parent
                clip: true

                TextArea {
                    id: textEditor
                    property bool syncingFromDocument: false
                    width: parent ? parent.width : undefined
                    height: parent ? parent.height : undefined
                    padding: 0
                    leftPadding: 0
                    rightPadding: 0
                    topPadding: 0
                    bottomPadding: 0
                    wrapMode: TextEdit.Wrap
                    color: "white"
                    placeholderText: qsTr("Start typing...")
                    font.family: "Menlo"
                    font.pixelSize: 16
                    selectByMouse: true
                    persistentSelection: true
                    background: null
                    Component.onCompleted: {
                        syncingFromDocument = true
                        text = root.document.text
                        syncingFromDocument = false
                    }
                    Connections {
                        target: root.document
                        function onTextChanged() {
                            textEditor.syncingFromDocument = true
                            textEditor.text = root.document.text
                            textEditor.syncingFromDocument = false
                        }
                    }
                    onTextChanged: {
                        if (syncingFromDocument) {
                            return
                        }
                        root.updateDocument(text)
                    }
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
                        color: "#4FC3F7"
                        z: 1
                        opacity: 0.9
                        visible: root.viewerMode === 1 && markdownEditor.cursorVisible
                        radius: 1
                        enabled: false
                    }

                    TextArea {
                        id: markdownEditor
                        property bool syncingFromDocument: false
                        anchors.fill: parent
                        color: Qt.rgba(0, 0, 0, 0)
                        selectionColor: Qt.rgba(79 / 255, 195 / 255, 247 / 255, 0.35)
                        wrapMode: TextEdit.Wrap
                        cursorVisible: false
                        font.family: "Menlo"
                        font.pixelSize: 16
                        selectByMouse: true
                        persistentSelection: true
                        focus: root.viewerMode === 1
                        background: null
                        Component.onCompleted: {
                            syncingFromDocument = true
                            text = root.document.text
                            syncingFromDocument = false
                            root.updateMarkdownCaret()
                        }
                        Connections {
                            target: root.document
                            function onTextChanged() {
                                markdownEditor.syncingFromDocument = true
                                markdownEditor.text = root.document.text
                                markdownEditor.syncingFromDocument = false
                                root.updateMarkdownCaret()
                            }
                        }
                        onTextChanged: {
                            if (syncingFromDocument) {
                                return
                            }
                            root.updateDocument(text)
                            root.updateMarkdownCaret()
                        }
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

                    TextArea {
                        id: splitEditor
                        property bool syncingFromDocument: false
                        width: parent ? parent.width : undefined
                        height: parent ? parent.height : undefined
                        padding: 0
                        leftPadding: 0
                        rightPadding: 0
                        topPadding: 0
                        bottomPadding: 0
                        wrapMode: TextEdit.Wrap
                        color: "white"
                        placeholderText: qsTr("Start typing...")
                        font.family: "Menlo"
                        font.pixelSize: 16
                        selectByMouse: true
                        persistentSelection: true
                        background: null
                        Component.onCompleted: {
                            syncingFromDocument = true
                            text = root.document.text
                            syncingFromDocument = false
                        }
                        Connections {
                            target: root.document
                            function onTextChanged() {
                                splitEditor.syncingFromDocument = true
                                splitEditor.text = root.document.text
                                splitEditor.syncingFromDocument = false
                            }
                        }
                        onTextChanged: {
                            if (syncingFromDocument) {
                                return
                            }
                            root.updateDocument(text)
                        }
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
                        color: "#f1f1f1"
                        selectionColor: "#444444"
                        cursorVisible: false
                    }
                }
            }
        }
    }
}
