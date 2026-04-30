import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    anchors.centerIn: parent
    Text{
        text:"Função equipamento"
        Layout.alignment:  Qt.AlignHCenter
    }
    ComboBox {
        //model: ["Sistema de suporte à vida","Terapia","Diagnóstico","Análise","Apoio"]
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
        Layout.preferredWidth: 220
        Layout.alignment:  Qt.AlignHCenter
    }
    Text{
        text:"Risco fornecido pelo equipamento"
        Layout.alignment:  Qt.AlignHCenter
    }
    ComboBox {
        //model: ["Morte","Lesão Grave","Lesão leve/moderada","Terapia ou diagnośtico falho","Sem Risco"]
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
        Layout.preferredWidth: 290
        Layout.alignment:  Qt.AlignHCenter
    }
    /*Text{
        text:"Risco fornecido pelo equipamento"
    }
    ComboBox {
        model: ["Sistema de suporte à vida","Terapia","Diagnóstico","Análise","Apoio"]
        Layout.preferredWidth: 220
    }
    /*Text{
        text:"Função equipamento"
    }
    ComboBox {
        model: ["Morte","Lesão Grave","Lesão leve/moderada","Terapia ou diagnośtico falho","Sem Risco"]
        Layout.preferredWidth: 220
    }*/
    Text{
        text:"Risco potencial de um acidente quando ocorre uma falha"
        Layout.alignment:  Qt.AlignHCenter
    }
    ComboBox {
        //model: ["Risco Alto","Risco Médio ou baixo","Risco descartado"]
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
        Layout.preferredWidth: 180
        Layout.alignment:  Qt.AlignHCenter
    }
    Text{
        text:"Risco de perdas, reclamações, retrabalhos"
        Layout.alignment:  Qt.AlignHCenter
    }
    ComboBox {
        //model: ["Risco Alto para perdas ou retrabalhos","Risco Médio para perdas ou retrabalhos","Risco baixo ou descartado"]
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
        Layout.preferredWidth: 320
        Layout.alignment:  Qt.AlignHCenter
    }
    Text{
        text:"Tempo de operação do equipamento"
        Layout.alignment:  Qt.AlignHCenter
    }
    ComboBox {
        //model: ["24 horas/dia","8 a 24 horas/dia","menos que 8 horas/dia"]
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
        Layout.preferredWidth: 200
        Layout.alignment:  Qt.AlignHCenter
    }
    Text{
        text:"Impacto no processo durante a falha do equipamento"
        Layout.alignment:  Qt.AlignHCenter
    }
    ComboBox {
        //model: ["Interrompe todo processo de produção","Não intenrrompe processo, mas gera perdas","Não há impacto significativo"]
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
        Layout.alignment:  Qt.AlignHCenter
    }
    ComboBox {
        //model: ["Maior que 1 falha/2 meses","1 falha/2 e 6 meses","Menor que 1 falha/6 meses"]
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
        Layout.preferredWidth: 230
        Layout.alignment:  Qt.AlignHCenter
    }
    Text{
        text:"Tempo médio de reparo"
        Layout.alignment:  Qt.AlignHCenter
    }
    ComboBox {
        //model: ["Maior que 2h","entre 0,5h e 2h","menor que 0,5h"]
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
        Layout.preferredWidth: 150
        Layout.alignment:  Qt.AlignHCenter
    }
    Item {
        Layout.fillWidth: true
    }
}
