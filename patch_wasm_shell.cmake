get_filename_component(HTML_DIR "${INPUT_HTML}" DIRECTORY)
file(COPY "${LOGO}" DESTINATION "${HTML_DIR}")
file(READ "${INPUT_HTML}" content)
string(REPLACE
    "<img src=\"qtlogo.svg\" width=\"320\" height=\"200\" style=\"display:block\"></img>"
    "<img src=\"matriz_icon_256.png\" width=\"96\" height=\"96\" style=\"display:block\"></img>"
    content "${content}")
string(REPLACE
    "<strong>Qt for WebAssembly: MatrizCriticidade</strong>"
    "<strong>Matriz de Criticidade</strong>"
    content "${content}")
string(REPLACE
    "<title>MatrizCriticidade</title>"
    "<title>MatrizCriticidade</title>\n    <link rel=\"icon\" type=\"image/png\" href=\"matriz_icon_256.png\">"
    content "${content}")
file(WRITE "${INPUT_HTML}" "${content}")