import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts

Rectangle {
    id: root
    color: "white"
    border.color: "#ccc"

    property var tableModel: null
    property var columns: []
    property int currentRow: -1

    signal rowSelected(int row)
    signal actionClicked(int row, string action)

    function resolveDisplay(col, val) {
        if (val === undefined || val === null) return ""
        if (col.resolve !== undefined) {
            for (var i = 0; i < col.resolve.length; i++) {
                if (col.resolve[i].id === val) return col.resolve[i].display || ""
            }
        }
        return String(val)
    }

    function colWidth(index) {
        if (index < columns.length - 1) return columns[index].width
        var fixed = 0
        for (var i = 0; i < columns.length - 1; i++) fixed += columns[i].width
        return Math.max(columns[index].width, listView.width - fixed)
    }

    onVisibleChanged: {
        if (visible) listView.forceActiveFocus()
    }

    ListView {
        id: listView
        anchors.fill: parent
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        ScrollBar.vertical: ScrollBar { }
        focus: true
        activeFocusOnTab: true
        keyNavigationEnabled: true

        Keys.onUpPressed: {
            if (root.currentRow > 0) {
                root.currentRow--
                listView.positionViewAtIndex(root.currentRow, ListView.Contain)
            }
        }
        Keys.onDownPressed: {
            if (root.currentRow < listView.count - 1) {
                root.currentRow++
                listView.positionViewAtIndex(root.currentRow, ListView.Contain)
            }
        }
        Keys.onReturnPressed: {
            if (root.currentRow >= 0) root.rowSelected(root.currentRow)
        }

        header: Rectangle {
            width: listView.width
            height: 30
            color: "#2e7d32"
            z: 2

            Row {
                anchors.fill: parent
                Repeater {
                    model: columns
                    Rectangle {
                        width: root.colWidth(index)
                        height: parent.height
                        color: "transparent"
                        border.color: "#ccc"
                        Label {
                            anchors.centerIn: parent
                            text: modelData.label
                            font.bold: true
                            font.pixelSize: 12
                            color: "white"
                        }
                    }
                }
            }
        }

        model: tableModel ? tableModel.count : 0

        delegate: Rectangle {
            readonly property int rowIndex: index
            width: listView.width
            height: 36
            color: {
                if (rowIndex === root.currentRow) return "#bbdefb"
                return rowIndex % 2 === 0 ? "#f5f5f5" : "white"
            }

            MouseArea {
                id: rowMouse
                anchors.fill: parent
                property int clickCount: 0
                onClicked: {
                    clickCount++
                    if (clickCount === 1) {
                        root.currentRow = rowIndex
                        listView.forceActiveFocus()
                        dblTimer.restart()
                    } else if (clickCount >= 2) {
                        clickCount = 0
                        dblTimer.stop()
                        root.rowSelected(rowIndex)
                    }
                }
                Timer {
                    id: dblTimer
                    interval: 400
                    onTriggered: { rowMouse.clickCount = 0 }
                }
            }

            Row {
                anchors.fill: parent
                Repeater {
                    model: columns
                    Rectangle {
                        width: root.colWidth(index)
                        height: parent.height
                        color: "transparent"
                        border.color: "#eee"
                        clip: true
                        Button {
                            anchors.centerIn: parent
                            visible: modelData.action !== undefined
                            text: modelData.action ? modelData.action.text || "" : ""
                            implicitWidth: parent.width - 8
                            implicitHeight: parent.height - 6
                            font.pixelSize: 12
                            font.bold: true
                            highlighted: true
                            Material.accent: "#2e7d32"
                            onClicked: root.actionClicked(rowIndex, modelData.action.name || "")
                        }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 6
                            visible: modelData.action === undefined
                            text: {
                                tableModel && tableModel.revision
                                var v = tableModel ? tableModel.get(rowIndex) : null
                                if (!v) return ""
                                if (modelData.compute) return modelData.compute(v)
                                if (modelData.resolve !== undefined) {
                                    var r = root.resolveDisplay(modelData, v[modelData.field] !== undefined ? v[modelData.field] : -1)
                                    if (r !== String(v[modelData.field])) return r
                                    return ""
                                }
                                return root.resolveDisplay(modelData, v[modelData.field])
                            }
                            color: "black"
                            elide: Text.ElideRight
                            font.pixelSize: 13
                        }
                    }
                }
            }
        }
    }
}
