import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    id:institutionForm
    anchors.centerIn: parent
    property int primary_key
    property alias nome: nomeInstituicao.text
    property alias cnpj: cnpj_text.text
    Text{
        text:"Nome da instituição"
    }
    TextField {
        id:nomeInstituicao
        Layout.preferredWidth: 350
        Layout.alignment:  Qt.AlignHCenter
    }
    Text{
        text:"CNPJ da instituição"
    }
    TextField {
        id:cnpj_text
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
            id:salvarInstituicao
            text: qsTr("Salvar Instituição");
            onClicked: {
                if(nome ==="" || cnpj ===""){
                    return;
                }
                AppController.insertIntoInstitutions(nome,cnpj);
            }
        }
    }
}
