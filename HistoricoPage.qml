import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import CriticidadeApp

Page {
    property var equipamentos: []

    TableModel {
        id: histModel
        tableName: "historico_manutencao"
        database: Database
    }

    function refresh() {
        histModel.refresh()
        Database.foreignOptions("equipamento", "patrimonio", function(opts) { equipamentos = opts })
    }

    Component.onCompleted: refresh()
    Connections { target: Database; function onDataChanged(table) { if (table === "historico_manutencao" || table === "equipamento") refresh() } }

    ColumnLayout {
        anchors.fill: parent
        spacing: 4

        RowLayout {
            Layout.fillWidth: true
            Layout.margins: 8
            Label { text: "Histórico de Manutenção"; font.pixelSize: 16; font.bold: true; Layout.fillWidth: true }
            Button { text: "Atualizar"; onClicked: refresh() }
            Button { text: "Adicionar"; highlighted: true; Material.accent: "#2e7d32"; onClicked: dialog.openNew() }
        }

        Frame {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 8
            padding: 0

            TableComponent {
                id: table
                anchors.fill: parent
                tableModel: histModel
                columns: [
                    { label: "Data", width: 150, field: "data_manutencao" },
                    { label: "Tipo", width: 150, field: "tipo_manutencao" },
                    { label: "Descrição", width: 280, field: "descricao" },
                    { label: "Custo", width: 120, field: "custo" },
                    { label: "Responsável", width: 200, field: "responsavel" },
                    { label: "Equipamento", width: 120, field: "id_equipamento", resolve: equipamentos }
                ]
            }
        }

        RowLayout {
            Layout.margins: 8
            Layout.alignment: Qt.AlignRight
            spacing: 8
            Button { text: "Editar"; enabled: table.currentRow >= 0; onClicked: dialog.openEdit(table.currentRow) }
            Button { text: "Excluir"; enabled: table.currentRow >= 0; onClicked: deleteConfirm.open() }
        }
    }

    Popup {
        id: dialog
        modal: true
        closePolicy: Popup.CloseOnEscape
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        width: 460
        height: 510
        property int editRow: -1
        property bool editMode: editRow >= 0
        property string dateValue: ""

        function fmtDisplay(raw) {
            if (!raw) return ""
            var p = raw.split("-")
            return p.length === 3 ? p[2] + "-" + p[1] + "-" + p[0] : raw
        }

        function openNew() {
            editRow = -1
            dateValue = ""
            dateField.text = ""; tipoField.text = ""; descField.text = ""
            custoField.text = "0"; respField.text = ""; obsField.text = ""
            equipCombo.currentIndex = -1
            open()
        }
        function openEdit(row) {
            editRow = row
            var d = histModel.get(row)
            dateValue = d.data_manutencao || ""
            dateField.text = fmtDisplay(dateValue)
            tipoField.text = d.tipo_manutencao || ""
            descField.text = d.descricao || ""
            custoField.text = d.custo !== undefined ? String(d.custo) : "0"
            respField.text = d.responsavel || ""
            obsField.text = d.observacoes || ""
            for (var i = 0; i < equipCombo.model.length; i++) {
                if (equipCombo.model[i].id === d.id_equipamento) { equipCombo.currentIndex = i; break }
            }
            open()
        }

        Shortcut {
            sequence: "Escape"
            enabled: dialog.opened
            onActivated: dialog.close()
        }
        background: Rectangle { color: "#f0f0f0"; border.color: "#999"; radius: 4 }

        ScrollView {
            anchors.fill: parent
            anchors.margins: 12
            clip: true
            Column {
                width: parent.width
                spacing: 10
                Label { text: "Equipamento:"; font.bold: true }
                ComboBox { id: equipCombo; textRole: "display"; valueRole: "id"; model: equipamentos; width: parent.width }
                Label { text: "Data:"; font.bold: true }
                TextField { id: dateField; placeholderText: "DD-MM-AAAA"; readOnly: true; width: parent.width; MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: datePicker.open() } }
                Label { text: "Tipo:"; font.bold: true }
                TextField { id: tipoField; placeholderText: "Ex: Corretiva, Preventiva"; width: parent.width }
                Label { text: "Descrição:"; font.bold: true }
                TextArea { id: descField; placeholderText: "Descrição da manutenção"; width: parent.width; height: 60 }
                Label { text: "Custo (R$):"; font.bold: true }
                TextField { id: custoField; placeholderText: "0.00"; width: parent.width; validator: RegularExpressionValidator { regularExpression: /[0-9]+\.?[0-9]*/ } }
                Label { text: "Responsável:"; font.bold: true }
                TextField { id: respField; placeholderText: "Nome do responsável"; width: parent.width }
                Label { text: "Observações:"; font.bold: true }
                TextArea { id: obsField; placeholderText: "Observações"; width: parent.width; height: 60 }
                Item { height: 10 }
                Row {
                    anchors.right: parent.right
                    spacing: 8
                    Button { text: "Cancelar"; onClicked: dialog.close() }
                    Button { id: saveBtn; text: "Salvar"; highlighted: true; Material.accent: "#2e7d32"; onClicked: {
                        if (equipCombo.currentIndex < 0) return
                        var data = {
                            data_manutencao: dialog.dateValue, tipo_manutencao: tipoField.text,
                            descricao: descField.text, custo: parseFloat(custoField.text) || 0,
                            responsavel: respField.text, observacoes: obsField.text,
                            id_equipamento: equipamentos[equipCombo.currentIndex].id
                        }
                        if (dialog.editMode) histModel.update(dialog.editRow, data)
                        else histModel.create(data)
                        histModel.refresh()
                        dialog.close()
                    } }
                    Shortcut { sequence: "Return"; enabled: dialog.opened; onActivated: saveBtn.clicked() }
                }
            }
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
            Label { text: "Tem certeza que deseja excluir este registro de manutenção?"; wrapMode: Text.WordWrap; width: 280 }
            Row { anchors.right: parent.right; spacing: 8
                Button { text: "Não"; onClicked: deleteConfirm.close() }
                Button { text: "Sim"; onClicked: { histModel.remove(table.currentRow); deleteConfirm.close() } }
            }
        }
    }

    DatePicker {
        id: datePicker
        dateText: dialog.dateValue
        onDatePicked: function(d) {
            dialog.dateValue = d
            dateField.text = dialog.fmtDisplay(d)
        }
    }
}
