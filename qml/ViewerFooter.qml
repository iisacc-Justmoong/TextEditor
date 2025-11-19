import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ToolBar {
    id: footer
    property int viewerMode: 0
    signal modeSelected(int mode)

    RowLayout {
        anchors.fill: parent
        spacing: 6

        ButtonGroup {
            id: viewGroup
        }

        ToolButton {
            text: qsTr("Text")
            checkable: true
            checked: footer.viewerMode === 0
            onClicked: footer.modeSelected(0)
            ButtonGroup.group: viewGroup
        }

        ToolButton {
            text: qsTr("Markdown")
            checkable: true
            checked: footer.viewerMode === 1
            onClicked: footer.modeSelected(1)
            ButtonGroup.group: viewGroup
        }

        ToolButton {
            text: qsTr("Split")
            checkable: true
            checked: footer.viewerMode === 2
            onClicked: footer.modeSelected(2)
            ButtonGroup.group: viewGroup
        }

        Item {
            Layout.fillWidth: true
        }
    }
}
