import QtQuick
import QtQuick.Controls
import TextEditor.Backend 1.0

TextArea {
    id: editor
    required property TextDocument document
    property bool syncFromDocument: true
    property bool syncToDocument: true
    property bool _syncing: false

    wrapMode: TextEdit.Wrap
    selectByMouse: true
    persistentSelection: true

    function refreshFromDocument() {
        if (!editor.syncFromDocument || !editor.document) {
            return
        }
        editor._syncing = true
        editor.text = editor.document.text
        editor._syncing = false
    }

    Component.onCompleted: refreshFromDocument()
    onDocumentChanged: refreshFromDocument()

    Connections {
        target: editor.document
        enabled: editor.syncFromDocument && editor.document
        function onTextChanged() {
            editor.refreshFromDocument()
        }
    }

    Connections {
        target: editor
        enabled: editor.syncToDocument
        function onTextChanged() {
            if (!editor.document || editor._syncing) {
                return
            }
            editor.document.text = editor.text
        }
    }
}
