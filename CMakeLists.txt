cmake_minimum_required(VERSION 3.16)

project(MatrizCriticidade VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)
find_package(Qt6 REQUIRED COMPONENTS Sql)
find_package(Qt6 REQUIRED COMPONENTS Test QuickTest)

enable_testing()

qt_standard_project_setup(REQUIRES 6.10)

qt_add_executable(appMatrizCriticidade
    src/main.cpp
)

target_include_directories(appMatrizCriticidade PRIVATE header)

qt_add_qml_module(appMatrizCriticidade
    URI MatrizCriticidade
    QML_FILES
        qml/Main.qml
        SOURCES header/appcontroller.h src/appcontroller.cpp
        QML_FILES
        QML_FILES qml/pages/CriticalityForm.qml
        QML_FILES qml/pages/InstitutionSelect.qml
        QML_FILES qml/components/CriticalityMatrixComponents.qml
        QML_FILES
        QML_FILES
        QML_FILES qml/pages/InsertInstitution.qml
        QML_FILES qml/pages/InsertSector.qml
        QML_FILES qml/pages/InsertEquipment.qml
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appMatrizCriticidade PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appMatrizCriticidade
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appMatrizCriticidade
    PRIVATE Qt6::Quick
)
target_link_libraries(appMatrizCriticidade PRIVATE Qt6::Sql)


install(TARGETS appMatrizCriticidade
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# Testes em C++
qt_add_executable(cpp_test tests/cpp/tst_appcontroller.cpp src/appcontroller.cpp)
target_include_directories(cpp_test PRIVATE header)
target_link_libraries(cpp_test PRIVATE Qt6::Test Qt6::Sql)
add_test(NAME cpp_test COMMAND cpp_test)

# Testes em QML
qt_add_executable(qml_test tests/qml/tst_main.cpp)
target_link_libraries(qml_test PRIVATE Qt6::QuickTest Qt6::Quick)
# Define o caminho onde o runner (tst_main) procurará os arquivos de teste
target_compile_definitions(qml_test PRIVATE QUICK_TEST_SOURCE_DIR="${CMAKE_CURRENT_SOURCE_DIR}/tests/qml")
add_test(NAME qml_test COMMAND qml_test)
