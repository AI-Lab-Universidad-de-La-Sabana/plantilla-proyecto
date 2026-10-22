# Operación

Completa este documento antes del primer despliegue [DOC-04]. Si el proyecto no se despliega, indícalo
en una línea y borra el resto.

## Dónde corre
- Entornos: `staging` → <URL> · `production` → <URL>
- Infraestructura: <servicio de nube, cuenta de la organización, región>
- Variables de entorno: las de `.env.example`, guardadas como secretos del repositorio en GitHub
  (Settings → Secrets and variables → Actions) con prefijo por entorno: `STAGING_*`, `PRODUCTION_*`.
  En GitHub Free, los repositorios privados no tienen *environments* ni sus reglas de aprobación.

## Cómo desplegar
- `staging`: <automático al fusionar en `main`>
- `production`: <al publicar una etiqueta `vX.Y.Z` con su GitHub Release; solo el equipo base crea etiquetas>
- Nunca se despliega desde un equipo personal.

## Rollback
1. <p. ej., volver a desplegar la etiqueta anterior desde Actions → Deploy → Run workflow.>
2. Abrir un issue con lo ocurrido.

## Logs y monitoreo
- Logs: <dónde verlos>. Están en JSON; filtra por `level` y `message`.
- Salud: `GET /health`.

## Si se cae
1. Revisar `/health` y los logs de los últimos minutos.
2. Si fue el último despliegue, hacer rollback.
3. Avisar a los responsables: @<persona1>, @<persona2>.
