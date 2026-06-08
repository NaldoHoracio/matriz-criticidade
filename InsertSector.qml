import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    id:sectorForm
    anchors.centerIn: parent
    property int primary_key_sector:1
    property alias nome_setor: nomeSetor.text
    property int fk_id_instituicao:1
    Text{
        text:"Nome do setor"
    }
    TextField {
        id:nomeSetor
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
            text: qsTr("Salvar setor");
            onClicked: {
                if(nome_setor ===""){
                    return;
                }
                AppController.insertIntoSectors(nome_setor,fk_id_instituicao);
                screenStack.pop();
            }
        }
    }
}
