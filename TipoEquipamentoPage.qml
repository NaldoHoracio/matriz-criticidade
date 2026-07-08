import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import CriticidadeApp

Page {
    TableModel {
        id: tipoModel
        tableName: "tipo_equipamento"
        database: Database
        orderBy: "valor"
    }

    function refresh() { tipoModel.refresh() }

    Component.onCompleted: refresh()
    Connections { target: Database; function onDataChanged(table) { if (table === "tipo_equipamento") refresh() } }

    ColumnLayout {
        anchors.fill: parent
        spacing: 4

        RowLayout {
            Layout.fillWidth: true
            Layout.margins: 8
            Label { text: "Tipos de Equipamento"; font.pixelSize: 16; font.bold: true; Layout.fillWidth: true }
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
                tableModel: tipoModel
                columns: [
                    { label: "Nome", width: 400, field: "nome" },
                    { label: "Descrição", width: 650, field: "descricao" }
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
        width: 400
        height: 280
        property int editRow: -1
        property bool editMode: editRow >= 0

        function openNew() { editRow = -1; nameField.text = ""; descField.text = ""; open() }
        function openEdit(row) {
            editRow = row
            var d = tipoModel.get(row)
            nameField.text = d.nome || ""
            descField.text = d.descricao || ""
            open()
        }

        Shortcut {
            sequence: "Escape"
            enabled: dialog.opened
            onActivated: dialog.close()
        }
        background: Rectangle { color: "#f0f0f0"; border.color: "#999"; radius: 4 }

        Column {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 10
            Label { text: "Nome:"; font.bold: true }
            TextField { id: nameField; placeholderText: "Nome do tipo"; width: parent.width }
            Label { text: "Descrição:"; font.bold: true }
            TextArea { id: descField; placeholderText: "Descrição"; width: parent.width; height: 80 }
            Item { height: 10 }
            Row {
                anchors.right: parent.right
                spacing: 8
                Button { text: "Cancelar"; onClicked: dialog.close() }
                Button { id: saveBtn; text: "Salvar"; highlighted: true; Material.accent: "#2e7d32"; onClicked: {
                    var data = { nome: nameField.text, descricao: descField.text }
                    if (dialog.editMode) tipoModel.update(dialog.editRow, data)
                    else tipoModel.create(data)
                    tipoModel.refresh()
                    dialog.close()
                } }
                Shortcut { sequence: "Return"; enabled: dialog.opened; onActivated: saveBtn.clicked() }
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
            Label { text: "Tem certeza que deseja excluir este tipo de equipamento?"; wrapMode: Text.WordWrap; width: 280 }
            Row { anchors.right: parent.right; spacing: 8
                Button { text: "Não"; onClicked: deleteConfirm.close() }
                Button { text: "Sim"; onClicked: { tipoModel.remove(table.currentRow); deleteConfirm.close() } }
            }
        }
    }
}
