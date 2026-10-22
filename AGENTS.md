# AGENTS.md — nombre-proyecto

Sigue la guía de ingeniería del AiLab:
https://github.com/AI-Lab-Universidad-de-La-Sabana/guia-ingenieria
(reglas para agentes: https://github.com/AI-Lab-Universidad-de-La-Sabana/guia-ingenieria#7-agentes-de-ia)
Responsables: @<persona1>, @<persona2>

## Qué es
<2–3 líneas: qué hace y para quién.>

## Stack
Python 3.13 · FastAPI · pydantic-settings · uv · ruff · mypy (strict) · pytest

## Comandos
- Instalar: `make setup` · Correr: `make dev` · Verificar (obligatorio antes de terminar): `make check`
- Un solo test: `uv run pytest tests/test_health.py -k health`
- Añadir una dependencia: `uv add <paquete>` (de desarrollo: `uv add --dev <paquete>`)

## Mapa del código
- `src/app/main.py` — crea la app FastAPI y registra las rutas
- `src/app/config.py` — configuración por variables de entorno (toda variable nueva va también en `.env.example`)
- `src/app/logs.py` — logs JSON; usa `logging.getLogger(__name__)` y `extra={...}`
- `tests/` — una prueba por comportamiento, con nombres que lo describen
- `docs/decisiones.md` — por qué las cosas son como son

## Convenciones propias
- <p. ej., "Las rutas viven en src/app/rutas/<recurso>.py y no contienen lógica de negocio".>

## Reglas clave
- Trabaja en una rama `<tipo>/<issue>-<desc>`; nunca hagas commit ni push a `main` (los hooks lo bloquean).
- Nunca uses `--no-verify` ni desactives hooks: en GitHub Free son la protección de `main`.
- Cambios mínimos; tests con cada cambio; no debilites tests, linters, tipos ni CI.
- No inventes APIs ni paquetes; no añadas dependencias sin justificarlas en el PR.
- Sin secretos ni datos personales reales en código, tests, logs o prompts.
- Pide confirmación antes de borrar, migrar, desplegar o tocar la configuración de GitHub.
- Termina en un PR; nunca apruebes ni fusiones PRs: eso lo hace una persona del equipo base.
- Al terminar: `make check` y un resumen de qué cambió, supuestos y qué revisar.

## Trampas conocidas
- La configuración se lee una vez (`get_settings` usa caché): en pruebas, crea `Settings(...)` directamente.
- <Añade aquí cada error que alguien (persona o agente) cometa dos veces.>
