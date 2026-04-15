# Matriz de Criticidade (Qt + QML)

Aplicação gráfica para análise de criticidade de equipamentos utilizando
uma matriz 3x3 (heatmap).

------------------------------------------------------------------------

## 🚀 Tecnologias

-   Qt 6
-   QML (Qt Quick)
-   C++
-   CMake

------------------------------------------------------------------------

## 📦 Funcionalidades

-   Seleção de equipamento (ComboBox)
-   Seleção de setor
-   Definição de função e risco
-   Matriz de criticidade visual (heatmap 3x3)
-   Campo de descrição textual
-   Título dinâmico baseado no equipamento

------------------------------------------------------------------------

## 📁 Estrutura do Projeto

    MatrizCriticidade/
    │
    ├── CMakeLists.txt
    ├── resources.qrc
    │
    ├── src/
    │   ├── main.cpp
    │   └── AppController.cpp
    │
    ├── header/
    │   └── AppController.h
    │
    ├── qml/
    │   └── Main.qml
    │
    ├── tests/
    │   ├── CMakeLists.txt
    │   └── test_app.cpp
    │
    └── README.md

------------------------------------------------------------------------

## ▶️ Como compilar e executar

### 🔧 1. Criar pasta de build

``` bash
mkdir build
cd build
```

### ⚙️ 2. Gerar projeto

``` bash
cmake ..
```

### 🛠️ 3. Compilar

``` bash
cmake --build .
```

### ▶️ 4. Executar

``` bash
./appMatriz
```

------------------------------------------------------------------------

## 🧪 Testes Unitários

Para executar os testes:

``` bash
ctest
```

------------------------------------------------------------------------

## 📌 Observações

-   Projeto estruturado com separação entre:
    -   Interface (QML)
    -   Lógica (C++)
    -   Testes
-   Pronto para expansão (MVC / MVVM)
-   Compatível com Qt Creator

------------------------------------------------------------------------

## 🚀 Possíveis Melhorias

------------------------------------------------------------------------

## 👨‍💻 Autor

Projeto acadêmico para análise de criticidade de equipamentos.
