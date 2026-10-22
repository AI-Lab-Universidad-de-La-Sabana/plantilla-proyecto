# prompts/

Solo para proyectos que usan LLM [IA-08]. Si este proyecto no usa LLM, borra esta carpeta y `evals/`.

- Un archivo por prompt (`clasificar_correo.md`, `resumir_documento.md`), versionado con el código.
- Nada de prompts largos escritos dentro del código: el código los carga desde aquí.
- El modelo y sus parámetros van en variables de entorno, con una versión fija (nunca `latest` en producción).
- Nunca incluyas datos personales reales en los ejemplos de un prompt.
