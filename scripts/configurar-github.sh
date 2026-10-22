#!/usr/bin/env bash
# Aplica los ajustes estándar a ESTE repositorio en GitHub [ORG-04]. Pensado para GitHub Free.
# Lo ejecuta un propietario una sola vez, desde la raíz del repositorio clonado, con la CLI de
# GitHub autenticada (gh auth login).
#
# Uso: bash scripts/configurar-github.sh [estado] [equipo-proyecto]
#   bash scripts/configurar-github.sh estado-poc proy-tutor-virtual
#
# GitHub Free:
#   - Repositorio privado: no se puede proteger `main` en el servidor. La protegen los hooks locales
#     (make setup) y la auditoría de CI, que abre un issue si algo llega a main sin PR aprobado.
#   - Repositorio público: además se crea un ruleset que protege `main` (scripts/ruleset-main.json).
set -euo pipefail

command -v gh >/dev/null || { echo "Falta la CLI de GitHub: https://cli.github.com"; exit 1; }

repo="$(gh repo view --json nameWithOwner --jq .nameWithOwner)"
visibilidad="$(gh repo view --json visibility --jq .visibility)"
org="${repo%%/*}"
estado="${1:-estado-poc}"   # estado-poc | estado-produccion | estado-mantenimiento
equipo="${2:-}"             # opcional: equipo temporal del proyecto, p. ej. proy-tutor-virtual
dir="$(cd "$(dirname "$0")" && pwd)"

case "$estado" in
  estado-poc|estado-produccion|estado-mantenimiento) ;;
  *) echo "Estado inválido: $estado (usa estado-poc, estado-produccion o estado-mantenimiento)"; exit 1 ;;
esac

echo "Configurando $repo ($visibilidad) ..."

# Solo squash merge con el título del PR como mensaje; borrar ramas tras el merge; sin wiki.
gh api --method PATCH "repos/${repo}" --silent \
  -F allow_squash_merge=true \
  -F allow_merge_commit=false \
  -F allow_rebase_merge=false \
  -F delete_branch_on_merge=true \
  -F has_wiki=false \
  -F has_issues=true \
  -f squash_merge_commit_title=PR_TITLE \
  -f squash_merge_commit_message=PR_BODY

# Equipos [ORG-03]
gh api --method PUT "orgs/${org}/teams/ailab-core/repos/${repo}" -f permission=maintain --silent
if [[ -n "$equipo" ]]; then
  if ! gh api "orgs/${org}/teams/${equipo}" --silent 2>/dev/null; then
    gh api --method POST "orgs/${org}/teams" -f name="$equipo" -f privacy=closed --silent
    echo "Equipo creado: $equipo (agrega a sus integrantes y anota la fecha de fin en el issue de arranque)."
  fi
  gh api --method PUT "orgs/${org}/teams/${equipo}/repos/${repo}" -f permission=push --silent
fi

# Protección de main en el servidor: solo posible en repositorios públicos con GitHub Free.
if [[ "$visibilidad" == "PUBLIC" ]]; then
  id="$(gh api "repos/${repo}/rulesets" --jq '.[] | select(.name == "proteccion-main") | .id')"
  if [[ -n "$id" ]]; then
    gh api --method PUT "repos/${repo}/rulesets/${id}" --input "${dir}/ruleset-main.json" --silent
  else
    gh api --method POST "repos/${repo}/rulesets" --input "${dir}/ruleset-main.json" --silent
  fi
  echo "Ruleset proteccion-main aplicado (repositorio público)."
else
  echo "Repositorio privado en GitHub Free: main queda protegida por los hooks y la auditoría de CI."
fi

# Topics de clasificación
gh repo edit "$repo" --add-topic ailab --add-topic "$estado"

# Etiquetas estándar (se actualizan si ya existen)
crear_etiqueta() { gh label create "$1" --repo "$repo" --color "$2" --description "$3" --force >/dev/null; }
crear_etiqueta "tipo:feat"         "1D76DB" "Nueva funcionalidad"
crear_etiqueta "tipo:fix"          "D73A4A" "Corrección de un defecto"
crear_etiqueta "tipo:docs"         "0E8A16" "Documentación"
crear_etiqueta "prioridad:alta"    "B60205" "Atender primero"
crear_etiqueta "prioridad:media"   "FBCA04" "Prioridad normal"
crear_etiqueta "prioridad:baja"    "C2E0C6" "Cuando haya tiempo"
crear_etiqueta "ai-assisted"       "5319E7" "Aporte sustancial de un agente de IA"
crear_etiqueta "seguridad"         "000000" "Tema de seguridad"
crear_etiqueta "auditoria"         "E99695" "Cambio en main fuera del flujo estándar"

echo "Listo: squash merge, borrado de ramas, equipos, topics (ailab, $estado) y etiquetas configurados."
