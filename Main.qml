import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MatrizCriticidade

ApplicationWindow {
    visible: true
    width: 1280
    height: 720
    title: "Matriz de Criticidade"

    property string equipamentoSelecionado: "Equipamento 1"

    ColumnLayout {
        anchors.fill: parent
        spacing: 10
        //padding: 10
        Label {
            text: AppController.instituicao
            font.pixelSize: 28
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            // ESQUERDA
            ColumnLayout {
                RowLayout{
                    ColumnLayout{
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Button{
                            id:cadastrarInstituicao
                            text:qsTr("Cadastar nova instituição")
                        }
                        Button{
                            id:cadastrarSetor
                            text:qsTr("Cadastar novo setor")
                        }
                        Button{
                            id:cadastrarEquipamento
                            text:qsTr("Cadastar novo equipamento")
                        }
                        Button{
                            id:atualizarInstituicao
                            text:qsTr("Atualizar instituição selecionada")
                        }
                        Button{
                            id:atualizarSetor
                            text:qsTr("Atualizar setor selecionado")
                        }
                        Button{
                            id:atualizarEquipamento
                            text:qsTr("Atualizar equipamento selecionado")
                        }
                        ComboBox {
                            model: ["Instituição 1", "Instituição 2"]
                        }
                        ComboBox {
                            model: ["Equipamento 1", "Equipamento 2"]
                            onCurrentTextChanged: equipamentoSelecionado = currentText
                        }

                        ComboBox {
                            model: ["SETOR 1", "SETOR 2", "SETOR 3"]
                        }

                        RowLayout {
                            ComboBox { model: ["1","2","3"] }
                            ComboBox { model: ["1","2","3"] }
                        }
                        TextArea {
                            Layout.preferredWidth: 200
                            Layout.fillHeight: true
                            placeholderText: "Breve descrição..."
                        }
                    }
                    ColumnLayout{
                        Layout.fillHeight: true
                        Button{
                            id:apagarInstituicao
                            text:qsTr("Apagar instituição selecionada")
                        }
                        Button{
                            id:apagarSetor
                            text:qsTr("Apagar setor selecionado")
                        }
                        Button{
                            id:apagarEquipamento
                            text:qsTr("Apagar equipamento selecionado")
                        }
                        Text{
                            text:"Função equipamento"
                        }
                        ComboBox {
                            model: ["Sistema de suporte à vida","Terapia","Diagnóstico","Análise","Apoio"]
                            Layout.preferredWidth: 220
                        }
                        Text{
                            text:"Função equipamento"
                        }
                        ComboBox {
                            model: ["Morte","Lesão Grave","Lesão leve/moderada","Terapia ou diagnośtico falho","Sem Risco"]
                            Layout.preferredWidth: 220
                        }
                        Text{
                            text:"Risco fornecido pelo equipamento"
                        }
                        ComboBox {
                            model: ["Sistema de suporte à vida","Terapia","Diagnóstico","Análise","Apoio"]
                            Layout.preferredWidth: 220
                        }
                        Text{
                            text:"Função equipamento"
                        }
                        ComboBox {
                            model: ["Morte","Lesão Grave","Lesão leve/moderada","Terapia ou diagnośtico falho","Sem Risco"]
                            Layout.preferredWidth: 220
                        }
                        Text{
                            text:"Risco potencial de um acidente quando ocorre uma falha"
                        }
                        ComboBox {
                            model: ["Risco Alto","Risco Médio ou baixo","Risco descartado"]
                            Layout.preferredWidth: 220
                        }
                        Text{
                            text:"Risco de perdas, reclamações, retrabalhos"
                        }
                        ComboBox {
                            model: ["Risco Alto para perdas ou retrabalhos","Risco Médio para perdas ou retrabalhos","Risco baixo ou descartado"]
                            Layout.preferredWidth: 300
                        }
                        Text{
                            text:"Tempo de operação do equipamento"
                        }
                        ComboBox {
                            model: ["24 horas/dia","8 a 24 horas/dia","menos que 8 horas/dia"]
                            Layout.preferredWidth: 300
                        }
                        Text{
                            text:"Impacto no processo durante a falha do equipamento"
                        }
                        ComboBox {
                            model: ["Interrompe todo processo de produção","Não intenrrompe processo, mas gera perdas","Não há impacto significativo"]
                            Layout.preferredWidth: 300
                        }
                        Text{
                            text:"Frequência de falha do equipamento"
                        }
                        ComboBox {
                            model: ["Maior que 1 falha/2 meses","1 falha/2 e 6 meses","Menor que 1 falha/6 meses"]
                            Layout.preferredWidth: 300
                        }
                        Text{
                            text:"Tempo médio de reparo"
                        }
                        ComboBox {
                            model: ["Maior que 2h","entre 0,5h e 2h","menor que 0,5h"]
                            Layout.preferredWidth: 300
                        }
                        Item {
                            Layout.fillWidth: true
                        }
                    }
                }


            }
            // DIREITA (MATRIZ)
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true

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
        }

        Label {
            text: AppController.instituicao + " - 2026"
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
            color: "black"
        }

    }
}