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
    property int criticityValue:0
    /*enum FuncaoValues{
        Sistema_Suporte_a_Vida=5,
        Terapia=4,
        Diagnostico=3,
        Analise=2,
        Suporte=1
    }
    enum RiscoFisicoValues{
        Morte=5,
        LesaoGrave=4,
        LesaoLeveModerada=3,
        TerapiaOuDiagnosticoFalho=2,
        SemRisco=0
    }
    enum GrauImportanciaAbcValues{
        CriticidadeA=15,
        CriticidadeB=5,
        CriticidadeC=1
    }
    function CalculateCriticity(){
        //criticality=(FuncaoValues+RiscoFisicoValues)*(GrauImportanciaAbcValues*FuncaoValues)
    }*/

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