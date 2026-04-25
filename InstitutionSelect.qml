import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    Button{
        id:cadastrarInstituicao
        text:qsTr("Cadastar nova instituição")
    }
    Button{
        id:cadastrarSetor
        text:qsTr("Cadastar novo setor")
    }
    Button{
        id:cadastrarEquipamento
        text:qsTr("Cadastar novo equipamento")
    }
    Button{
        id:atualizarInstituicao
        text:qsTr("Atualizar instituição selecionada")
    }
    Button{
        id:atualizarSetor
        text:qsTr("Atualizar setor selecionado")
    }
    Button{
        id:atualizarEquipamento
        text:qsTr("Atualizar equipamento selecionado")
    }
    ComboBox {
        model: ["Instituição 1", "Instituição 2"]
    }
    ComboBox {
        model: ["Equipamento 1", "Equipamento 2"]
        onCurrentTextChanged: equipamentoSelecionado = currentText
    }

    ComboBox {
        model: ["SETOR 1", "SETOR 2", "SETOR 3"]
    }

    RowLayout {
        ComboBox { model: ["1","2","3"] }
        ComboBox { model: ["1","2","3"] }
    }
    TextArea {
        Layout.preferredWidth: 200
        Layout.fillHeight: true
        placeholderText: "Breve descrição..."
    }
}
