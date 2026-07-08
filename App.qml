import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import CriticidadeApp

ApplicationWindow {
    id: window
    visible: true
    width: 1100
    height: 750
    title: "Sistema de Matriz de Criticidade"

    Material.accent: "#2e7d32"

    property string currentPage: "empresa"
    property int filterEmpresaId: -1

    function goBack() {
        if (window.currentPage === "calculocriticidade") {
            window.currentPage = "equipamento"
        } else if (window.currentPage === "equipamento") {
            window.filterSetorId = -1
            window.filterSetorName = ""
            window.currentPage = "setor"
        } else if (window.currentPage === "setor") {
            window.filterEmpresaId = -1
            window.filterEmpresaName = ""
            window.currentPage = "empresa"
        }
    }

    Shortcut {
        sequence: "Escape"
        onActivated: {
            if (window.currentPage !== "empresa")
                goBack()
        }
    }
    property string filterEmpresaName: ""
    property int filterSetorId: -1
    property string filterSetorName: ""
    property int calcCriticidadeEquipamentoId: -1
    property string calcCriticidadeEquipamentoNome: ""

    Drawer {
        id: drawer
        width: 240
        height: window.height
        modal: false
        position: 0
        edge: Qt.LeftEdge
        interactive: width > 0

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 0
            spacing: 0

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 80
                color: "#1b5e20"

                Label {
                    anchors.centerIn: parent
                    text: "Matriz de\nCriticidade"
                    color: "white"
                    font.pixelSize: 18
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            Repeater {
                model: ListModel {
                    ListElement { label: "Empresas"; page: "empresa"; icon: "🏢" }
                    ListElement { label: "Setores"; page: "setor"; icon: "📂" }
                    ListElement { label: "Equipamentos"; page: "equipamento"; icon: "⚙️" }
                    ListElement { label: "Criticidade"; page: "criticidade"; icon: "📊" }
                }

                delegate: ItemDelegate {
                    id: del
                    Layout.fillWidth: true
                    height: 48
                    highlighted: window.currentPage === model.page

                    contentItem: RowLayout {
                        spacing: 12
                        Label { text: model.icon; font.pixelSize: 20 }
                        Label { text: model.label; font.pixelSize: 14 }
                    }

                    onClicked: {
                        if (model.page === "setor") {
                            window.filterEmpresaId = -1
                            window.filterEmpresaName = ""
                        }
                        if (model.page === "equipamento") {
                            window.filterSetorId = -1
                            window.filterSetorName = ""
                        }
                        window.currentPage = model.page
                        drawer.close()
                    }
                }
            }

            Item { Layout.fillHeight: true }
        }
    }

    ToolBar {
        id: toolbar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: 48
        z: 1
        Material.background: Material.Green

        RowLayout {
            anchors.fill: parent
            ToolButton {
                text: "☰"
                font.pixelSize: 20
                onClicked: drawer.open()
            }
            ToolButton {
                text: "←"
                font.pixelSize: 20
                visible: window.currentPage === "setor" || window.currentPage === "equipamento" || window.currentPage === "calculocriticidade"
                onClicked: goBack()
            }
            Label {
                text: {
                    switch (window.currentPage) {
                        case "empresa": return "Gerenciar Empresas"
                        case "setor": return "Gerenciar Setores"
                        case "equipamento": return "Gerenciar Equipamentos"
                        case "criticidade": return "Gerenciar Criticidade"
                        case "calculocriticidade": return "Cálculo de Criticidade"
                default: return ""
                    }
                }
                font.pixelSize: 16
                font.bold: true
                elide: Text.ElideRight
                Layout.fillWidth: true
                leftPadding: 8
            }
        }
    }

    ColumnLayout {
        anchors.top: toolbar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        spacing: 0

        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: {
                switch (window.currentPage) {
                    case "empresa": return 0
                    case "setor": return 1
                    case "equipamento": return 2
                    case "criticidade": return 3
                    case "calculocriticidade": return 4
                    default: return 0
                }
            }

            EmpresaPage {
                onNavigateToSetores: function(empresaId, empresaName) {
                    filterEmpresaId = empresaId
                    filterEmpresaName = empresaName
                    currentPage = "setor"
                }
            }
            SetorPage {
                filterEmpresaId: window.filterEmpresaId
                filterEmpresaName: window.filterEmpresaName
                onNavigateToEquipamentos: function(setorId, setorName) {
                    filterSetorId = setorId
                    filterSetorName = setorName
                    currentPage = "equipamento"
                }
            }
            EquipamentoPage {
                filterSetorId: window.filterSetorId
                filterSetorName: window.filterSetorName
                filterEmpresaId: window.filterEmpresaId
                onNavigateToCriticidade: function(equipamentoId, equipamentoNome) {
                    window.calcCriticidadeEquipamentoId = equipamentoId
                    window.calcCriticidadeEquipamentoNome = equipamentoNome
                    window.currentPage = "calculocriticidade"
                }
            }
            CriticidadePage { }
            Item {
                id: calcCritContainer
                visible: window.currentPage === "calculocriticidade"
                Loader {
                    id: calcLoader
                    anchors.fill: parent
                    active: false
                    sourceComponent: CalculoCriticidadePage {
                        equipamentoId: window.calcCriticidadeEquipamentoId
                        equipamentoNome: window.calcCriticidadeEquipamentoNome
                    }
                }
                onVisibleChanged: {
                    if (visible && window.currentPage === "calculocriticidade")
                        calcLoader.active = true
                    else
                        calcLoader.active = false
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            color: "#f0f0f0"
            RowLayout {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left; anchors.leftMargin: 0
                spacing: 2
                Image { source: "ifal_logo.png"; fillMode: Image.PreserveAspectFit; Layout.preferredHeight: 32 }
                Label { text: "Instituto Federal de Alagoas 2026"; font.pixelSize: 12; color: "#2e7d32"; font.bold: true }
            }
        }
    }
}
