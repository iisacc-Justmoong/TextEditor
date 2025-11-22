import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ToolBar {
    id: toolbar

    signal newRequested()
    signal openRequested()
    signal saveRequested()
    signal insertTimestampRequested()
    signal fontFamilyChanged(string family)
    signal fontSizeChanged(int size)

    property int wordCount: 0
    property int paragraphCount: 0
    property int lineCount: 0
    property int characterCount: 0
    property var fontOptions: []
    property string selectedFontFamily: ""
    property int selectedFontSize: 16

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

        Label {
            text: qsTr("Font:")
            verticalAlignment: Text.AlignVCenter
        }

        ComboBox {
            id: fontSelector
            Layout.preferredWidth: 200
            model: toolbar.fontOptions ? toolbar.fontOptions : []
            enabled: toolbar.fontOptions && toolbar.fontOptions.length > 0
            currentIndex: {
                if (!toolbar.fontOptions || toolbar.fontOptions.length === 0) {
                    return -1
                }
                var idx = toolbar.fontOptions.indexOf(toolbar.selectedFontFamily)
                return idx >= 0 ? idx : 0
            }
            onActivated: toolbar.fontFamilyChanged(currentText)
        }

        Label {
            text: qsTr("Size:")
            verticalAlignment: Text.AlignVCenter
        }

        SpinBox {
            id: fontSizeSelector
            Layout.preferredWidth: 80
            from: 8
            to: 72
            value: toolbar.selectedFontSize
            editable: true
            onValueChanged: {
                if (value !== toolbar.selectedFontSize) {
                    toolbar.fontSizeChanged(value)
                }
            }
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
