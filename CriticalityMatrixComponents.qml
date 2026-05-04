import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    id:criticalityMatrixComponents
    anchors.centerIn: parent

    Label {
        text: "Matriz de Criticidade do " + equipamentoSelecionado
    }

    GridLayout {
        columns: 5
        rows: 5
        Layout.fillWidth: true
        Layout.fillHeight: true

        Repeater {
            model: 25
            Rectangle {
                border.color:{
                    if((impacto ===1 || impacto ===2) && (probabilidade ===2 || probabilidade ===3) && (index===20)){
                        return "darkgreen";
                    }
                    if(((impacto ===1) || (impacto ===2)) && ((probabilidade ===4) || (probabilidade ===5)) && (index===21)){
                        return "darkgreen";
                    }
                    if(((impacto ===1) || (impacto ===2)) && ((probabilidade ===6) || (probabilidade ===15)) && (index===22)){
                        return "darkgreen";
                    }
                    if(((impacto ===1) || (impacto ===2)) && ((probabilidade ===16) || (probabilidade ===18)) && (index===23)){
                        return "darkgreen";
                    }
                    if(((impacto ===1) || (impacto ===2)) && ((probabilidade ===19) || (probabilidade ===20)) && (index===24)){
                        return "darkgreen";
                    }
                    if(((impacto ===3) || (impacto ===4)) && ((probabilidade ===2) || (probabilidade ===3)) && (index===15)){
                        return "darkgreen";
                    }
                    if(((impacto ===3) || (impacto ===4)) && ((probabilidade ===4) || (probabilidade ===5)) && (index===16)){
                        return "darkgreen";
                    }
                    if(((impacto ===3) || (impacto ===4)) && ((probabilidade ===6) || (probabilidade ===15)) && (index===17)){
                        return "darkgreen";
                    }
                    if(((impacto ===3) || (impacto ===4)) && ((probabilidade ===16) || (probabilidade ===18)) && (index===18)){
                        return "darkgreen";
                    }
                    if(((impacto ===3) || (impacto ===4)) && ((probabilidade ===19) || (probabilidade ===20)) && (index===19)){
                        return "darkgreen";
                    }
                    if(((impacto ===5) || (impacto ===6)) && ((probabilidade ===2) || (probabilidade ===3)) && (index===10)){
                        return "darkgreen";
                    }
                    if(((impacto ===5) || (impacto ===6)) && ((probabilidade ===4) || (probabilidade ===5)) && (index===11)){
                        return "darkgreen";
                    }
                    if(((impacto ===5) || (impacto ===6)) && ((probabilidade ===6) || (probabilidade ===15)) && (index===12)){
                        return "darkgreen";
                    }
                    if(((impacto ===5) || (impacto ===6)) && ((probabilidade ===16) || (probabilidade ===18)) && (index===13)){
                        return "darkgreen";
                    }
                    if(((impacto ===5) || (impacto ===6)) && ((probabilidade ===19) || (probabilidade ===20)) && (index===14)){
                        return "darkgreen";
                    }
                    if(((impacto ===7) || (impacto ===8)) && ((probabilidade ===2) || (probabilidade ===3)) && (index===5)){
                        return "darkgreen";
                    }
                    if(((impacto ===7) || (impacto ===8)) && ((probabilidade ===4) || (probabilidade ===5)) && (index===6)){
                        return "darkgreen";
                    }
                    if(((impacto ===7) || (impacto ===8)) && ((probabilidade ===6) || (probabilidade ===15)) && (index===7)){
                        return "darkgreen";
                    }
                    if(((impacto ===7) || (impacto ===8)) && ((probabilidade ===16) || (probabilidade ===18)) && (index===8)){
                        return "darkgreen";
                    }
                    if(((impacto ===7) || (impacto ===8)) && ((probabilidade ===19) || (probabilidade ===20)) && (index===9)){
                        return "darkgreen";
                    }
                    if(((impacto ===9) || (impacto ===10)) && ((probabilidade ===2) || (probabilidade ===3)) && (index===0)){
                        return "darkgreen";
                    }
                    if(((impacto ===9) || (impacto ===10)) && ((probabilidade ===4) || (probabilidade ===5)) && (index===1)){
                        return "darkgreen";
                    }
                    if(((impacto ===9) || (impacto ===10)) && ((probabilidade ===6) || (probabilidade ===15)) && (index===2)){
                        return "darkgreen";
                    }
                    if(((impacto ===9) || (impacto ===10)) && ((probabilidade ===16) || (probabilidade ===18)) && (index===3)){
                        return "darkgreen";
                    }
                    if(((impacto ===9) || (impacto ===10)) && ((probabilidade ===19) || (probabilidade ===20)) && (index===4)){
                        return "darkgreen";
                    }
                    else{
                        return "black";
                    }
                }
                border.width: 5
                Layout.preferredHeight: 80
                Layout.preferredWidth: 80
                color: {
                    if(index===2 || index===3 || index===4 || index===7 || index===8 || index===9 || index===13 || index===14){
                        return "red";
                    }
                    if(index===15 || index===16 || index===20 || index===21 || index===22){
                        return "darkgreen";
                    }
                    else{
                        return "yellow";
                    }
                }
            }
        }
    }
}
