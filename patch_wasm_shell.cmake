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
string(REPLACE
    "#screen { width: 100%; height: 100%; }"
    "#screen { width: 100%; height: 100%; }\n      .spinner { width: 48px; height: 48px; margin: 8px auto; border: 6px solid #e0e0e0; border-top-color: #2e7d32; border-radius: 50%; animation: qt-spin 1s linear infinite; }\n      @keyframes qt-spin { to { transform: rotate(360deg); } }"
    content "${content}")
string(REPLACE
    "status.innerHTML = 'Loading...';"
    "status.innerHTML = '<div class=\"spinner\"></div>';"
    content "${content}")
file(WRITE "${INPUT_HTML}" "${content}")