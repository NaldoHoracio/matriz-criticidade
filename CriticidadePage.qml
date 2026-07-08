import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import CriticidadeApp

Page {
    property var equipamentos: []

    TableModel {
        id: critModel
        tableName: "criticidade"
        database: Database
    }

    function refresh() {
        equipamentos = Database.foreignOptions("equipamento", "modelo")
        critModel.refresh()
    }

    Component.onCompleted: refresh()
    Connections { target: Database; function onDataChanged(table) { if (table === "criticidade" || table === "equipamento") refresh() } }

    ColumnLayout {
        anchors.fill: parent
        spacing: 4

        RowLayout {
            Layout.fillWidth: true
            Layout.margins: 8
            Label { text: "Resultados de Criticidade"; font.pixelSize: 16; font.bold: true; Layout.fillWidth: true }
            Button { text: "Atualizar"; onClicked: refresh() }
        }

        Frame {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 8
            padding: 0

            TableComponent {
                id: table
                anchors.fill: parent
                tableModel: critModel
                columns: [
                    { label: "Equipamento", width: 200, field: "id_equipamento", resolve: equipamentos },
                    { label: "Função", width: 80, field: "Funcao" },
                    { label: "Risco", width: 80, field: "Risco" },
                    { label: "Risco ABC", width: 100, field: "RiscoAbc" },
                    { label: "Perda ABC", width: 100, field: "PerdaAbc" },
                    { label: "Tempo", width: 80, field: "Tempo" },
                    { label: "Interrupção", width: 110, field: "Interrupcao" },
                    { label: "MTTF", width: 80, field: "Mttf" },
                    { label: "MTTR", width: 80, field: "Mttr" },
                    { label: "Final", width: 80, field: "criticidade_final" }
                ]
            }
        }

        RowLayout {
            Layout.margins: 8
            Layout.alignment: Qt.AlignRight
            spacing: 8
            Button { text: "Excluir"; enabled: table.currentRow >= 0; onClicked: deleteConfirm.open() }
        }
    }

    Popup {
        id: deleteConfirm
        modal: true
        closePolicy: Popup.CloseOnEscape
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        width: 320
        height: 130
        Shortcut {
            sequence: "Escape"
            enabled: deleteConfirm.opened
            onActivated: deleteConfirm.close()
        }
        background: Rectangle { color: "#f0f0f0"; border.color: "#999"; radius: 4 }
        Column {
            anchors.centerIn: parent
            spacing: 12
            Label { text: "Tem certeza que deseja excluir esta criticidade?"; wrapMode: Text.WordWrap; width: 280 }
            Row { anchors.right: parent.right; spacing: 8
                Button { text: "Não"; onClicked: deleteConfirm.close() }
                Button { text: "Sim"; onClicked: { critModel.remove(table.currentRow); deleteConfirm.close() } }
            }
        }
    }
}
