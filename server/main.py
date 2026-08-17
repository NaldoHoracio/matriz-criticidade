"""REST API for Matriz de Criticidade.

Mirrors the operations previously done by DatabaseManager (SQLite) so the
client can be switched to a remote PostgreSQL database. Tables and columns
are validated against a whitelist to avoid SQL injection.
"""
import os
from typing import Optional

from fastapi import FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from sqlalchemy import create_engine, text
from sqlalchemy.engine import Connection

DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "postgresql+psycopg2://criticidade:criticidade@localhost:5432/criticidade",
)

engine = create_engine(DATABASE_URL, pool_pre_ping=True)

app = FastAPI(title="Matriz de Criticidade API", version="1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Table name -> primary key column
TABLES = {
    "empresa": "id_empresa",
    "setor": "id_setor",
    "tipo_equipamento": "id_tipo_equipamento",
    "equipamento": "id_equipamento",
    "criticidade": "id_criticidade",
    "historico_manutencao": "id_manutencao",
}

TIPO_EQUIPAMENTO_FIXOS = ["Apoio", "Análise", "Diagnóstico", "Terapia", "Sistema de Suporte à Vida"]
TIPO_EQUIPAMENTO_VALORES = [1, 2, 3, 4, 5]

SCHEMA = """
CREATE TABLE IF NOT EXISTS empresa (
    id_empresa SERIAL PRIMARY KEY,
    nome VARCHAR(200) NOT NULL,
    cnpj VARCHAR(18) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS setor (
    id_setor SERIAL PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    id_empresa INTEGER NOT NULL REFERENCES empresa(id_empresa) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS tipo_equipamento (
    id_tipo_equipamento SERIAL PRIMARY KEY,
    nome VARCHAR(200) NOT NULL UNIQUE,
    descricao TEXT,
    valor INTEGER DEFAULT 0
);

CREATE TABLE IF NOT EXISTS equipamento (
    id_equipamento SERIAL PRIMARY KEY,
    patrimonio VARCHAR(100),
    modelo VARCHAR(200),
    fabricante VARCHAR(200),
    data_aquisicao DATE,
    id_setor INTEGER NOT NULL REFERENCES setor(id_setor) ON DELETE CASCADE,
    id_tipo_equipamento INTEGER NOT NULL REFERENCES tipo_equipamento(id_tipo_equipamento) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS criticidade (
    id_criticidade SERIAL PRIMARY KEY,
    "Funcao" INTEGER DEFAULT 0,
    "Risco" INTEGER DEFAULT 0,
    "RiscoAbc" INTEGER DEFAULT 0,
    "PerdaAbc" INTEGER DEFAULT 0,
    "Tempo" INTEGER DEFAULT 0,
    "Interrupcao" INTEGER DEFAULT 0,
    "Mttf" INTEGER DEFAULT 0,
    "Mttr" INTEGER DEFAULT 0,
    criticidade_final INTEGER DEFAULT 0,
    id_equipamento INTEGER UNIQUE NOT NULL REFERENCES equipamento(id_equipamento) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS historico_manutencao (
    id_manutencao SERIAL PRIMARY KEY,
    data_manutencao DATE NOT NULL,
    tipo_manutencao VARCHAR(100),
    descricao TEXT,
    custo REAL DEFAULT 0,
    responsavel VARCHAR(200),
    observacoes TEXT,
    id_equipamento INTEGER NOT NULL REFERENCES equipamento(id_equipamento) ON DELETE CASCADE
);
"""


def get_conn() -> Connection:
    return engine.connect()


def check_table(table: str) -> str:
    if table not in TABLES:
        raise HTTPException(status_code=404, detail=f"Tabela desconhecida: {table}")
    return TABLES[table]


def columns_of(conn: Connection, table: str) -> dict:
    """Return {column_name: data_type} for a table."""
    rows = conn.execute(
        text("SELECT column_name, data_type FROM information_schema.columns WHERE table_name = :t ORDER BY ordinal_position"),
        {"t": table},
    )
    return {r[0]: r[1] for r in rows}


def coerce(value: str, data_type: str):
    """Convert a string query value to the column's Python type."""
    if value is None:
        return None
    if data_type in ("integer", "smallint", "bigint"):
        try:
            return int(value)
        except ValueError:
            return 0
    if data_type in ("real", "double precision", "numeric"):
        try:
            return float(value)
        except ValueError:
            return 0.0
    if data_type == "date":
        return value  # accepted as ISO string by psycopg
    if data_type == "boolean":
        return value.lower() in ("true", "1", "yes")
    return value


@app.on_event("startup")
def on_startup() -> None:
    with engine.begin() as conn:
        conn.execute(text(SCHEMA))
        # Ensure the criticidade table has all expected columns (idempotent).
        existing = set(columns_of(conn, "criticidade"))
        expected = ["Funcao", "Risco", "RiscoAbc", "PerdaAbc", "Tempo",
                    "Interrupcao", "Mttf", "Mttr", "criticidade_final"]
        for col in expected:
            if col not in existing:
                conn.execute(text(f'ALTER TABLE criticidade ADD COLUMN "{col}" INTEGER DEFAULT 0'))

        # Seed fixed tipo_equipamento rows.
        for nome, valor in zip(TIPO_EQUIPAMENTO_FIXOS, TIPO_EQUIPAMENTO_VALORES):
            conn.execute(
                text("""
                    INSERT INTO tipo_equipamento (nome, valor)
                    SELECT :nome, :valor
                    WHERE NOT EXISTS (SELECT 1 FROM tipo_equipamento WHERE nome = :nome)
                """),
                {"nome": nome, "valor": valor},
            )
            conn.execute(
                text("UPDATE tipo_equipamento SET valor = :valor WHERE nome = :nome AND valor <> :valor"),
                {"nome": nome, "valor": valor},
            )


def row_to_dict(row) -> dict:
    if row is None:
        return {}
    return dict(row._mapping)


# ---------------------------------------------------------------- health
@app.get("/api/health")
def health():
    with get_conn() as conn:
        conn.execute(text("SELECT 1"))
    return {"status": "ok"}


# ------------------------------------------------------------------ read
@app.get("/api/tables/{table}")
def fetch_all(table: str, order_by: Optional[str] = Query(default=None)):
    check_table(table)
    sql = f"SELECT * FROM \"{table}\""
    params = {}
    if order_by:
        sql += f" ORDER BY \"{order_by}\""
    with get_conn() as conn:
        rows = conn.execute(text(sql), params).fetchall()
    return [row_to_dict(r) for r in rows]


@app.get("/api/tables/{table}/where")
def fetch_where(
    table: str,
    column: str = Query(...),
    value: Optional[str] = Query(default=None),
    order_by: Optional[str] = Query(default=None),
):
    check_table(table)
    with get_conn() as conn:
        cols = columns_of(conn, table)
    if column not in cols:
        raise HTTPException(status_code=400, detail=f"Coluna desconhecida: {column}")
    typed = coerce(value, cols[column])
    sql = f"SELECT * FROM \"{table}\" WHERE \"{column}\" = :v"
    if order_by:
        if order_by not in cols:
            raise HTTPException(status_code=400, detail=f"Coluna de ordenação desconhecida: {order_by}")
        sql += f" ORDER BY \"{order_by}\""
    with get_conn() as conn:
        rows = conn.execute(text(sql), {"v": typed}).fetchall()
    return [row_to_dict(r) for r in rows]


@app.get("/api/tables/{table}/columns")
def column_names(table: str):
    check_table(table)
    with get_conn() as conn:
        cols = columns_of(conn, table)
    return list(cols.keys())


@app.get("/api/tables/{table}/pk")
def pk_column(table: str):
    return {"pk": check_table(table)}


@app.get("/api/tables/{table}/options")
def foreign_options(table: str, display: str = Query(...)):
    pk = check_table(table)
    with get_conn() as conn:
        cols = columns_of(conn, table)
    if display not in cols:
        raise HTTPException(status_code=400, detail=f"Coluna desconhecida: {display}")
    order_col = "valor" if table == "tipo_equipamento" else display
    sql = f'SELECT "{pk}" AS id, "{display}" AS display FROM "{table}" ORDER BY "{order_col}"'
    with get_conn() as conn:
        rows = conn.execute(text(sql)).fetchall()
    return [{"id": r[0], "display": r[1]} for r in rows]


@app.get("/api/tables/{table}/distinct")
def distinct_values(table: str, column: str = Query(...)):
    check_table(table)
    with get_conn() as conn:
        cols = columns_of(conn, table)
    if column not in cols:
        raise HTTPException(status_code=400, detail=f"Coluna desconhecida: {column}")
    sql = (
        f'SELECT DISTINCT "{column}" FROM "{table}" '
        f'WHERE "{column}" IS NOT NULL AND "{column}" <> \'\' ORDER BY "{column}"'
    )
    with get_conn() as conn:
        rows = conn.execute(text(sql)).fetchall()
    return [r[0] for r in rows]


@app.get("/api/tables/{table}/{row_id}")
def fetch_by_id(table: str, row_id: int):
    pk = check_table(table)
    with get_conn() as conn:
        row = conn.execute(
            text(f'SELECT * FROM "{table}" WHERE "{pk}" = :id'), {"id": row_id}
        ).fetchone()
    return row_to_dict(row)


# ----------------------------------------------------------------- write
@app.post("/api/tables/{table}")
def create_record(table: str, data: dict):
    pk = check_table(table)
    with get_conn() as conn:
        cols = columns_of(conn, table)

        if table == "tipo_equipamento" and "nome" in data:
            dup = conn.execute(
                text("SELECT COUNT(*) FROM tipo_equipamento WHERE nome = :nome"),
                {"nome": data["nome"]},
            ).scalar()
            if dup and dup > 0:
                return JSONResponse(status_code=200, content={"id": -1})

        allowed = {k: v for k, v in data.items() if k in cols and k != pk}
        if not allowed:
            return JSONResponse(status_code=200, content={"id": -1})

        cols_sql = ", ".join(f'"{k}"' for k in allowed)
        vals_sql = ", ".join(f":{k}" for k in allowed)
        result = conn.execute(
            text(f'INSERT INTO "{table}" ({cols_sql}) VALUES ({vals_sql}) RETURNING "{pk}"'),
            allowed,
        )
        new_id = result.scalar()
        conn.commit()
    return {"id": new_id}


@app.put("/api/tables/{table}/{row_id}")
def update_record(table: str, row_id: int, data: dict):
    pk = check_table(table)
    with get_conn() as conn:
        cols = columns_of(conn, table)

        if table == "tipo_equipamento" and "nome" in data:
            dup = conn.execute(
                text(f'SELECT COUNT(*) FROM tipo_equipamento WHERE nome = :nome AND "{pk}" <> :id'),
                {"nome": data["nome"], "id": row_id},
            ).scalar()
            if dup and dup > 0:
                return {"ok": False}

        allowed = {k: v for k, v in data.items() if k in cols and k != pk}
        if not allowed:
            return {"ok": False}

        sets_sql = ", ".join(f'"{k}" = :{k}' for k in allowed)
        params = dict(allowed)
        params["id"] = row_id
        conn.execute(
            text(f'UPDATE "{table}" SET {sets_sql} WHERE "{pk}" = :id'),
            params,
        )
        conn.commit()
    return {"ok": True}


@app.delete("/api/tables/{table}/{row_id}")
def delete_record(table: str, row_id: int):
    pk = check_table(table)
    with get_conn() as conn:
        # ON DELETE CASCADE handles the child rows (setor -> equipamento -> criticidade/historico).
        conn.execute(text(f'DELETE FROM "{table}" WHERE "{pk}" = :id'), {"id": row_id})
        conn.commit()
    return {"ok": True}


# ------------------------------------------------------------ criticidade
@app.post("/api/criticidade/save")
def save_criticidade(data: dict):
    equip = data.get("equipamentoId")
    fields = {
        "Funcao": data.get("funcao", 0),
        "Risco": data.get("risco", 0),
        "RiscoAbc": data.get("riscoAbc", 0),
        "PerdaAbc": data.get("perdaAbc", 0),
        "Tempo": data.get("tempo", 0),
        "Interrupcao": data.get("interrupcao", 0),
        "Mttf": data.get("mttf", 0),
        "Mttr": data.get("mttr", 0),
        "criticidade_final": data.get("criticidadeFinal", 0),
    }
    with get_conn() as conn:
        existing = conn.execute(
            text("SELECT id_criticidade FROM criticidade WHERE id_equipamento = :id"),
            {"id": equip},
        ).scalar()
        if existing:
            sets = ", ".join(f'"{k}" = :{k}' for k in fields)
            conn.execute(
                text(f"UPDATE criticidade SET {sets} WHERE id_equipamento = :equip"),
                {**fields, "equip": equip},
            )
        else:
            col_sql = ", ".join(f'"{k}"' for k in fields)
            val_sql = ", ".join(f":{k}" for k in fields)
            conn.execute(
                text(
                    f'INSERT INTO criticidade ({col_sql}, id_equipamento) '
                    f"VALUES ({val_sql}, :equip)"
                ),
                {**fields, "equip": equip},
            )
        conn.commit()
    return {"ok": True}


@app.get("/api/criticidade/equipamento/{equip_id}")
def fetch_criticidade_by_equipamento(equip_id: int):
    with get_conn() as conn:
        row = conn.execute(
            text("SELECT * FROM criticidade WHERE id_equipamento = :id"), {"id": equip_id}
        ).fetchone()
    return row_to_dict(row)
