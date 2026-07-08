import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import CriticidadeApp

Page {
    id: page
    property int equipamentoId: -1
    property string equipamentoNome: ""

    property int criticityValue: 0
    property int funcao: 0
    property int risco: 0
    property int classificacaoAbc: 0
    property int impacto: 0
    property int probabilidade: 0
    property string riscoAbcStr: ""
    property string perdaAbcStr: ""
    property string tempoStr: ""
    property string interrupcaoStr: ""
    property string mttfStr: ""
    property string mttrStr: ""
    property string equipamentoSelecionado: ""

    function abcToInt(val) {
        if (val === "A") return 15
        if (val === "B") return 5
        if (val === "C") return 1
        return 0
    }

    function salvarNoBanco() {
        if (page.equipamentoId < 0) { console.log("ERRO: equipamentoId < 0"); return }
        console.log("Salvando criticidade para equipamento ID:", page.equipamentoId, "Nome:", page.equipamentoNome)
        var result = Database.saveCriticidade(
            page.equipamentoId,
            page.funcao,
            page.risco,
            abcToInt(page.riscoAbcStr),
            abcToInt(page.perdaAbcStr),
            abcToInt(page.tempoStr),
            abcToInt(page.interrupcaoStr),
            abcToInt(page.mttfStr),
            abcToInt(page.mttrStr),
            page.criticityValue
        )
        console.log("  saveCriticidade resultado:", result)
    }

    function intToAbc(val) {
        if (val === 15) return "A"
        if (val === 5) return "B"
        if (val === 1) return "C"
        return ""
    }

    Component {
        id: criticalityFormView
        Page {
            property var existingData: null
            property int funcaoInicial: -1

            Component.onCompleted: {
                if (existingData) {
                    Qt.callLater(function() { form.loadData(existingData, page.intToAbc) })
                } else if (funcaoInicial > 0) {
                    Qt.callLater(function() { form.setInitialFuncao(funcaoInicial) })
                }
            }

            ScrollView {
                anchors.fill: parent
                clip: true
                contentWidth: parent.width
                contentHeight: column.height

                Column {
                    id: column
                    width: parent.width
                    spacing: 8
                    topPadding: 8
                    bottomPadding: 8

                    Label {
                        text: "Cálculo de Criticidade \u2014 " + page.equipamentoNome
                        font.pixelSize: 16; font.bold: true
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Item {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: Math.min(parent.width - 16, 500)
                        height: form.implicitHeight

                        CriticalityForm {
                            id: form
                            anchors.centerIn: parent
                            width: parent.width
                        }
                    }

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 12
                        topPadding: 8
                        Button {
                            text: "Calcular Criticidade"
                            highlighted: true
                            Material.accent: "#2e7d32"
                            onClicked: {
                                page.criticityValue = form.calculateCriticity()
                                page.funcao = form.getFuncao()
                                page.risco = form.getRisco()
                                page.classificacaoAbc = form.getClassificacao()
                                page.impacto = page.funcao + page.risco
                                page.probabilidade = page.classificacaoAbc + page.funcao
                                page.riscoAbcStr = form.riscoAbc || ""
                                page.perdaAbcStr = form.perdaAbc || ""
                                page.tempoStr = form.tempo || ""
                                page.interrupcaoStr = form.interrupcao || ""
                                page.mttfStr = form.mttf || ""
                                page.mttrStr = form.mttr || ""
                                page.equipamentoSelecionado = page.equipamentoNome

                                page.salvarNoBanco()

                                criticityValue = page.criticityValue
                                impacto = page.impacto
                                probabilidade = page.probabilidade
                                equipamentoSelecionado = page.equipamentoNome

                                screenStack.push(criticalityMatrixView)
                            }
                        }
                        Button {
                            text: "Voltar"
                            onClicked: page.voltar()
                        }
                    }
                }
            }
        }
    }

    Component {
        id: criticalityMatrixView
        Page {
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 8

                Label {
                    text: "Resultado \u2014 " + page.equipamentoNome
                    font.pixelSize: 16; font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    CriticalityMatrixComponents {
                        anchors.centerIn: parent
                        width: parent.width
                        height: parent.height
                    }
                }

                RowLayout {
                    Layout.alignment: Qt.AlignRight
                    spacing: 8
                    Button {
                        text: "Voltar ao formulário"
                        onClicked: screenStack.pop()
                    }
                    Button {
                        text: "Voltar para equipamentos"
                        onClicked: page.voltar()
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        console.log("Pagina criada para equipamento ID:", page.equipamentoId, "nome:", page.equipamentoNome)
        var allData = Database.fetchAll("criticidade")
        console.log("TODOS registros criticidade:", JSON.stringify(allData))
        var d = Database.fetchCriticidadeByEquipamento(page.equipamentoId)
        console.log("fetchCriticidadeByEquipamento:", JSON.stringify(d))
        if (d && d.id_criticidade !== undefined) {
            page.funcao = d.Funcao || 0
            page.risco = d.Risco || 0
            page.criticityValue = d.criticidade_final || 0
            page.impacto = page.funcao + page.risco
            page.probabilidade = page.impacto > 0 ? Math.round(page.criticityValue / page.impacto) : 0
            page.equipamentoSelecionado = page.equipamentoNome
            criticityValue = page.criticityValue
            impacto = page.impacto
            probabilidade = page.probabilidade
            equipamentoSelecionado = page.equipamentoNome
            screenStack.push(criticalityFormView, { existingData: d })
            screenStack.push(criticalityMatrixView)
        } else {
            var equip = Database.fetchById("equipamento", page.equipamentoId)
            var funcaoVal = 1
            if (equip && equip.id_tipo_equipamento > 0) {
                var tipo = Database.fetchById("tipo_equipamento", equip.id_tipo_equipamento)
                if (tipo && tipo.valor > 0) funcaoVal = tipo.valor
            }
            screenStack.push(criticalityFormView, { funcaoInicial: funcaoVal })
        }
    }

    StackView {
        id: screenStack
        anchors.fill: parent
        initialItem: null
    }

    function voltar() {
        window.currentPage = "equipamento"
    }
}
