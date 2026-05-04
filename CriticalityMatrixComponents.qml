import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    id:criticalityMatrixComponents
    anchors.centerIn: parent
    function highlightMatrix(){
        if(((impacto ===1 || impacto ===2)) && ((probabilidade ===2) || (probabilidade ===3))){
            setBorderInTheRectangle(20);
        }
        if(((impacto ===1) || (impacto ===2)) && ((probabilidade ===4) || (probabilidade ===5))){
            setBorderInTheRectangle(21);
        }
        if(((impacto ===1) || (impacto ===2)) && ((probabilidade ===6) || (probabilidade <=15))){
            setBorderInTheRectangle(22);
        }
        if(((impacto ===1) || (impacto ===2)) && ((probabilidade >=16) || (probabilidade ===18))){
            setBorderInTheRectangle(23);
        }
        if(((impacto ===1) || (impacto ===2)) && ((probabilidade ===19) || (probabilidade ===20))){
            setBorderInTheRectangle(24);
        }
        if(((impacto ===3) || (impacto ===4)) && ((probabilidade ===2) || (probabilidade ===3))){
            setBorderInTheRectangle(15);
        }
        if(((impacto ===3) || (impacto ===4)) && ((probabilidade ===4) || (probabilidade ===5))){
            setBorderInTheRectangle(16);
        }
        if(((impacto ===3) || (impacto ===4)) && ((probabilidade ===6) || (probabilidade <=15))){
            setBorderInTheRectangle(17);
        }
        if(((impacto === 3) || (impacto === 4)) && ((probabilidade >= 16) || (probabilidade === 18))){
            setBorderInTheRectangle(18);
        }
        if(((impacto ===3) || (impacto ===4)) && ((probabilidade ===19) || (probabilidade ===20))){
            setBorderInTheRectangle(19);
        }
        if(((impacto ===5) || (impacto ===6)) && ((probabilidade ===2) || (probabilidade ===3))){
            setBorderInTheRectangle(10);
        }
        if(((impacto ===5) || (impacto ===6)) && ((probabilidade ===4) || (probabilidade ===5))){
            setBorderInTheRectangle(11);
        }
        if(((impacto ===5) || (impacto ===6)) && ((probabilidade ===6) || (probabilidade <=15))){
            setBorderInTheRectangle(12);
        }
        if(((impacto ===5) || (impacto ===6)) && ((probabilidade >=16) || (probabilidade ===18))){
            setBorderInTheRectangle(13);
        }
        if(((impacto ===5) || (impacto ===6)) && ((probabilidade ===19) || (probabilidade ===20))){
            setBorderInTheRectangle(14);
        }
        if(((impacto ===7) || (impacto ===8)) && ((probabilidade ===2) || (probabilidade ===3))){
            setBorderInTheRectangle(5);
        }
        if(((impacto ===7) || (impacto ===8)) && ((probabilidade ===4) || (probabilidade ===5))){
            setBorderInTheRectangle(6);
        }
        if(((impacto ===7) || (impacto ===8)) && ((probabilidade ===6) || (probabilidade <=15))){
            setBorderInTheRectangle(7);
        }
        if(((impacto ===7) || (impacto ===8)) && ((probabilidade >=16) || (probabilidade ===18))){
            setBorderInTheRectangle(8);
        }
        if(((impacto ===7) || (impacto ===8)) && ((probabilidade ===19) || (probabilidade ===20))){
            setBorderInTheRectangle(9);
        }
        if(((impacto ===9) || (impacto ===10)) && ((probabilidade ===2) || (probabilidade ===3))){
            setBorderInTheRectangle(0);
        }
        if(((impacto ===9) || (impacto ===10)) && ((probabilidade ===4) || (probabilidade ===5))){
            setBorderInTheRectangle(1);
        }
        if(((impacto ===9) || (impacto ===10)) && ((probabilidade >=6) && (probabilidade <=15))){
            setBorderInTheRectangle(2);
        }
        if(((impacto ===9) || (impacto ===10)) && ((probabilidade >=16) && (probabilidade <=18))){
            setBorderInTheRectangle(3);
        }
        if(((impacto ===9) || (impacto ===10)) && ((probabilidade ===19) || (probabilidade ===20))){
            setBorderInTheRectangle(4);
        }
    }
    function setBorderInTheRectangle(index){
        var item=criticalityMatrix.itemAt(index);
        if(item){
            item.border.color="darkgreen";
            item.border.width=5;
        }
    }
    Label {
        text: "Matriz de Criticidade do " + equipamentoSelecionado
    }

    GridLayout {
        columns: 5
        rows: 5
        Layout.fillWidth: true
        Layout.fillHeight: true

        Repeater {
            id:criticalityMatrix
            model: 25
            Rectangle {
                id:container
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
                Component.onCompleted: {
                    highlightMatrix();
                }
            }
        }
    }
}
