import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ToolBar {
    id: toolbar

    signal newRequested()
    signal openRequested()
    signal saveRequested()
    signal insertTimestampRequested()

    property int wordCount: 0
    property int paragraphCount: 0
    property int lineCount: 0
    property int characterCount: 0

    RowLayout {
        anchors.fill: parent
        spacing: 8

        ToolButton {
            text: qsTr("New")
            onClicked: toolbar.newRequested()
        }

        ToolButton {
            text: qsTr("Open")
            onClicked: toolbar.openRequested()
        }

        ToolButton {
            text: qsTr("Save")
            onClicked: toolbar.saveRequested()
        }

        ToolButton {
            text: qsTr("Insert Timestamp")
            onClicked: toolbar.insertTimestampRequested()
        }

        Item {
            Layout.fillWidth: true
        }

        Label {
            text: qsTr("%1 chars | %2 words | %3 paras | %4 lines")
                  .arg(toolbar.characterCount)
                  .arg(toolbar.wordCount)
                  .arg(toolbar.paragraphCount)
                  .arg(toolbar.lineCount)
            font.bold: true
        }
    }
}
