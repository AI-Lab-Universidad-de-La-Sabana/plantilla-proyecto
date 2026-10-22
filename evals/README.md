# evals/

Evaluaciones del comportamiento de los componentes con LLM [IA-09]. Se ejecutan con `make evals`.

- Al menos 20 casos representativos, incluidos casos límite, con datos sintéticos o anonimizados.
- Cada archivo `test_*.py` define casos y un criterio de éxito medible (exactitud, formato, etc.).
- Corren cuando cambian los prompts o el modelo; una regresión bloquea el merge igual que un test.
- Valida las salidas estructuradas contra un esquema (p. ej., un modelo de Pydantic) antes de usarlas.
