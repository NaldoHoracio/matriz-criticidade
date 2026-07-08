import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts

Popup {
    id: root
    modal: true
    closePolicy: Popup.CloseOnEscape
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    width: 500
    height: 320

    property string dateText: ""
    property int selectedYear: new Date().getFullYear()
    signal datePicked(string date)

    readonly property var months: [
        "Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho",
        "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro"
    ]

    function parseParts() {
        if (!dateText) return { year: new Date().getFullYear(), month: 1, day: 1 }
        var parts = dateText.split("-")
        var y = parseInt(parts[0])
        var m = parseInt(parts[1])
        var d = parseInt(parts[2])
        if (isNaN(y)) y = new Date().getFullYear()
        if (isNaN(m)) m = 1
        if (isNaN(d)) d = 1
        return { year: y, month: m, day: d }
    }

    function daysInMonth(y, m) {
        return new Date(y, m, 0).getDate()
    }

    function updateDayModel() {
        var max = daysInMonth(selectedYear, monthCombo.currentIndex + 1)
        var days = []
        for (var i = 1; i <= max; i++) days.push(i)
        dayCombo.model = days
        if (parseInt(dayCombo.currentValue) > max) dayCombo.currentIndex = max - 1
    }

    function buildYearModel() {
        var years = []
        for (var i = 1000; i <= 3000; i++) years.push(i)
        return years
    }

    onOpened: {
        var p = parseParts()
        selectedYear = p.year
        monthCombo.currentIndex = Math.max(0, Math.min(11, p.month - 1))
        updateDayModel()
        var max = daysInMonth(p.year, p.month)
        dayCombo.currentIndex = Math.max(0, Math.min(max - 1, p.day - 1))
    }

    background: Rectangle { color: "#f0f0f0"; border.color: "#999"; radius: 4 }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 20

        Label { text: "Selecionar Data"; font.bold: true; font.pixelSize: 18; Layout.alignment: Qt.AlignHCenter }

        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            spacing: 12

            ColumnLayout {
                spacing: 6
                Layout.alignment: Qt.AlignHCenter
                Label { text: "Dia"; font.pixelSize: 13; font.bold: true; Layout.alignment: Qt.AlignHCenter }
                ComboBox {
                    id: dayCombo
                    model: []
                    font.pixelSize: 16
                    implicitWidth: 100
                    implicitHeight: 48
                }
            }

            ColumnLayout {
                spacing: 6
                Layout.alignment: Qt.AlignHCenter
                Label { text: "Mês"; font.pixelSize: 13; font.bold: true; Layout.alignment: Qt.AlignHCenter }
                ComboBox {
                    id: monthCombo
                    model: months
                    font.pixelSize: 16
                    implicitWidth: 150
                    implicitHeight: 48
                    onActivated: updateDayModel()
                }
            }

            ColumnLayout {
                spacing: 6
                Layout.alignment: Qt.AlignHCenter
                Label { text: "Ano"; font.pixelSize: 13; font.bold: true; Layout.alignment: Qt.AlignHCenter }
                Rectangle {
                    id: yearSelector
                    implicitWidth: 120
                    implicitHeight: 48
                    border.color: "#999"
                    border.width: 1
                    radius: 4
                    color: "white"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 8
                        spacing: 4
                        Label {
                            id: yearLabel
                            text: selectedYear
                            font.pixelSize: 16
                            Layout.fillWidth: true
                        }
                        Label {
                            text: "\u25BC"
                            font.pixelSize: 10
                            color: "#666"
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: yearPopup.open()
                    }

                    Popup {
                        id: yearPopup
                        y: parent.height
                        width: parent.width
                        height: 300
                        padding: 0

                        onOpened: {
                            yearListView.positionViewAtIndex(
                                Math.max(0, Math.min(2000, selectedYear - 1000)),
                                ListView.Center
                            )
                        }

                        ListView {
                            id: yearListView
                            anchors.fill: parent
                            model: buildYearModel()
                            clip: true

                            delegate: ItemDelegate {
                                text: modelData
                                width: ListView.view.width
                                highlighted: modelData === selectedYear
                                onClicked: {
                                    selectedYear = modelData
                                    yearPopup.close()
                                    updateDayModel()
                                }
                            }

                            ScrollIndicator.vertical: ScrollIndicator { }
                        }
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }

        RowLayout {
            Layout.fillWidth: true
            spacing: 16
            Item { Layout.fillWidth: true }
            Button { text: "Cancelar"; implicitWidth: 100; implicitHeight: 40; onClicked: root.close() }
            Button { text: "OK"; highlighted: true; Material.accent: "#2e7d32"; implicitWidth: 100; implicitHeight: 40; onClicked: {
                var dStr = String(selectedYear) + "-"
                    + ("00" + String(monthCombo.currentIndex + 1)).slice(-2) + "-"
                    + ("00" + String(dayCombo.currentValue)).slice(-2)
                root.datePicked(dStr)
                root.close()
            } }
        }
    }
}
