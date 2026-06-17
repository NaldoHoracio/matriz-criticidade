import QtQuick
import QtTest

TestCase {
    name: "ComponentTests"

    function test_math() {
        compare(2 + 2, 4, "A matemática básica falhou!");
    }

    // Aqui poderão ser adicionados testes envolvendo os componentes da pasta qml/components/
    // Exemplo:
    // Component {
    //     id: myComponent
    //     Item {}
    // }
    //
    // function test_component() {
    //     let obj = createTemporaryObject(myComponent, null)
    //     verify(obj !== null)
    // }
}
