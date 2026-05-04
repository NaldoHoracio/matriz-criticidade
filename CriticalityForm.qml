import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    id:criticalityForm
    anchors.centerIn: parent
    property alias funcao: funcaoCombobox.currentValue
    property alias risco: riscoCombobox.currentValue
    property alias riscoAbc: riscoAbcCombobox.currentValue
    property alias perdaAbc: perdaCombobox.currentValue
    property alias tempo: tempoFuncionamentoCombobox.currentValue
    property alias interrupcao:  interrupcaoCombobox.currentValue
    property alias mttf: mttfCombobox.currentValue
    property alias mttr: mtbrCombobox.currentValue
    function getFuncao(){
        return funcao;
    }
    function getRisco(){
        return risco;
    }
    function getClassificacao(){
        return classifyAbc();
    }
    function classifyAbc(){
        var value;
        if(riscoAbc.Value ==="A"){
            value=15;
            return value;
        }
        if(riscoAbc.Value === "B" || riscoAbc.Value === "C"){
            if(perdaAbc.Value === "A"){
                value=15;
                return value;
            }
            if(perdaAbc.Value === "B" || perdaAbc.Value === "C"){
                if(tempo.Value === "A" || tempo.Value === "B"){
                    if(interrupcao.Value === "A"){
                        if(mttf.Value === "A"){
                            if(mttr.Value === "A"){
                                value=15;
                                return value;
                            }
                        }
                    }
                    if(interrupcao.Value === "B"){
                        if(mttf.Value ==="A" || mttf.Value ==="B"){
                            if(mttr.Value === "A" || mttr.Value === "B"){
                                value=5;
                                return value;
                            }
                            if(mttr.Value === "C"){
                                value=1;
                                return value;
                            }
                        }
                        if(mttf.Value ==="C"){
                            value=1;
                            return value;
                        }
                    }
                    if(interrupcao.Value === "C"){
                        value=1;
                        return value;
                    }
                }
                if(tempo.Value === "C"){
                    if(interrupcao.Value === "A" || interrupcao.Value === "B"){
                        if(mttf.Value === "A" || mttf.Value === "B"){
                            if(mttr.Value === "A" || mttr.Value === "B"){
                                value=5;
                                return value;
                            }
                            if(mttr.Value === "C"){
                                value=1;
                                return value;
                            }
                        }
                        if(mttf.Value === "C"){
                            value=1;
                            return value;
                        }
                    }
                    if(interrupcao.Value === "C"){
                        value=1;
                        return value;
                    }
                }
            }
        }
    }
    function printComboboxesValues(){
        console.log(funcao.Value);
        console.log(risco.Value);
        console.log(riscoAbc.Value);
        console.log(perdaAbc.Value);
        console.log(tempo.Value);
        console.log(interrupcao.Value);
        console.log(mttf.Value);
        console.log(mttr.Value);
    }
    function calculateCriticity(){
        var AbcClassification=classifyAbc();
        var criticity=(funcao.Value+risco.Value)*(AbcClassification+funcao.Value);
        return criticity;
    }
    Text{
        text:"Função equipamento"
    }
    ComboBox {
        id:funcaoCombobox
        textRole:"Name"
        model:ListModel{
            ListElement{
                Name:"Sistema de suporte à vida"
                Value:5
            }
            ListElement{
                Name:"Terapia"
                Value:4
            }
            ListElement{
                Name:"Diagnóstico"
                Value:3
            }
            ListElement{
                Name:"Análise"
                Value:2
            }
            ListElement{
                Name:"Apoio"
                Value:1
            }
        }
        /*onActivated: {
                console.log("Selected Text:", currentText)
                console.log("Selected Index:", currentValue.Value)
        }*/
        Layout.preferredWidth: 350
        Layout.alignment:  Qt.AlignHCenter
    }
    Text{
        text:"Risco fornecido pelo equipamento"
    }
    ComboBox {
        id:riscoCombobox
        textRole:"Name"
        model:ListModel{
            ListElement{
                Name:"Morte"
                Value:5
            }
            ListElement{
                Name:"Lesão Grave"
                Value:4
            }
            ListElement{
                    Name:"Lesão leve/moderada"
                    Value:3
            }
            ListElement{
                Name:"Terapia ou diagnośtico falho"
                Value:2
            }
            ListElement{
                Name:"Sem Risco"
                Value:0
            }
        }
        Layout.preferredWidth: 350
        Layout.alignment:  Qt.AlignHCenter
    }
    Text{
        text:"Risco potencial de um acidente quando ocorre uma falha"
    }
    ComboBox {
        id:riscoAbcCombobox
        textRole:"Name"
        model:ListModel{
            ListElement{
                Name:"Risco Alto"
                Value:"A"
            }
            ListElement{
                Name:"Risco Médio ou baixo"
                Value:"B"
            }
            ListElement{
                    Name:"Risco descartado"
                    Value:"C"
            }
        }
        Layout.preferredWidth: 350
        Layout.alignment:  Qt.AlignHCenter
    }
    Text{
        text:"Risco de perdas, reclamações, retrabalhos"
    }
    ComboBox {
        id:perdaCombobox
        textRole:"Name"
        model:ListModel{
            ListElement{
                Name:"Risco Alto para perdas ou retrabalhos"
                Value:"A"
            }
            ListElement{
                Name:"Risco Médio para perdas ou retrabalhos"
                Value:"B"
            }
            ListElement{
                    Name:"Risco baixo ou descartado"
                    Value:"C"
            }
        }
        Layout.preferredWidth: 350
        Layout.alignment:  Qt.AlignHCenter
    }
    Text{
        text:"Tempo de operação do equipamento"
    }
    ComboBox {
        id:tempoFuncionamentoCombobox
        textRole:"Name"
        model:ListModel{
            ListElement{
                Name:"24 horas/dia"
                Value:"A"
            }
            ListElement{
                Name:"8 a 24 horas/dia"
                Value:"B"
            }
            ListElement{
                Name:"menos que 8 horas/dia"
                Value:"C"
            }
        }
        Layout.preferredWidth: 350
        Layout.alignment:  Qt.AlignHCenter
    }
    Text{
        text:"Impacto no processo durante a falha do equipamento"
    }
    ComboBox {
        id:interrupcaoCombobox
        textRole:"Name"
        model:ListModel{
            ListElement{
                Name:"Interrompe todo processo de produção"
                Value:"A"
            }
            ListElement{
                Name:"Não intenrrompe processo, mas gera perdas"
                Value:"B"
            }
            ListElement{
                Name:"Não há impacto significativo"
                Value:"C"
            }
        }
        Layout.preferredWidth: 350
        Layout.alignment:  Qt.AlignHCenter
    }
    Text{
        text:"Frequência de falha do equipamento"
    }
    ComboBox {
        id:mttfCombobox
        textRole:"Name"
        model:ListModel{
            ListElement{
                Name:"Maior que 1 falha/2 meses"
                Value:"A"
            }
            ListElement{
                Name:"1 falha/2 e 6 meses"
                Value:"B"
            }
            ListElement{
                Name:"Menor que 1 falha/6 meses"
                Value:"C"
            }
        }
        Layout.preferredWidth: 350
        Layout.alignment:  Qt.AlignHCenter
    }
    Text{
        text:"Tempo médio de reparo"
    }
    ComboBox {
        id:mtbrCombobox
        textRole:"Name"
        model:ListModel{
            ListElement{
                Name:"Maior que 2h"
                Value:"A"
            }
            ListElement{
                Name:"entre 0,5h e 2h"
                Value:"B"
            }
            ListElement{
                Name:"menor que 0,5h"
                Value:"C"
            }
        }
        Layout.preferredWidth: 350
        Layout.alignment:  Qt.AlignHCenter
    }
    Item {
        Layout.fillWidth: true
    }
}
