#!/usr/bin/env bash
# Personaliza la plantilla con el nombre del proyecto. Uso: make init NOMBRE=tutor-virtual-api
# Se ejecuta una sola vez, en un repositorio recién creado con "Use this template" [ORG-02].
set -euo pipefail

nombre="${1:-}"
marcador="nombre-proyecto"

if [[ -z "$nombre" ]]; then
  echo "Uso: make init NOMBRE=<proyecto>-<componente>   (p. ej., make init NOMBRE=tutor-virtual-api)"
  exit 1
fi
if [[ ! "$nombre" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
  echo "Nombre inválido: '$nombre'. Usa minúsculas y guiones (kebab-case) [ORG-02]."
  exit 1
fi
remoto="$(git remote get-url origin 2>/dev/null || true)"
if [[ "$remoto" =~ /plantilla-proyecto(\.git)?$ ]]; then
  echo "Estás en el repositorio de la plantilla, no en un proyecto. Crea primero un repositorio con"
  echo "\"Use this template\" y ejecuta make init allí."
  exit 1
fi
if ! grep -q "$marcador" pyproject.toml; then
  echo "La plantilla ya fue inicializada (no se encontró '$marcador' en pyproject.toml)."
  exit 1
fi

# La inicialización también entra por PR: los hooks no permiten commits en main.
rama_init="chore/1-inicializar-proyecto"
if [[ -d .git ]] && [[ "$(git branch --show-current 2>/dev/null)" == "main" ]]; then
  git switch -c "$rama_init" >/dev/null 2>&1
  echo "Rama creada: $rama_init"
fi

archivos=(README.md AGENTS.md pyproject.toml .env.example src/app/config.py)
for archivo in "${archivos[@]}"; do
  if [[ -f "$archivo" ]]; then
    sed -i.bak "s/${marcador}/${nombre}/g" "$archivo"
    rm -f "${archivo}.bak"
  fi
done

# Quita del README las instrucciones de uso de la plantilla
sed -i.bak '/<!-- plantilla:inicio/,/<!-- plantilla:fin -->/d' README.md && rm -f README.md.bak
cat -s README.md > README.md.tmp && mv README.md.tmp README.md   # sin líneas en blanco dobles

# Primera decisión: fecha y versión de la plantilla de la que nace el proyecto
hoy="$(date +%Y-%m-%d)"
version="$(tr -d '[:space:]' < .plantilla-version 2>/dev/null || echo desconocida)"
sed -i.bak -e "s/^## AAAA-MM-DD/## ${hoy}/" -e "s/PLANTILLA_VERSION/${version}/" docs/decisiones.md
rm -f docs/decisiones.md.bak

# El nombre del proyecto también está en el lockfile
if command -v uv >/dev/null; then
  uv lock --quiet
fi

echo "Plantilla v${version} inicializada como '$nombre'."
echo "Siguiente: make setup && make check, completa los <...> de README.md, AGENTS.md y docs/,"
echo "y sube los cambios con un PR (git commit, git push -u origin HEAD)."
