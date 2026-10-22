"""Logs estructurados en JSON, una línea por evento [CAL-05].

Nunca registres secretos ni datos personales: usa identificadores, no nombres ni correos.
"""

import json
import logging
from datetime import UTC, datetime
from typing import Any

_CAMPOS_ESTANDAR = set(vars(logging.makeLogRecord({})))


class FormatoJSON(logging.Formatter):
    def format(self, record: logging.LogRecord) -> str:
        evento: dict[str, Any] = {
            "timestamp": datetime.fromtimestamp(record.created, tz=UTC).isoformat(),
            "level": record.levelname,
            "logger": record.name,
            "message": record.getMessage(),
        }
        # Campos adicionales: logger.info("pago creado", extra={"pago_id": 42})
        evento.update(
            {k: v for k, v in vars(record).items() if k not in _CAMPOS_ESTANDAR and k != "message"}
        )
        if record.exc_info:
            evento["exception"] = self.formatException(record.exc_info)
        return json.dumps(evento, ensure_ascii=False, default=str)


def configurar_logs(nivel: str = "INFO") -> None:
    """Envía todos los logs a la salida estándar en formato JSON."""
    manejador = logging.StreamHandler()
    manejador.setFormatter(FormatoJSON())
    raiz = logging.getLogger()
    raiz.handlers = [manejador]
    raiz.setLevel(nivel)
