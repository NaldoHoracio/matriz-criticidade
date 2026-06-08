import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    id:equipmentForm
    anchors.centerIn: parent
    property int id_equipamento
    property alias patrimonio_text: patrimonio.text
    property alias modelo_text: modelo.text
    property alias fabricante_text: fabricante.text
    property alias data_de_aquisicao_text: data_de_aquisicao.text
    property int fk_id_setor:1
    property int  fk_tipo_equipmanto: 1
    Text{
        text:"Patrimonio"
    }
    TextField {
        id:patrimonio
        Layout.preferredWidth: 350
        Layout.alignment:  Qt.AlignHCenter
    }
    Text{
        text:"Modelo"
    }
    TextField {
        id:modelo
        Layout.preferredWidth: 350
        Layout.alignment:  Qt.AlignHCenter
    }
    Text{
        text:"Fabricante"
    }
    TextField {
        id:fabricante
        Layout.preferredWidth: 350
        Layout.alignment:  Qt.AlignHCenter
    }
    Text{
        text:"Data de aquisição"
    }
    TextField {
        id:data_de_aquisicao
        Layout.preferredWidth: 350
        Layout.alignment:  Qt.AlignHCenter
    }
    RowLayout{
        Button{
            id:cancelar
            text: qsTr("Cancelar");
            onClicked: {
                screenStack.pop();
            }
        }
        Button{
            id:salvarSetor
            text: qsTr("Salvar Equipamento");
            onClicked: {
                if(patrimonio_text ==="" || modelo_text ==="" || fabricante_text ==="" || data_de_aquisicao_text===""){
                    return;
                }
                AppController.insertIntoEquipments(patrimonio_text,modelo_text,fabricante_text,data_de_aquisicao_text,fk_id_setor,fk_tipo_equipmanto);
            }
        }
    }
}
