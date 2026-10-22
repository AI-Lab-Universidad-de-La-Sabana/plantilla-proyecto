import pytest
from pydantic import ValidationError

from app.config import Settings


def test_lee_la_configuracion_de_variables_de_entorno(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setenv("APP_ENV", "staging")

    settings = Settings(_env_file=None)  # type: ignore[call-arg]

    assert settings.app_env == "staging"


def test_rechaza_un_valor_invalido_al_arrancar(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setenv("APP_ENV", "pruebas")

    with pytest.raises(ValidationError):
        Settings(_env_file=None)  # type: ignore[call-arg]
