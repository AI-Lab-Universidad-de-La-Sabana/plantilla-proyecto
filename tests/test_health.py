from fastapi.testclient import TestClient

from app import __version__
from app.main import create_app


def test_health_responde_ok_con_la_version() -> None:
    cliente = TestClient(create_app())

    respuesta = cliente.get("/health")

    assert respuesta.status_code == 200
    assert respuesta.json()["status"] == "ok"
    assert respuesta.json()["version"] == __version__
