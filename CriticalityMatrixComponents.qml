import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    id:criticalityMatrixComponents
    anchors.centerIn: parent
    //property alias criticalityScore:criticality.text
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
                border.color: "black"
                Layout.preferredHeight: 80
                Layout.preferredWidth: 80
                color: {
                    if(index===2 || index===3 || index===4 || index===7 || index===8 || index===9 || index===13 || index===14){
                        return "red";
                    }
                    if(index===15 || index===20 || index===21 || index===22){
                        return "green";
                    }
                    else{
                        return "yellow";
                    }
                }

            }
        }
    }
}
