#!/usr/bin/env bash
# Hook pre-push: impide hacer push directo a `main` [ORG-04].
# En GitHub Free, los repositorios privados no pueden proteger ramas en el servidor; este hook
# y la auditoría de CI lo compensan. No lo saltes con --no-verify.
set -euo pipefail

if [[ "${PRE_COMMIT_REMOTE_BRANCH:-}" == "refs/heads/main" ]]; then
  echo "Push directo a main bloqueado."
  echo "Crea una rama <tipo>/<numero-issue>-<descripcion>, haz push de esa rama y abre un PR."
  exit 1
fi
