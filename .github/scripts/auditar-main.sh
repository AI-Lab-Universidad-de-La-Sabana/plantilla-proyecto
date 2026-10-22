#!/usr/bin/env bash
# Auditoría de `main` para GitHub Free [ORG-04].
#
# En repositorios privados con GitHub Free no se puede proteger `main` en el servidor. Este script
# corre en CI después de cada push a `main` y verifica que cada commit llegó por un PR fusionado con
# la aprobación de una persona distinta del autor. Si algo no cumple, abre un issue que notifica al
# equipo base y deja el job en rojo. No impide el cambio: lo hace visible para corregirlo.
#
# Requiere: gh y jq (vienen en los runners de GitHub), GH_TOKEN con permisos issues:write y
# pull-requests:read, y las variables estándar de Actions (GITHUB_REPOSITORY, GITHUB_EVENT_PATH...).
set -euo pipefail

repo="${GITHUB_REPOSITORY:?}"
evento="${GITHUB_EVENT_PATH:?}"
org="${repo%%/*}"
hallazgos=()

if [[ "$(jq -r '.forced // false' "$evento")" == "true" ]]; then
  hallazgos+=("Force push a \`main\` por @$(jq -r '.pusher.name' "$evento").")
fi

while read -r sha; do
  [[ -z "$sha" ]] && continue
  corto="${sha:0:7}"

  # El commit inicial de un repositorio creado desde la plantilla no pasa por un PR.
  padres="$(gh api "repos/${repo}/commits/${sha}" --jq '.parents | length')"
  [[ "$padres" == "0" ]] && continue

  pr="$(gh api "repos/${repo}/commits/${sha}/pulls" \
    --jq '[.[] | select(.merged_at != null and .base.ref == "main")][0].number // empty')"
  if [[ -z "$pr" ]]; then
    hallazgos+=("El commit ${corto} llegó a \`main\` sin un PR.")
    continue
  fi

  autor="$(gh api "repos/${repo}/pulls/${pr}" --jq '.user.login')"
  aprobaciones="$(gh api --paginate "repos/${repo}/pulls/${pr}/reviews" \
    --jq ".[] | select(.state == \"APPROVED\" and .user.login != \"${autor}\") | .user.login" \
    | { grep -c . || true; })"
  if [[ "$aprobaciones" -eq 0 ]]; then
    hallazgos+=("El PR #${pr} (de @${autor}) se fusionó sin la aprobación de otra persona.")
  fi
done < <(jq -r '.commits[]?.id' "$evento")

if [[ ${#hallazgos[@]} -eq 0 ]]; then
  echo "Auditoría de main: todo llegó por PR aprobado."
  exit 0
fi

ejecucion="${GITHUB_SERVER_URL:-https://github.com}/${repo}/actions/runs/${GITHUB_RUN_ID:-0}"
cuerpo="$(
  # shellcheck disable=SC2016  # las comillas invertidas son Markdown literal, no una expansión
  printf '@%s/ailab-core: se detectaron cambios en `main` que no siguieron el flujo estándar.\n\n' "$org"
  for h in "${hallazgos[@]}"; do printf -- '- %s\n' "$h"; done
  printf '\n**Qué hacer:** revisar el cambio; si fue un error, revertirlo mediante un PR; '
  printf 'dejar aquí la explicación y cerrar el issue.\n\nEjecución: %s\n' "$ejecucion"
)"
titulo="Auditoría de main: cambios fuera del flujo estándar"

gh issue create --repo "$repo" --title "$titulo" --body "$cuerpo" --label auditoria \
  || gh issue create --repo "$repo" --title "$titulo" --body "$cuerpo"

printf '%s\n' "${hallazgos[@]}"
exit 1
