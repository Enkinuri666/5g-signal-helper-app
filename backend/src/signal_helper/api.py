"""FastAPI surface.

Endpoints are read-only and require no auth — the whole app runs on the
LAN and CORS is scoped narrowly. Modem credentials never leave here.

  GET /api/signal   → latest SignalSnapshot
  GET /api/health   → ModemStatus
"""

from __future__ import annotations

import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware

from .config import Settings
from .modem import ModemAdapter, ModemAuthError, ModemUnreachableError
from .modem.arcadyan import ArcadyanAdapter
from .modem.mock import MockAdapter
from .models import ModemStatus, SignalSnapshot

log = logging.getLogger(__name__)


def _build_adapter(settings: Settings) -> ModemAdapter:
    if settings.use_mock_adapter or not settings.modem_password:
        if not settings.use_mock_adapter:
            log.warning("MODEM_PASSWORD unset — falling back to MockAdapter for safety.")
        return MockAdapter()
    return ArcadyanAdapter(
        host=settings.modem_host,
        username=settings.modem_username,
        password=settings.modem_password,
        timeout_s=settings.request_timeout_s,
    )


@asynccontextmanager
async def lifespan(app: FastAPI):
    settings = Settings.from_env()
    adapter = _build_adapter(settings)
    app.state.adapter = adapter
    app.state.settings = settings
    try:
        yield
    finally:
        await adapter.close()


app = FastAPI(title="5G Signal Helper", version="0.1.0", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # LAN-only server; PWA is served from the same origin in the next phase.
    allow_methods=["GET"],
    allow_headers=["*"],
)


@app.get("/api/signal", response_model=SignalSnapshot)
async def get_signal() -> SignalSnapshot:
    adapter: ModemAdapter = app.state.adapter
    try:
        return await adapter.read_snapshot()
    except ModemAuthError as exc:
        raise HTTPException(status_code=502, detail=f"modem auth failed: {exc}") from exc
    except ModemUnreachableError as exc:
        raise HTTPException(status_code=504, detail=f"modem unreachable: {exc}") from exc


@app.get("/api/health", response_model=ModemStatus)
async def get_health() -> ModemStatus:
    adapter: ModemAdapter = app.state.adapter
    return await adapter.status()
