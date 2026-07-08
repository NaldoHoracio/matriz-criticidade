import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import CriticidadeApp

Page {
    signal navigateToSetores(int empresaId, string empresaName)

    TableModel {
        id: empresaModel
        tableName: "empresa"
        database: Database
    }

    TableModel {
        id: setorModel
        tableName: "setor"
        database: Database
    }

    function refresh() { empresaModel.refresh() }

    Component.onCompleted: refresh()
    Connections { target: Database; function onDataChanged(table) { if (table === "empresa") refresh() } }

    ColumnLayout {
        anchors.fill: parent
        spacing: 4

        RowLayout {
            Layout.fillWidth: true
            Layout.margins: 8
            Label { text: "Empresas Cadastradas"; font.pixelSize: 16; font.bold: true; Layout.fillWidth: true }
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
                tableModel: empresaModel
                columns: [
                    { label: "Nome", width: 500, field: "nome" },
                    { label: "CNPJ", width: 300, field: "cnpj" },
                    { label: "", width: 150, action: { text: "Adicionar Setor", name: "addSetor" } }
                ]
                onRowSelected: function(row) {
                    var d = empresaModel.get(row)
                    navigateToSetores(d.id_empresa, d.nome || "")
                }
                onActionClicked: function(row, action) {
                    var d = empresaModel.get(row)
                    addSetorDialog.empresaId = d.id_empresa
                    addSetorDialog.empresaName = d.nome || ""
                    setorNomeField.text = ""
                    addSetorDialog.open()
                }
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
        height: 220
        property int editRow: -1
        property bool editMode: editRow >= 0

        function openNew() { editRow = -1; nameField.text = ""; cnpjField.text = ""; open() }
        function fmtCnpj(raw) {
            if (!raw) return ""
            var digits = raw.replace(/[^\d]/g, "")
            if (digits.length !== 14) return raw
            return digits.substr(0,2) + "." + digits.substr(2,3) + "." + digits.substr(5,3) + "/" + digits.substr(8,4) + "-" + digits.substr(12,2)
        }
        function openEdit(row) { editRow = row; var d = empresaModel.get(row); nameField.text = d.nome || ""; cnpjField.text = fmtCnpj(d.cnpj || ""); open() }

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
            TextField { id: nameField; placeholderText: "Nome da empresa"; width: parent.width }
            Label { text: "CNPJ:"; font.bold: true }
            TextField {
                id: cnpjField
                placeholderText: "00.000.000/0000-00"
                width: parent.width
                onTextChanged: {
                    var digits = text.replace(/[^\d]/g, "").substr(0, 14)
                    var formatted = ""
                    if (digits.length > 0) formatted = digits.substr(0,2)
                    if (digits.length > 2) formatted += "." + digits.substr(2,3)
                    if (digits.length > 5) formatted += "." + digits.substr(5,3)
                    if (digits.length > 8) formatted += "/" + digits.substr(8,4)
                    if (digits.length > 12) formatted += "-" + digits.substr(12,2)
                    if (text !== formatted) text = formatted
                }
            }
            Item { height: 10 }
            Row {
                anchors.right: parent.right
                spacing: 8
                Button { text: "Cancelar"; onClicked: dialog.close() }
                Button { id: saveBtn; text: "Salvar"; highlighted: true; Material.accent: "#2e7d32"; onClicked: {
                    var data = { nome: nameField.text, cnpj: cnpjField.text }
                    if (dialog.editMode) empresaModel.update(dialog.editRow, data)
                    else empresaModel.create(data)
                    empresaModel.refresh()
                    dialog.close()
                } }
                Shortcut { sequence: "Return"; enabled: dialog.opened; onActivated: saveBtn.clicked() }
            }
        }
    }

    Popup {
        id: addSetorDialog
        modal: true
        closePolicy: Popup.CloseOnEscape
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        width: 400
        height: 200

        property int empresaId: -1
        property string empresaName: ""

        Shortcut {
            sequence: "Escape"
            enabled: addSetorDialog.opened
            onActivated: addSetorDialog.close()
        }
        background: Rectangle { color: "#f0f0f0"; border.color: "#999"; radius: 4 }

        Column {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 10
            Label { text: "Adicionar Setor"; font.pixelSize: 15; font.bold: true }
            Label { text: "Empresa: " + addSetorDialog.empresaName; color: "#555" }
            Label { text: "Nome do Setor:"; font.bold: true }
            TextField { id: setorNomeField; placeholderText: "Nome do setor"; width: parent.width }
            Item { height: 6 }
            Row {
                anchors.right: parent.right
                spacing: 8
                Button { text: "Cancelar"; onClicked: addSetorDialog.close() }
                Button { id: addSetorSaveBtn; text: "Salvar"; highlighted: true; Material.accent: "#2e7d32"; onClicked: {
                    if (setorNomeField.text.trim() === "") return
                    var data = { nome: setorNomeField.text, id_empresa: addSetorDialog.empresaId }
                    setorModel.create(data)
                    addSetorDialog.close()
                } }
                Shortcut { sequence: "Return"; enabled: addSetorDialog.opened; onActivated: addSetorSaveBtn.clicked() }
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
            Label { text: "Tem certeza que deseja excluir esta empresa?"; wrapMode: Text.WordWrap; width: 280 }
            Row { anchors.right: parent.right; spacing: 8
                Button { text: "Não"; onClicked: deleteConfirm.close() }
                Button { text: "Sim"; onClicked: { empresaModel.remove(table.currentRow); deleteConfirm.close() } }
            }
        }
    }
}
