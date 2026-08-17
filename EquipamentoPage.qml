import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import CriticidadeApp

Page {
    id: equipamentoPage
    property int filterSetorId: -1
    property string filterSetorName: ""
    property int filterEmpresaId: -1
    property var setores: []
    property var tipos: []
    property var modelList: []
    property var fabricanteList: []
    property var criticidadeLookup: []
    property var criticidadeMap: ({})
    property bool settingFilter: false

    signal navigateToCriticidade(int equipamentoId, string equipamentoNome)

    TableModel {
        id: equipModel
        tableName: "equipamento"
        database: Database
    }

    function applyFilter() {
        if (filterSetorId >= 0)
            equipModel.setFilter("id_setor", filterSetorId)
        else
            equipModel.refresh()
    }

    function refresh() {
        if (filterEmpresaId >= 0) {
            Database.fetchWhere("setor", "id_empresa", filterEmpresaId, function(rows) {
                var opts = []
                for (var i = 0; i < rows.length; i++) opts.push({ id: rows[i].id_setor, display: rows[i].nome })
                setores = opts
            })
        } else {
            Database.foreignOptions("setor", "nome", function(opts) { setores = opts })
        }
        Database.foreignOptions("tipo_equipamento", "nome", function(opts) { tipos = opts })
        Database.distinctValues("equipamento", "modelo", function(vals) { modelList = vals })
        Database.distinctValues("equipamento", "fabricante", function(vals) { fabricanteList = vals })
        Database.fetchAll("criticidade", function(critRows) {
            criticidadeLookup = []
            criticidadeMap = ({})
            console.log("DEBUG criticRows:", JSON.stringify(critRows))
            for (var ci = 0; ci < critRows.length; ci++) {
                var equipId = critRows[ci]["id_equipamento"]
                var critVal = critRows[ci]["criticidade_final"]
                console.log("DEBUG critRow:", equipId, "->", critVal)
                criticidadeLookup.push({ id: equipId, display: String(critVal) })
                criticidadeMap[equipId] = String(critVal)
            }
            console.log("DEBUG criticidadeLookup:", JSON.stringify(criticidadeLookup))
            console.log("DEBUG criticidadeMap:", JSON.stringify(criticidadeMap))
        })
        applyFilter()
        syncTimer.restart()
    }

    onFilterEmpresaIdChanged: refresh()

    Timer {
        id: syncTimer
        interval: 1
        onTriggered: {
            settingFilter = true
            for (var i = 0; i < setorFiltro.model.length; i++) {
                if (setorFiltro.model[i].id === filterSetorId) { setorFiltro.currentIndex = i; break }
            }
            settingFilter = false
        }
    }

    onFilterSetorIdChanged: {
        if (settingFilter) return
        settingFilter = true
        applyFilter()
        for (var i = 0; i < setorFiltro.model.length; i++) {
            if (setorFiltro.model[i].id === filterSetorId) { setorFiltro.currentIndex = i; break }
        }
        settingFilter = false
    }

    Component.onCompleted: refresh()
    Connections { target: Database; function onDataChanged(table) { if (table === "equipamento" || table === "setor" || table === "tipo_equipamento" || table === "criticidade") refresh() } }

    ColumnLayout {
        anchors.fill: parent
        spacing: 4

        RowLayout {
            Layout.fillWidth: true
            Layout.margins: 8
            Label {
                text: filterSetorId >= 0 ? "Equipamentos \u2014 " + filterSetorName : "Equipamentos Cadastrados"
                font.pixelSize: 16; font.bold: true
            }
            ComboBox {
                id: setorFiltro
                textRole: "display"
                valueRole: "id"
                model: setores.length > 0 ? [{ id: -1, display: "Todos os Setores" }].concat(setores) : []
                Layout.minimumWidth: 200
                onActivated: function(index) {
                    if (settingFilter) return
                    settingFilter = true
                    filterSetorId = model[index].id
                    filterSetorName = filterSetorId < 0 ? "" : model[index].display
                    applyFilter()
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
                tableModel: equipModel
                columns: [
                    { label: "Patrimônio", width: 140, field: "patrimonio" },
                    { label: "Modelo", width: 180, field: "modelo" },
                    { label: "Fabricante", width: 180, field: "fabricante" },
                    { label: "Aquisição", width: 120, field: "data_aquisicao" },
                    { label: "Critic.", width: 70, compute: function(v) { return criticidadeMap[v.id_equipamento] || "" } },
                    { label: "Setor", width: 140, field: "id_setor", resolve: setores },
                    { label: "Tipo Equip.", width: 140, field: "id_tipo_equipamento", resolve: tipos }
                ]
                onRowSelected: function(row) {
                    var d = equipModel.get(row)
                    equipamentoPage.navigateToCriticidade(d.id_equipamento, d.modelo || d.patrimonio || "")
                }
            }
        }

        RowLayout {
            Layout.margins: 8
            Layout.alignment: Qt.AlignRight
            spacing: 8
            Button { text: "Editar"; enabled: table.currentRow >= 0; onClicked: dialog.openEdit(table.currentRow) }
            Button { text: "Calcular Criticidade"; enabled: table.currentRow >= 0; onClicked: {
                var d = equipModel.get(table.currentRow)
                equipamentoPage.navigateToCriticidade(d.id_equipamento, d.modelo || d.patrimonio || "")
            } }
            Button { text: "Excluir"; enabled: table.currentRow >= 0; onClicked: deleteConfirm.open() }
        }
    }

    Popup {
        id: dialog
        modal: true
        closePolicy: Popup.CloseOnEscape
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        width: 520
        height: 450
        property int editRow: -1
        property bool editMode: editRow >= 0
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
            if (!dialog.dateValue) missing.push("Data de Aquisição")
            if (filterSetorId < 0 && setorCombo.currentIndex < 0) missing.push("Setor")
            if (tipoCombo.currentIndex < 0) missing.push("Tipo de Equipamento")
            return missing
        }

        function openNew() {
            editRow = -1
            dateValue = dialog.todayISO()
            patField.text = ""
            modelField.currentIndex = -1; modelField.editText = dialog.lastModel
            fabField.currentIndex = -1; fabField.editText = dialog.lastFabricante
            dateField.text = dialog.fmtDisplay(dateValue); tipoCombo.currentIndex = -1
            if (filterSetorId < 0) setorCombo.currentIndex = -1
            if (dialog.lastTipoEquipamentoId >= 0) {
                for (var j = 0; j < tipos.length; j++) {
                    if (tipos[j].id === dialog.lastTipoEquipamentoId) { tipoCombo.currentIndex = j; break }
                }
            }
            patField.forceActiveFocus()
            dialogScroll.contentItem.contentY = 0
            open()
        }
        function openEdit(row) {
            editRow = row
            var d = equipModel.get(row)
            patField.text = d.patrimonio || ""
            modelField.editText = d.modelo || ""
            fabField.editText = d.fabricante || ""
            dateValue = d.data_aquisicao || ""
            dateField.text = fmtDisplay(dateValue)
            if (filterSetorId < 0) {
                for (var i = 0; i < setorCombo.model.length; i++) {
                    if (setorCombo.model[i].id === d.id_setor) { setorCombo.currentIndex = i; break }
                }
            }
            for (var j = 0; j < tipoCombo.model.length; j++) {
                if (tipoCombo.model[j].id === d.id_tipo_equipamento) { tipoCombo.currentIndex = j; break }
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
            id: dialogScroll
            anchors.fill: parent
            anchors.margins: 12
            clip: true
            Column {
                width: parent.width
                spacing: 10
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
                                if (filterSetorId < 0 && e.id_setor) {
                                    for (var i = 0; i < setorCombo.model.length; i++) {
                                        if (setorCombo.model[i].id === e.id_setor) { setorCombo.currentIndex = i; break }
                                    }
                                }
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
                Label { text: "Setor:"; font.bold: true }
                ComboBox { id: setorCombo; textRole: "display"; valueRole: "id"; model: setores; width: parent.width; visible: filterSetorId < 0 }
                Label { text: filterSetorName; font.pixelSize: 15; font.bold: true; color: "#212121"; visible: filterSetorId >= 0 }
                Label { text: "Tipo de Equipamento:"; font.bold: true }
                ComboBox { id: tipoCombo; textRole: "display"; valueRole: "id"; model: tipos; width: parent.width; popup.width: Math.max(width, 350) }
                Item { height: 10 }
                Row {
                    anchors.right: parent.right
                    spacing: 8
                    Button { text: "Cancelar"; onClicked: dialog.close() }
                    Button { id: saveBtn; text: "Salvar"; highlighted: true; Material.accent: "#2e7d32"; onClicked: {
                        var missing = dialog.validateFields()
                        if (missing.length > 0) {
                            validationWarning.missingFields = missing
                            validationWarning.open()
                            return
                        }
                        var setorId = filterSetorId >= 0 ? filterSetorId : setores[setorCombo.currentIndex].id
                        dialog.lastModel = modelField.editText
                        dialog.lastFabricante = fabField.editText
                        dialog.lastTipoEquipamentoId = tipos[tipoCombo.currentIndex].id
                        var data = {
                            patrimonio: patField.text, modelo: modelField.editText, fabricante: fabField.editText,
                            data_aquisicao: dialog.dateValue,
                            id_setor: setorId,
                            id_tipo_equipamento: tipos[tipoCombo.currentIndex].id
                        }
                        if (dialog.editMode) equipModel.update(dialog.editRow, data)
                        else equipModel.create(data)
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
        width: 360
        height: 140
        Shortcut {
            sequence: "Escape"
            enabled: deleteConfirm.opened
            onActivated: deleteConfirm.close()
        }
        background: Rectangle { color: "#f0f0f0"; border.color: "#999"; radius: 4 }
        Column {
            anchors.centerIn: parent
            spacing: 12
            Label { text: "Tem certeza que deseja excluir este equipamento?\nIsso também removerá criticidade e histórico associados."; wrapMode: Text.WordWrap; width: 320 }
            Row { anchors.right: parent.right; spacing: 8
                Button { text: "Não"; onClicked: deleteConfirm.close() }
                Button { text: "Sim"; onClicked: { equipModel.remove(table.currentRow); deleteConfirm.close() } }
            }
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

    DatePicker {
        id: datePicker
        dateText: dialog.dateValue
        onDatePicked: function(d) {
            dialog.dateValue = d
            dateField.text = dialog.fmtDisplay(d)
        }
    }
}
