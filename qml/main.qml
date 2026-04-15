import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    visible: true
    width: 1280
    height: 720
    title: "Matriz de Criticidade"

    property string equipamentoSelecionado: "Equipamento 1"

    ColumnLayout {
        anchors.fill: parent
        spacing: 10
        padding: 10

        Label {
            text: appController.instituicao
            font.pixelSize: 28
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            // ESQUERDA
            ColumnLayout {
                Layout.preferredWidth: 350

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
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    placeholderText: "Breve descrição..."
                }
            }

            // DIREITA (MATRIZ)
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Label {
                    text: "Matriz de Criticidade do " + equipamentoSelecionado
                }

                GridLayout {
                    columns: 3
                    rows: 3
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Repeater {
                        model: 9

                        Rectangle {
                            border.color: "black"

                            color: {
                                var row = Math.floor(index / 3)
                                var col = index % 3
                                var v = row + col
                                if (v <= 1) return "green"
                                if (v == 2) return "yellow"
                                if (v == 3) return "orange"
                                return "red"
                            }

                            Label {
                                anchors.centerIn: parent
                                text: index+1
                            }
                        }
                    }
                }
            }
        }

        Label {
            text: appController.instituicao + " - 2026"
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
        }
    }
}