# =============================================================================
#  Makefile — interfaz estándar de los proyectos del AiLab
# =============================================================================
#  Los nombres de los objetivos son un contrato: personas, agentes de IA y CI
#  usan siempre los mismos (setup, dev, test, check). Cambia lo que hace cada
#  uno si tu proyecto lo necesita, pero no sus nombres.
#
#  Detecta el stack automáticamente:
#    pyproject.toml  → Python (uv, ruff, mypy, pytest)
#    package.json    → TypeScript/JavaScript (pnpm; requiere los scripts
#                      dev, format, lint, typecheck y test en package.json)
#  Si existen ambos, cada objetivo se ejecuta para los dos.
# =============================================================================

.DEFAULT_GOAL := help
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
MAKEFLAGS += --no-print-directory

# Cobertura mínima de pruebas (Python). En prototipos: make check COV_MIN=0
COV_MIN ?= 70

PY := $(wildcard pyproject.toml)
JS := $(wildcard package.json)

.PHONY: help setup install env hooks dev fmt lint test check evals lock init clean requisitos

help: ## Muestra los comandos disponibles
	@echo "Uso: make <objetivo>"
	@echo
	@grep -E '^[a-z-]+:.*## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*## "} {printf "  \033[36m%-11s\033[0m %s\n", $$1, $$2}'

# --- Preparación --------------------------------------------------------------

setup: requisitos install env hooks ## Primera vez: instala todo, crea .env y activa los hooks
	@echo
	@echo "Listo. Siguiente paso: make dev"

requisitos:
	@command -v git >/dev/null || { echo "Falta git."; exit 1; }
	@command -v uv >/dev/null || { echo "Falta uv (Python y hooks de git). Instálalo: https://docs.astral.sh/uv/getting-started/installation/"; exit 1; }
ifneq ($(JS),)
	@command -v pnpm >/dev/null || { echo "Falta pnpm. Instálalo: https://pnpm.io/installation"; exit 1; }
endif

install: ## Instala las dependencias exactamente como están en el lockfile (lo usa CI)
ifneq ($(PY),)
	uv sync --locked
endif
ifneq ($(JS),)
	pnpm install --frozen-lockfile
endif

env:
	@if [ ! -f .env ]; then cp .env.example .env; echo "Creado .env a partir de .env.example (revisa los valores)."; fi

hooks:
	@if [ -d .git ]; then uvx pre-commit install; else echo "Sin repositorio git: hooks omitidos."; fi

# --- Desarrollo ---------------------------------------------------------------

dev: ## Levanta el proyecto en local
ifneq ($(JS),)
ifneq ($(PY),)
	@echo "Proyecto con Python y TypeScript: ejecuta cada parte en una terminal:"
	@echo "  uv run uvicorn app.main:app --reload"
	@echo "  pnpm dev"
else
	pnpm dev
endif
else
	uv run uvicorn app.main:app --reload
endif

fmt: ## Formatea el código y aplica correcciones automáticas
ifneq ($(PY),)
	uv run ruff format .
	uv run ruff check --fix .
endif
ifneq ($(JS),)
	pnpm run format
endif

lint: ## Verifica formato, lint y tipos (sin modificar archivos)
ifneq ($(PY),)
	uv run ruff format --check .
	uv run ruff check .
	uv run mypy
endif
ifneq ($(JS),)
	pnpm run lint
	pnpm run typecheck
endif

test: ## Corre las pruebas (con cobertura mínima COV_MIN en Python)
ifneq ($(PY),)
	uv run pytest --cov=src --cov-report=term-missing --cov-fail-under=$(COV_MIN)
endif
ifneq ($(JS),)
	pnpm test
endif

check: lint test ## Todo lo que corre CI. Obligatorio antes de abrir un PR
	@echo
	@echo "make check: OK"

evals: ## Corre las evals de LLM en evals/ (si el proyecto las tiene)
	@if ls evals/test_*.py >/dev/null 2>&1; then uv run pytest evals -q; else echo "Sin evals (evals/test_*.py)."; fi

# --- Mantenimiento ------------------------------------------------------------

lock: ## Actualiza el lockfile después de cambiar dependencias
ifneq ($(PY),)
	uv lock
endif
ifneq ($(JS),)
	pnpm install
endif

init: ## Personaliza la plantilla: make init NOMBRE=mi-proyecto
	@bash scripts/inicializar.sh "$(NOMBRE)"

clean: ## Borra cachés y artefactos generados
	rm -rf .venv .pytest_cache .mypy_cache .ruff_cache .coverage htmlcov dist build node_modules
	find . -type d -name __pycache__ -prune -exec rm -rf {} +
