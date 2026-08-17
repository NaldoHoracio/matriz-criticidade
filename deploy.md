# Deploy — Matriz de Criticidade

A aplicação é composta por duas partes:

| Parte | Tecnologia | Artefato |
|---|---|---|
| Frontend | Qt 6.11 (QML) compilado para WebAssembly | `build-wasm/bin/` (HTML + JS + WASM) |
| Backend | FastAPI + PostgreSQL | `server/` (Dockerfile + docker-compose.yml) |

O frontend é **estático** e o backend é **stateless** (dados ficam no PostgreSQL),
o que permite hospedar cada parte em lugares diferentes ou tudo em um servidor só.

---

## 1. Preparando o frontend para produção

O app WASM precisa conhecer a URL da API. Em WebAssembly não existem variáveis de
ambiente — o default está em `main.cpp`:

```cpp
dbManager.setBaseUrl(qEnvironmentVariable("CRITICIDADE_API_URL", "http://localhost:8000"));
```

**Antes de publicar em produção**, troque o default pela URL real (ex.:
`https://api.seudominio.com`) e faça o rebuild:

```bash
export EMSDK=/tmp/opencode/emsdk
source /tmp/opencode/emsdk/emsdk_env.sh
~/Qt/6.11.1/wasm_singlethread/bin/qt-cmake -S . -B build-wasm -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build build-wasm
```

O resultado fica em `build-wasm/bin/` (o CMake já aplica o shell personalizado com o
ícone do app via `patch_wasm_shell.cmake`). Publicar a pasta inteira:
`MatrizCriticidade.html`, `MatrizCriticidade.js`, `MatrizCriticidade.wasm`,
`qtloader.js`, `qtlogo.svg`, `matriz_icon_256.png`.

> Requisito: a API **precisa ser HTTPS** — o navegador bloqueia fetch `http://`
> a partir de uma página `https://`. O CORS do servidor já libera qualquer origem.

---

## 2. Opção A — Servidor próprio (VPS)

### 2.1 Backend (API + PostgreSQL) via Docker

O `server/` já contém `Dockerfile`, `docker-compose.yml` e `requirements.txt`.

```bash
# no servidor (com Docker e docker compose instalados):
scp -r server user@servidor:~/
ssh user@servidor
cd server
docker compose up -d --build
```

- PostgreSQL 16 sobe com volume persistente (`pgdata`)
- API sobe em `0.0.0.0:8000` (`DATABASE_URL` já aponta para o serviço `db`)

### 2.2 Frontend via nginx

```bash
sudo mkdir -p /var/www/matriz
scp build-wasm/bin/* user@servidor:~/
# copiar os arquivos para /var/www/matriz (com permissões corretas)
```

`/etc/nginx/sites-available/matriz`:

```nginx
server {
    listen 80;
    server_name seu-dominio.com;

    root /var/www/matriz;
    index MatrizCriticidade.html;

    location / {
        try_files $uri $uri/ =404;
        add_header Cross-Origin-Opener-Policy same-origin;
        add_header Cross-Origin-Embedder-Policy require-corp;
    }

    # API na mesma máquina (opcional):
    location /api/ {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
    }
}
```

HTTPS (obrigatório para o fetch da API):

```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d seu-dominio.com
```

---

## 3. Opção B — Hospedagem gerenciada

### 3.1 Frontend no GitHub Pages

O repositório `NaldoHoracio/matriz-criticidade` tem a branch `gh-pages` com o
conteúdo de `build-wasm/bin`.

1. GitHub → Settings → Pages → "Deploy from a branch" → `gh-pages` → `/ (root)`
2. URL: `https://NaldoHoracio.github.io/matriz-criticidade/`

Para atualizar após novo build:

```bash
rm -rf /tmp/ghpages && mkdir -p /tmp/ghpages
cp build-wasm/bin/* /tmp/ghpages/
cd /tmp/ghpages
git init -b gh-pages
git add -A
git -c user.name="Marcos Vinicius" -c user.email="marcosviniciusrodriguescosta2@gmail.com" \
    commit -m "Deploy GitHub Pages"
git remote add origin https://github.com/NaldoHoracio/matriz-criticidade.git
git push -f origin gh-pages
```

### 3.2 Backend no Fly.io

Pré-requisito: conta em https://fly.io e um token de acesso pessoal
(https://fly.io/user/personal_access_tokens).

```bash
export FLY_API_TOKEN=<seu-token>
flyctl auth login          # ou: flyctl auth token <token>

cd server
flyctl launch --no-deploy --name matriz-criticidade-api
# editar fly.toml conforme necessário (app, região, etc.)

flyctl postgres create --name matriz-criticidade-db
flyctl postgres attach matriz-criticidade-db --app matriz-criticidade-api

# ajustar a DATABASE_URL gerada (psycopg2) e fazer o deploy:
flyctl deploy
flyctl open
```

O Fly fornece o certificado HTTPS automaticamente (URL: `https://matriz-criticidade-api.fly.dev`).

---

## 4. Verificação pós-instalação

| Teste | Como |
|---|---|
| API viva | `curl https://<url-da-api>/api/health` → `{"status":"ok"}` |
| Dados | `curl https://<url-da-api>/api/tables/empresa` → lista de empresas |
| Frontend | Abrir a URL pública → deve carregar com o ícone do app e abrir a tela de Empresas |
| Persistência | Criar uma empresa, recarregar a página e conferir se ela permanece |