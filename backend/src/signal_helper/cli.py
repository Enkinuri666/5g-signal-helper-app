"""Command-line entry point.

Two commands, both useful before the UI exists:

    signal-helper probe   # one-shot read, prints the snapshot
    signal-helper serve   # runs the API

`probe` is the PoC the architecture doc calls for: it lets an operator
confirm the modem answers, credentials work, and metrics parse — without
needing a browser open.
"""

from __future__ import annotations

import asyncio
import json
import logging
import os
from typing import Optional

import typer

from .config import Settings
from .modem import ModemAdapter, ModemAuthError, ModemUnreachableError
from .modem.arcadyan import ArcadyanAdapter
from .modem.mock import MockAdapter

app = typer.Typer(add_completion=False, no_args_is_help=True)


def _build_adapter(settings: Settings) -> ModemAdapter:
    if settings.use_mock_adapter:
        return MockAdapter()
    if not settings.modem_password:
        typer.echo(
            "MODEM_PASSWORD is not set. Export it or pass --password. "
            "Set USE_MOCK_ADAPTER=1 for offline dev.",
            err=True,
        )
        raise typer.Exit(code=2)
    return ArcadyanAdapter(
        host=settings.modem_host,
        username=settings.modem_username,
        password=settings.modem_password,
        timeout_s=settings.request_timeout_s,
    )


@app.command()
def probe(
    host: Optional[str] = typer.Option(None, help="Modem IP; defaults to $MODEM_HOST or 192.168.1.1"),
    username: Optional[str] = typer.Option(None, help="Modem username; defaults to $MODEM_USERNAME"),
    password: Optional[str] = typer.Option(None, help="Modem password; defaults to $MODEM_PASSWORD"),
    mock: bool = typer.Option(False, "--mock", help="Use the fixture adapter, don't touch the network"),
    verbose: bool = typer.Option(False, "--verbose", "-v", help="Enable debug logging"),
) -> None:
    """One-shot read of the modem. Prints the snapshot as JSON."""
    logging.basicConfig(level=logging.DEBUG if verbose else logging.INFO, format="%(message)s")
    if host:
        os.environ["MODEM_HOST"] = host
    if username:
        os.environ["MODEM_USERNAME"] = username
    if password:
        os.environ["MODEM_PASSWORD"] = password
    if mock:
        os.environ["USE_MOCK_ADAPTER"] = "1"

    settings = Settings.from_env()

    async def _run() -> int:
        adapter = _build_adapter(settings)
        try:
            snap = await adapter.read_snapshot()
            typer.echo(snap.model_dump_json(indent=2))
            return 0
        except ModemAuthError as exc:
            typer.echo(f"AUTH FAILURE: {exc}", err=True)
            return 3
        except ModemUnreachableError as exc:
            typer.echo(f"UNREACHABLE: {exc}", err=True)
            return 4
        finally:
            await adapter.close()

    raise typer.Exit(code=asyncio.run(_run()))


@app.command()
def serve(
    host: str = typer.Option("0.0.0.0", help="Interface to bind"),
    port: int = typer.Option(8765, help="Port"),
    reload: bool = typer.Option(False, help="uvicorn --reload"),
) -> None:
    """Run the FastAPI backend."""
    import uvicorn

    uvicorn.run("signal_helper.api:app", host=host, port=port, reload=reload)


if __name__ == "__main__":
    app()
