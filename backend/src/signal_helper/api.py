"""FastAPI surface + PWA host.

  GET /               → the PWA shell (index.html)
  GET /api/signal     → latest SignalSnapshot (one-shot)
  GET /api/signal/stream → SSE, one event per poll tick (~1 Hz)
  GET /api/health     → ModemStatus

The whole app is served from one origin so CORS isn't an issue and the
PWA can register its service worker cleanly.
"""

from __future__ import annotations

import json
import logging
from contextlib import asynccontextmanager
from pathlib import Path

from fastapi import FastAPI, HTTPException, Request
from fastapi.responses import StreamingResponse
from fastapi.staticfiles import StaticFiles

from .config import Settings
from .modem import ModemAdapter, ModemAuthError, ModemError, ModemUnreachableError
from .modem.arcadyan import ArcadyanAdapter
from .modem.mock import MockAdapter
from .models import ModemStatus, SignalSnapshot
from .poller import BroadcastPoller

log = logging.getLogger(__name__)

_STATIC_DIR = Path(__file__).parent / "static"


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
    poller = BroadcastPoller(adapter, interval_s=settings.poll_interval_s)
    await poller.start()
    app.state.adapter = adapter
    app.state.poller = poller
    app.state.settings = settings
    try:
        yield
    finally:
        await poller.stop()
        await adapter.close()


app = FastAPI(title="5G Signal Helper", version="0.1.0", lifespan=lifespan)


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


@app.get("/api/signal/stream")
async def stream_signal(request: Request) -> StreamingResponse:
    poller: BroadcastPoller = app.state.poller

    async def event_source():
        # Nudge some proxies to flush immediately.
        yield ": stream opened\n\n"
        async for item in poller.subscribe():
            if await request.is_disconnected():
                break
            if isinstance(item, ModemError):
                payload = {"error": str(item), "type": type(item).__name__}
                yield f"event: modem_error\ndata: {json.dumps(payload)}\n\n"
            else:
                yield f"data: {item.model_dump_json()}\n\n"

    return StreamingResponse(
        event_source(),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache, no-transform",
            "X-Accel-Buffering": "no",
            "Connection": "keep-alive",
        },
    )


# Static PWA shell — mount LAST so /api/* wins.
if _STATIC_DIR.is_dir():
    app.mount("/", StaticFiles(directory=_STATIC_DIR, html=True), name="pwa")
