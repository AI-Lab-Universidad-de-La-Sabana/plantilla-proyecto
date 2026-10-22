# nombre-proyecto

<!-- plantilla:inicio — `make init` borra este bloque -->
> [!IMPORTANT]
> **Este es el repositorio `plantilla-proyecto` del AiLab.** Es la base de todo proyecto nuevo y aplica la [guía de ingeniería](https://github.com/AI-Lab-Universidad-de-La-Sabana/guia-ingenieria). No se desarrolla aquí: se usa para crear repositorios.
>
> **Crear un proyecto** (propietario de la organización, [ORG-02](https://github.com/AI-Lab-Universidad-de-La-Sabana/guia-ingenieria#org-02)):
> 1. **[Use this template](https://github.com/AI-Lab-Universidad-de-La-Sabana/plantilla-proyecto/generate)** → dueño `AI-Lab-Universidad-de-La-Sabana`, nombre `<proyecto>-<componente>`, visibilidad **privada**.
> 2. En el repositorio nuevo, con la CLI de GitHub autenticada: `bash scripts/configurar-github.sh estado-poc proy-<proyecto>` (solo squash, borrado de ramas, equipos, topics y etiquetas).
> 3. Clonarlo y ejecutar `make init NOMBRE=<proyecto>-<componente>`: crea la rama `chore/1-inicializar-proyecto`, personaliza los archivos y borra este bloque.
> 4. `make setup && make check`, completar los `<...>` de este README, de `AGENTS.md` y de `docs/operacion.md`, y fusionar por PR.
>
> ¿Proyecto TypeScript? Ver [Proyectos TypeScript](#proyectos-typescript).
>
> **Mantener la plantilla** (equipo base): los cambios entran por PR como en cualquier repositorio. Antes de fusionar, `make check` en verde y una prueba de `make init` en una copia. Al publicar, se actualiza `.plantilla-version` y se crea la etiqueta `vX.Y.Z` con su GitHub Release explicando qué cambió. Los proyectos existentes no se actualizan solos: si un cambio les sirve, se lleva con un PR en cada uno.
<!-- plantilla:fin -->

Descripción de una línea: qué hace este proyecto y para quién.

**Responsables:** @<persona1>, @<persona2> · **Estado:** PoC | producción | mantenimiento
**Guía de ingeniería:** https://github.com/AI-Lab-Universidad-de-La-Sabana/guia-ingenieria

## Requisitos

- `git` y `make`
- [`uv`](https://docs.astral.sh/uv/getting-started/installation/): instala Python 3.13 y los hooks de git

## Inicio rápido

```bash
make setup   # instala dependencias, crea .env y activa los hooks de git
make dev     # levanta la API en http://127.0.0.1:8000 (documentación en /docs)
make check   # formato, lint, tipos y pruebas: lo mismo que corre CI
```

`make help` muestra todos los comandos.

## Estructura

```
src/app/            Código de la aplicación (main.py, config.py, logs.py)
tests/              Pruebas (pytest)
docs/decisiones.md  Registro de decisiones: lee esto antes de preguntar "¿por qué es así?"
docs/operacion.md   Despliegue, rollback y logs
prompts/, evals/    Solo si el proyecto usa LLM (ver sus README)
AGENTS.md           Contexto para agentes de IA y personas nuevas
```

## Cómo contribuir

1. Toma o crea un issue con criterios de aceptación.
2. Crea una rama `<tipo>/<numero-issue>-<descripcion>`, p. ej. `git switch -c feat/12-exportar-csv`.
3. Haz cambios pequeños con sus pruebas y ejecuta `make check`.
4. Abre un PR con título en Conventional Commits (`feat(api): agrega exportación CSV`) y `Closes #12`. La plantilla del PR menciona a `ailab-core` para pedir la revisión.
5. Una persona del equipo base distinta del autor aprueba el PR y **es quien lo fusiona**, con *squash*, cuando CI está en verde.

## Cómo se protege `main` (GitHub Free)

La organización usa GitHub Free. En repositorios privados, ese plan no permite proteger ramas, exigir
revisiones ni aplicar CODEOWNERS en el servidor. La protección se reparte así
([ORG-04](https://github.com/AI-Lab-Universidad-de-La-Sabana/guia-ingenieria#org-04)):

| Capa | Qué hace | Dónde |
|---|---|---|
| Hooks de git | Bloquean commits en `main` y `git push` a `main`; detectan secretos antes del commit | `.pre-commit-config.yaml` (los instala `make setup`) |
| CI | Valida rama, título del PR, secretos, formato, lint, tipos y pruebas en cada PR | `.github/workflows/ci.yml` |
| Auditoría de `main` | Tras cada push a `main`, verifica que todo llegó por un PR aprobado por otra persona; si no, abre un issue para `ailab-core` | Último paso de CI |
| Acuerdo del equipo | Nadie fusiona sin la aprobación de otra persona del equipo base ni con CI en rojo; quien aprueba es quien fusiona | Guía de ingeniería |

Los hooks se pueden saltar con `--no-verify`; no lo hagas. La auditoría lo detecta igual.
Si el repositorio es público, `scripts/configurar-github.sh` además aplica un ruleset que protege
`main` en el servidor.

**Minutos de Actions.** GitHub Free da 2.000 minutos al mes para repositorios privados, compartidos por
toda la organización (los públicos no consumen minutos). Por eso CI es un solo job y cancela las
ejecuciones viejas de la misma rama. Haz `make check` en local antes de hacer push.

## Despliegue

Ver [`docs/operacion.md`](docs/operacion.md). Solo se despliega desde CI, a partir de `main` o de una etiqueta `vX.Y.Z`.

## Proyectos TypeScript

El `Makefile` detecta `package.json` y usa `pnpm`. Para un proyecto solo TypeScript:

1. Borra `pyproject.toml`, `uv.lock`, `.python-version`, `src/app/` y `tests/`, y crea tu proyecto con `pnpm` (p. ej., `pnpm create next-app .`).
2. Asegúrate de que `package.json` tenga los scripts `dev`, `format`, `lint`, `typecheck` y `test`.
3. Crea `.nvmrc` con la versión de Node (p. ej., `22`); CI la usa.
4. En `.github/dependabot.yml`, cambia el ecosistema `uv` por `npm`.

`uv` sigue siendo necesario para los hooks de git (`pre-commit`).
