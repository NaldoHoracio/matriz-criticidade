cmake_minimum_required(VERSION 3.16)
project(CriticidadeApp VERSION 1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 REQUIRED COMPONENTS Quick Sql QuickControls2)

qt_add_executable(CriticidadeApp
    main.cpp
    DatabaseManager.h DatabaseManager.cpp
    TableModel.h TableModel.cpp
)

set_target_properties(CriticidadeApp PROPERTIES
    OUTPUT_NAME "MatrizCriticidade"
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
)

qt_add_qml_module(CriticidadeApp
    URI CriticidadeApp
    VERSION 1.0
    QML_FILES
        App.qml
        TableComponent.qml
        EmpresaPage.qml
        SetorPage.qml
        TipoEquipamentoPage.qml
        EquipamentoPage.qml
        CriticidadePage.qml
        HistoricoPage.qml
        DatePicker.qml
        CriticalityForm.qml
        CriticalityMatrixComponents.qml
        CalculoCriticidadePage.qml
    RESOURCES
        ifal_logo.png
)

target_link_libraries(CriticidadeApp PRIVATE
    Qt6::Quick
    Qt6::Sql
    Qt6::QuickControls2
)

install(TARGETS CriticidadeApp
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
