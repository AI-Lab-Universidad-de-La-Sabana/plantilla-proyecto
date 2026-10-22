"""Configuración del proyecto, leída de variables de entorno y validada al arrancar [REP-02].

Para añadir una variable:
1. Declárala aquí con su tipo (sin valor por defecto si es obligatoria).
2. Agrégala a `.env.example` con un valor de ejemplo, nunca uno real.
Si falta una variable obligatoria, la aplicación no arranca y el error dice cuál es.
"""

from functools import lru_cache
from typing import Literal

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")

    app_name: str = "nombre-proyecto"
    app_env: Literal["local", "staging", "production"] = "local"
    log_level: Literal["DEBUG", "INFO", "WARNING", "ERROR"] = "INFO"


@lru_cache
def get_settings() -> Settings:
    """Devuelve la configuración (se lee una sola vez por proceso)."""
    return Settings()
