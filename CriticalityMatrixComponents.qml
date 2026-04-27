import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    anchors.centerIn: parent
    Label {
        text: "Matriz de Criticidade do " + equipamentoSelecionado
    }

    GridLayout {
        columns: 5
        rows: 5
        Layout.fillWidth: true
        Layout.fillHeight: true

        Repeater {
            model: 20

            Rectangle {
                border.color: "black"
                Layout.preferredHeight: 40
                Layout.preferredWidth: 40
                color: {
                    var row = Math.floor(index / 5)
                    var col = index % 5
                    var v = row + col
                    if (v <= 1) return "green"
                    if (v == 2) return "yellow"
                    if (v == 3) return "orange"
                    return "red"
                }

                /*Label {
                    anchors.centerIn: parent
                    text: index+1
                }*/
            }
        }
    }
}
