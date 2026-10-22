import json
import logging

from app.logs import FormatoJSON


def test_los_logs_son_json_con_campos_adicionales() -> None:
    registro = logging.makeLogRecord(
        {"name": "app", "levelname": "INFO", "msg": "pago creado", "pago_id": 42}
    )

    evento = json.loads(FormatoJSON().format(registro))

    assert evento["message"] == "pago creado"
    assert evento["level"] == "INFO"
    assert evento["pago_id"] == 42
    assert "timestamp" in evento
