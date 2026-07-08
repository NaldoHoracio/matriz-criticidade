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
        if(riscoAbc ==="A"){
            return 15;
        }
        if(riscoAbc === "B" || riscoAbc === "C"){
            if(perdaAbc === "A"){
                return 15;
            }
            if(perdaAbc === "B" || perdaAbc === "C"){
                if(tempo === "A" || tempo === "B"){
                    if(interrupcao === "A"){
                        if(mttf === "A"){
                            if(mttr === "A"){
                                return 15;
                            }
                            if(mttr === "B"){
                                return 5;
                            }
                            if(mttr === "C"){
                                return 1;
                            }
                        }
                        if(mttf === "B"){
                            console.log("mttf B");
                            if((mttr === "A") || (mttr === "B")){
                                return 5;
                            }
                            if(mttr === "C"){
                                return 1;
                            }
                        }
                        if(mttf === "C"){
                            return 1;
                        }
                    }
                    if(interrupcao === "B"){
                        if(mttf ==="A" || mttf ==="B"){
                            if(mttr === "A" || mttr === "B"){
                                return 5;
                            }
                            if(mttr === "C"){
                                return 1;
                            }
                        }
                        if(mttf ==="C"){
                            return 1;
                        }
                    }
                    if(interrupcao === "C"){
                        return 1;
                    }
                }
                if(tempo === "C"){
                    if(interrupcao === "A" || interrupcao === "B"){
                        if(mttf === "A" || mttf === "B"){
                            if(mttr === "A" || mttr === "B"){
                                return 5;
                            }
                            if(mttr === "C"){
                                return 1;
                            }
                        }
                        if(mttf === "C"){
                            return 1;
                        }
                    }
                    if(interrupcao === "C"){
                        return 1;
                    }
                }
            }
        }
    }
    function printComboboxesValues(){
        console.log("riscoAbc "+riscoAbc);
        console.log("perdaAbc "+perdaAbc);
        console.log("tempo "+tempo);
        console.log("interrupcao "+interrupcao);
        console.log("mttf "+mttf);
        console.log("mttr "+mttr);
    }
    function loadData(data, intToAbc) {
        setComboValue(funcaoCombobox, data.Funcao)
        setComboValue(riscoCombobox, data.Risco)
        setComboIndexByValue(riscoAbcCombobox, intToAbc(data.RiscoAbc))
        setComboIndexByValue(perdaCombobox, intToAbc(data.PerdaAbc))
        setComboIndexByValue(tempoFuncionamentoCombobox, intToAbc(data.Tempo))
        setComboIndexByValue(interrupcaoCombobox, intToAbc(data.Interrupcao))
        setComboIndexByValue(mttfCombobox, intToAbc(data.Mttf))
        setComboIndexByValue(mtbrCombobox, intToAbc(data.Mttr))
    }
    function setInitialFuncao(valor) {
        setComboValue(funcaoCombobox, valor)
    }
    function setComboValue(combo, value) {
        for (var i = 0; i < combo.count; i++) {
            if (combo.model.get(i)[combo.valueRole] === value) { combo.currentIndex = i; return }
        }
    }
    function setComboIndexByValue(combo, value) {
        for (var i = 0; i < combo.count; i++) {
            if (combo.model.get(i)[combo.valueRole] === value) { combo.currentIndex = i; return }
        }
    }
    function calculateCriticity(){
        printComboboxesValues();
        var AbcClassification=classifyAbc();
        var criticity=(funcao+risco)*(AbcClassification+funcao);
        return criticity;
    }
    Text{
        text:"Função equipamento"
    }
    ComboBox {
        id:funcaoCombobox
        textRole:"Name"
        valueRole:"Value"
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
        Layout.preferredWidth: 350
        Layout.alignment:  Qt.AlignHCenter
    }
    Text{
        text:"Risco fornecido pelo equipamento"
    }
    ComboBox {
        id:riscoCombobox
        textRole:"Name"
        valueRole:"Value"
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
        valueRole:"Value"
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
        valueRole:"Value"
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
        valueRole:"Value"
        model:ListModel{
            ListElement{
                Name:"24 horas por dia"
                Value:"A"
            }
            ListElement{
                Name:"8 a 24 horas por dia"
                Value:"B"
            }
            ListElement{
                Name:"menos que 8 horas por dia"
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
        valueRole:"Value"
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
        valueRole:"Value"
        model:ListModel{
            ListElement{
                Name:"Maior que 1 falha a cada 2 meses"
                Value:"A"
            }
            ListElement{
                Name:"1 falha entre 2 e 6 meses"
                Value:"B"
            }
            ListElement{
                Name:"Menor que 1 falha a cada 6 meses"
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
        valueRole:"Value"
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
