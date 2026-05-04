import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MatrizCriticidade

ApplicationWindow {
    visible: true
    width: 1280
    height: 720
    title: "Matriz de Criticidade"

    property string equipamentoSelecionado: "Equipamento 1"
    property int criticityValue:2
    property int  funcao: 1
    property int risco: 0
    property int classificacaoAbc:1
    property int impacto:0
    property int probabilidade:0

    StackView{
        id:screenStack
        anchors.fill: parent
        initialItem: criticalityForm
    }
    RowLayout{
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 20
        spacing:10
        Button{
            id:goToCriticalityForm
            text: "form"
            onClicked: screenStack.push(criticalityForm)
        }
        Button{
            id:goToMatriz
            text:"matriz"
            onClicked: {
                screenStack.push(criticalityMatrixComponents);
            }
        }
    }

    Component{
        id:institutionSelect
        Page{
            InstitutionSelect{
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
        }
    }
    Component{
        id:criticalityForm
        Page{
            CriticalityForm{
                id:form
                Layout.fillWidth: true
                Layout.fillHeight: true
                Button{
                    text:"Calcular Criticidade"
                    onClicked:{
                        criticityValue=form.calculateCriticity();
                        funcao=form.getFuncao().Value;
                        risco=form.getRisco().Value;
                        classificacaoAbc=form.getClassificacao();
                        impacto=funcao+risco;
                        probabilidade=classificacaoAbc+funcao;
                        console.log(impacto);
                        console.log(probabilidade);
                        screenStack.push(criticalityMatrixComponents);
                    }
                }
            }
        }
    }
    Component{
        id:criticalityMatrixComponents
        Page{
            CriticalityMatrixComponents{
                Layout.fillWidth: true
                Layout.fillHeight: true

                Label {
                    id:criticality
                    text: criticityValue
                }
            }
        }
    }
}