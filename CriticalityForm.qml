import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    anchors.centerIn: parent
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
