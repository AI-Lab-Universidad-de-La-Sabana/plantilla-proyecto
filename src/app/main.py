"""Punto de entrada de la API. Ejecuta `make dev` y abre http://127.0.0.1:8000/docs."""

import logging

from fastapi import FastAPI

from app import __version__
from app.config import get_settings
from app.logs import configurar_logs

logger = logging.getLogger(__name__)


def create_app() -> FastAPI:
    settings = get_settings()  # falla aquí, al arrancar, si la configuración no es válida
    configurar_logs(settings.log_level)

    app = FastAPI(title=settings.app_name, version=__version__)

    @app.get("/health", tags=["operación"])
    def health() -> dict[str, str]:
        """Estado del servicio, para balanceadores y monitoreo."""
        return {"status": "ok", "version": __version__, "env": settings.app_env}

    logger.info("aplicación iniciada", extra={"env": settings.app_env})
    return app


app = create_app()
