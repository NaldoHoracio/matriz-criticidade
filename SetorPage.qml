import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import CriticidadeApp

Page {
    signal navigateToEquipamentos(int setorId, string setorNome)
    property int filterEmpresaId: -1
    property string filterEmpresaName: ""

    property var empresas: []
    property var tipos: []
    property var modelList: []
    property var fabricanteList: []
    property bool settingFilter: false

    TableModel {
        id: setorModel
        tableName: "setor"
        database: Database
    }

    function refresh() {
        if (filterEmpresaId >= 0)
            setorModel.setFilter("id_empresa", filterEmpresaId)
        else
            setorModel.refresh()
        Database.foreignOptions("tipo_equipamento", "nome", function(opts) { tipos = opts })
        Database.distinctValues("equipamento", "modelo", function(vals) { modelList = vals })
        Database.distinctValues("equipamento", "fabricante", function(vals) { fabricanteList = vals })
        Database.foreignOptions("empresa", "nome", function(opts) {
            empresas = opts
            syncEmpresaFiltro()
        })
    }

    function syncEmpresaFiltro() {
        settingFilter = true
        if (filterEmpresaId < 0 && empresas.length > 0) {
            window.filterEmpresaId = empresas[0].id
            window.filterEmpresaName = empresas[0].display
        }
        if (filterEmpresaId >= 0)
            setorModel.setFilter("id_empresa", filterEmpresaId)
        for (var i = 0; i < empresas.length; i++) {
            if (empresas[i].id === filterEmpresaId) { empresaFiltro.currentIndex = i; break }
        }
        settingFilter = false
    }

    onFilterEmpresaIdChanged: {
        if (settingFilter) return
        refresh()
    }

    Component.onCompleted: refresh()
    Connections { target: Database; function onDataChanged(table) { if (table === "setor" || table === "empresa" || table === "equipamento" || table === "tipo_equipamento") refresh() } }

    ColumnLayout {
        anchors.fill: parent
        spacing: 4

        RowLayout {
            Layout.fillWidth: true
            Layout.margins: 8
            Label {
                text: "Setores \u2014 " + filterEmpresaName
                font.pixelSize: 16; font.bold: true
            }
            ComboBox {
                id: empresaFiltro
                textRole: "display"
                valueRole: "id"
                model: empresas
                Layout.minimumWidth: 200
                onActivated: function(index) {
                    if (settingFilter) return
                    settingFilter = true
                    window.filterEmpresaId = empresas[index].id
                    window.filterEmpresaName = empresas[index].display
                    refresh()
                    settingFilter = false
                }
            }
            Item { Layout.fillWidth: true }
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
                tableModel: setorModel
                columns: [
                    { label: "Nome", width: 500, field: "nome" },
                    { label: "Empresa", width: 250, field: "id_empresa", resolve: empresas },
                    { label: "", width: 150, action: { text: "Adicionar Equipamento", name: "addEquip" } }
                ]
                onRowSelected: function(row) {
                    var d = setorModel.get(row)
                    navigateToEquipamentos(d.id_setor, d.nome || "")
                }
                onActionClicked: function(row, action) {
                    if (action === "addEquip") equipDialog.openForSetor(row)
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
        height: 240
        property int editRow: -1
        property bool editMode: editRow >= 0

        function openNew() {
            editRow = -1; nameField.text = ""
            if (filterEmpresaId >= 0) {
                empresaCombo.currentIndex = -1
            } else {
                empresaCombo.currentIndex = -1
            }
            open()
        }
        function openEdit(row) {
            editRow = row
            var d = setorModel.get(row)
            nameField.text = d.nome || ""
            for (var i = 0; i < empresaCombo.model.length; i++) {
                if (empresaCombo.model[i].id === d.id_empresa) { empresaCombo.currentIndex = i; break }
            }
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
            TextField { id: nameField; placeholderText: "Nome do setor"; width: parent.width }
            Label { text: "Empresa:"; font.bold: true }
            ComboBox { id: empresaCombo; textRole: "display"; valueRole: "id"; model: empresas; width: parent.width; visible: filterEmpresaId < 0; popup.width: Math.max(width, 400) }
            Label { text: filterEmpresaName; font.pixelSize: 15; font.bold: true; color: "#212121"; visible: filterEmpresaId >= 0 }
            Item { height: 10 }
            Row {
                anchors.right: parent.right
                spacing: 8
                Button { text: "Cancelar"; onClicked: dialog.close() }
                Button { id: saveBtn; text: "Salvar"; highlighted: true; Material.accent: "#2e7d32"; onClicked: {
                    var empresaId = filterEmpresaId >= 0 ? filterEmpresaId : (empresaCombo.currentIndex >= 0 ? empresas[empresaCombo.currentIndex].id : -1)
                    if (empresaId < 0) return
                    var data = { nome: nameField.text, id_empresa: empresaId }
                    if (dialog.editMode) setorModel.update(dialog.editRow, data)
                    else setorModel.create(data)
                    setorModel.refresh()
                    dialog.close()
                } }
                Shortcut { sequence: "Return"; enabled: dialog.opened; onActivated: saveBtn.clicked() }
            }
        }
    }

    Popup {
        id: equipDialog
        modal: true
        closePolicy: Popup.CloseOnEscape
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        width: 520
        height: 400
        property int setorRow: -1
        property int setorId: -1
        property string dateValue: ""
        property string lastModel: ""
        property string lastFabricante: ""
        property int lastTipoEquipamentoId: -1

        function fmtDisplay(raw) {
            if (!raw) return ""
            var p = raw.split("-")
            return p.length === 3 ? p[2] + "-" + p[1] + "-" + p[0] : raw
        }

        function todayISO() {
            var d = new Date()
            return d.getFullYear() + "-" + ("00" + (d.getMonth() + 1)).slice(-2) + "-" + ("00" + d.getDate()).slice(-2)
        }

        function validateFields() {
            var missing = []
            if (!patField.text.trim()) missing.push("Patrimônio")
            if (!modelField.editText.trim()) missing.push("Modelo")
            if (!fabField.editText.trim()) missing.push("Fabricante")
            if (!equipDialog.dateValue) missing.push("Data de Aquisição")
            if (tipoCombo.currentIndex < 0) missing.push("Tipo de Equipamento")
            return missing
        }

        function openForSetor(row) {
            setorRow = row
            var d = setorModel.get(row)
            setorId = d.id_setor
            dateValue = equipDialog.todayISO()
            patField.text = ""
            modelField.currentIndex = -1
            modelField.editText = equipDialog.lastModel
            fabField.currentIndex = -1
            fabField.editText = equipDialog.lastFabricante
            dateField.text = equipDialog.fmtDisplay(dateValue); tipoCombo.currentIndex = -1
            if (equipDialog.lastTipoEquipamentoId >= 0) {
                for (var j = 0; j < tipos.length; j++) {
                    if (tipos[j].id === equipDialog.lastTipoEquipamentoId) { tipoCombo.currentIndex = j; break }
                }
            }
            patField.forceActiveFocus()
            equipDialogScroll.contentItem.contentY = 0
            open()
        }

        Shortcut {
            sequence: "Escape"
            enabled: equipDialog.opened
            onActivated: equipDialog.close()
        }
        background: Rectangle { color: "#f0f0f0"; border.color: "#999"; radius: 4 }

        ScrollView {
            id: equipDialogScroll
            anchors.fill: parent
            anchors.margins: 12
            clip: true
            Column {
                width: parent.width
                spacing: 10
                Label { text: "Adicionar Equipamento ao Setor"; font.bold: true; font.pixelSize: 14 }
                Label { text: "Patrimônio:"; font.bold: true }
                TextField { id: patField; placeholderText: "N\u00ba patrimônio"; width: parent.width }
                Label { text: "Modelo:"; font.bold: true }
                ComboBox {
                    id: modelField
                    editable: true
                    model: modelList
                    width: parent.width
                    onActivated: function(index) {
                        var modelName = modelField.editText
                        if (!modelName) return
                        Database.fetchWhere("equipamento", "modelo", modelName, function(existing) {
                            if (existing.length > 0) {
                                var e = existing[0]
                                fabField.editText = e.fabricante || ""
                                for (var j = 0; j < tipoCombo.model.length; j++) {
                                    if (tipoCombo.model[j].id === e.id_tipo_equipamento) { tipoCombo.currentIndex = j; break }
                                }
                            }
                        })
                    }
                }
                Button { text: "Limpar"; flat: true; font.pixelSize: 11; anchors.right: parent.right; onClicked: { modelField.editText = ""; modelField.currentIndex = -1 } }
                Label { text: "Fabricante:"; font.bold: true }
                ComboBox { id: fabField; editable: true; model: fabricanteList; width: parent.width }
                Button { text: "Limpar"; flat: true; font.pixelSize: 11; anchors.right: parent.right; onClicked: { fabField.editText = ""; fabField.currentIndex = -1 } }
                Label { text: "Data de Aquisição:"; font.bold: true }
                TextField { id: dateField; placeholderText: "DD-MM-AAAA"; readOnly: true; width: parent.width; MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: datePicker.open() } }
                Label { text: "Tipo de Equipamento:"; font.bold: true }
                ComboBox { id: tipoCombo; textRole: "display"; valueRole: "id"; model: tipos; width: parent.width; popup.width: Math.max(width, 350) }
                Item { height: 10 }
                Row {
                    anchors.right: parent.right
                    spacing: 8
                    Button { text: "Cancelar"; onClicked: equipDialog.close() }
                    Button { id: equipSaveBtn; text: "Salvar"; highlighted: true; Material.accent: "#2e7d32"; onClicked: {
                        var missing = equipDialog.validateFields()
                        if (missing.length > 0) {
                            validationWarning.missingFields = missing
                            validationWarning.open()
                            return
                        }
                        equipDialog.lastModel = modelField.editText
                        equipDialog.lastFabricante = fabField.editText
                        equipDialog.lastTipoEquipamentoId = tipos[tipoCombo.currentIndex].id
                        var data = {
                            patrimonio: patField.text, modelo: modelField.editText, fabricante: fabField.editText,
                            data_aquisicao: equipDialog.dateValue,
                            id_setor: equipDialog.setorId,
                            id_tipo_equipamento: tipos[tipoCombo.currentIndex].id
                        }
                        Database.createRecord("equipamento", data)
                        equipDialog.close()
                    } }
                    Shortcut { sequence: "Return"; enabled: equipDialog.opened; onActivated: equipSaveBtn.clicked() }
                }
            }
        }
    }

    DatePicker {
        id: datePicker
        dateText: equipDialog.dateValue
        onDatePicked: function(d) {
            equipDialog.dateValue = d
            dateField.text = equipDialog.fmtDisplay(d)
        }
    }

    Popup {
        id: validationWarning
        modal: true
        closePolicy: Popup.CloseOnEscape
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        width: 380
        height: 200
        property var missingFields: []
        Shortcut {
            sequence: "Escape"
            enabled: validationWarning.opened
            onActivated: validationWarning.close()
        }
        background: Rectangle { color: "#f0f0f0"; border.color: "#c62828"; radius: 4 }
        Column {
            anchors.centerIn: parent
            spacing: 16
            Label { text: "Preencha os campos obrigatórios:"; font.bold: true; font.pixelSize: 14 }
            Label {
                text: validationWarning.missingFields.join(", ")
                wrapMode: Text.WordWrap
                width: 340
                color: "#c62828"
                font.pixelSize: 13
            }
            Button { text: "OK"; anchors.right: parent.right; Material.accent: "#c62828"; highlighted: true; onClicked: validationWarning.close() }
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
            Label { text: "Tem certeza que deseja excluir este setor?"; wrapMode: Text.WordWrap; width: 280 }
            Row { anchors.right: parent.right; spacing: 8
                Button { text: "Não"; onClicked: deleteConfirm.close() }
                Button { text: "Sim"; onClicked: { setorModel.remove(table.currentRow); deleteConfirm.close() } }
            }
        }
    }
}
