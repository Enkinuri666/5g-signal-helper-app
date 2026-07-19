"""Command-line entry point.

    signal-helper probe   # one-shot read, prints the snapshot
    signal-helper serve   # runs the API (add --tls for HTTPS)
    signal-helper cert    # mints a self-signed TLS cert for LAN HTTPS

`probe` is the PoC the architecture doc calls for: it lets an operator
confirm the modem answers, credentials work, and metrics parse — without
needing a browser open.
"""

from __future__ import annotations

import asyncio
import logging
import os
from pathlib import Path
from typing import Optional

import typer

from .config import Settings
from .modem import ModemAdapter, ModemAuthError, ModemUnreachableError
from .modem.arcadyan import ArcadyanAdapter
from .modem.mock import MockAdapter
from .tls import (
    DEFAULT_CERT_PATH,
    DEFAULT_KEY_PATH,
    collect_default_sans,
    generate_self_signed,
)

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
    tls: bool = typer.Option(
        False,
        "--tls",
        help=f"Serve HTTPS using the default cert at {DEFAULT_CERT_PATH}. "
        "Run `signal-helper cert` first to mint one.",
    ),
    tls_cert: Optional[Path] = typer.Option(
        None, "--tls-cert", help="Path to a TLS certificate (overrides --tls)."
    ),
    tls_key: Optional[Path] = typer.Option(
        None, "--tls-key", help="Path to a TLS private key (overrides --tls)."
    ),
) -> None:
    """Run the FastAPI backend.

    Sensor APIs the PWA depends on (DeviceOrientation, geolocation,
    service worker install) require a secure origin. For LAN access from
    a phone, run `signal-helper cert` once and start the backend with
    `--tls`.
    """
    import uvicorn

    cert_path, key_path = _resolve_tls_paths(tls, tls_cert, tls_key)

    if cert_path and key_path:
        scheme = "https"
        ssl_kwargs = {"ssl_certfile": str(cert_path), "ssl_keyfile": str(key_path)}
    elif tls or tls_cert or tls_key:
        typer.echo(
            "TLS requested but no usable cert found. Run `signal-helper cert` "
            "or pass --tls-cert and --tls-key together.",
            err=True,
        )
        raise typer.Exit(code=2)
    else:
        scheme = "http"
        ssl_kwargs = {}
        typer.echo(
            "Note: serving HTTP. The PWA's sensors won't work over the LAN "
            "until you run `signal-helper cert` and restart with --tls.",
            err=True,
        )

    typer.echo(f"listening on {scheme}://{host}:{port}", err=True)
    uvicorn.run("signal_helper.api:app", host=host, port=port, reload=reload, **ssl_kwargs)


def _resolve_tls_paths(
    tls: bool, tls_cert: Optional[Path], tls_key: Optional[Path]
) -> tuple[Optional[Path], Optional[Path]]:
    """Explicit --tls-cert/--tls-key win; --tls falls back to the default pair."""
    if tls_cert and tls_key:
        return tls_cert, tls_key
    if tls_cert or tls_key:
        return None, None  # partial pair — caller reports the error
    if tls and DEFAULT_CERT_PATH.exists() and DEFAULT_KEY_PATH.exists():
        return DEFAULT_CERT_PATH, DEFAULT_KEY_PATH
    return None, None


@app.command()
def cert(
    san: list[str] = typer.Option(
        [],
        "--san",
        help="Extra hostnames or IPs to embed. Pass once per SAN "
        "(e.g. --san 192.168.1.50 --san modem.local). "
        "127.0.0.1, localhost, and the auto-detected LAN IP are always included.",
    ),
    cert_path: Path = typer.Option(DEFAULT_CERT_PATH, "--cert-path"),
    key_path: Path = typer.Option(DEFAULT_KEY_PATH, "--key-path"),
    days: int = typer.Option(365, help="How long the cert is valid for."),
    force: bool = typer.Option(False, "--force", help="Overwrite an existing cert without prompting."),
) -> None:
    """Mint a self-signed TLS cert for LAN HTTPS.

    The cert's Subject Alternative Names must include whatever address
    the phone types into the browser — an IP (e.g. `https://192.168.1.50:8765`)
    or a hostname (e.g. `https://modem.local:8765`). Anything not in the
    SAN list will trigger `NET::ERR_CERT_COMMON_NAME_INVALID`.
    """
    if not force and cert_path.exists():
        typer.confirm(
            f"{cert_path} already exists. Overwrite?", abort=True, default=False
        )

    sans = collect_default_sans(san)
    result = generate_self_signed(sans, cert_path=cert_path, key_path=key_path, days_valid=days)

    typer.echo(f"cert : {result.cert_path}")
    typer.echo(f"key  : {result.key_path}")
    typer.echo(f"SANs : {', '.join(result.subject_alt_names)}")
    typer.echo(f"valid: until {result.not_after.isoformat()}")
    typer.echo("")
    typer.echo(
        "Next: `signal-helper serve --tls`. On first visit the phone will show "
        "'your connection is not private' — tap 'Advanced → proceed'. Sensor "
        "APIs will then work over the LAN."
    )


if __name__ == "__main__":
    app()
