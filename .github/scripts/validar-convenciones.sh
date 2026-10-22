#!/usr/bin/env bash
# Valida el nombre de la rama [FLU-02] y el título del PR en Conventional Commits [FLU-03].
# Uso local: bash .github/scripts/validar-convenciones.sh "feat/12-exportar-csv" "feat(api): agrega CSV"
set -euo pipefail

rama="${1:?Falta el nombre de la rama}"
titulo="${2:?Falta el título del PR}"

patron_rama='^((feat|fix|refactor|docs|test|ci|build|perf|chore|hotfix|spike)/[0-9]+-[a-z0-9][a-z0-9._-]*|release/[0-9]+\.[0-9]+|(claude|codex|copilot|cursor|dependabot|renovate)/.+)$'
patron_titulo='^(feat|fix|refactor|perf|test|docs|build|ci|chore|revert)(\([a-z0-9._/-]+\))?!?: .+$'

errores=0

if [[ "$rama" =~ $patron_rama ]]; then
  echo "Rama válida: $rama"
else
  echo "::error::Rama inválida: '$rama'. Usa <tipo>/<numero-issue>-<descripcion>, p. ej. feat/12-exportar-csv."
  echo "Tipos: feat, fix, refactor, docs, test, ci, build, perf, chore, hotfix, spike."
  errores=1
fi

if [[ "$titulo" =~ $patron_titulo ]]; then
  echo "Título válido: $titulo"
else
  echo "::error::Título de PR inválido: '$titulo'. Usa Conventional Commits, p. ej. 'feat(api): agrega exportación CSV'."
  errores=1
fi

exit "$errores"
