# 5g-signal-helper-app

Live **5G Alignment Compass** for the Vodafone Australia Arcadyan 5G FWA
modem. Runs on your LAN, reads the modem's own radio metrics (RSRP, RSRQ,
SINR, Cell ID), and overlays them on a compass driven by the phone's
magnetometer and GPS — so you can physically rotate the modem toward the
strongest cell without guessing from a stock browser UI.

See [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) for the full design,
the local-first security posture, and the Archer BE500 routing notes.

## Status

This is the **initial architecture + data-acquisition PoC** slice.

- ✅ Modem adapter interface (`ModemAdapter`) and mock fixtures
- ✅ Arcadyan adapter with two firmware handshakes (form + JSON-RPC)
- ✅ `signal-helper probe` CLI to verify credentials and parse metrics
- ✅ FastAPI backend serving `/api/signal` and `/api/health`
- ⏳ PWA compass UI (next slice)
- ⏳ SSE stream for sub-second updates (next slice)

## Quick start

```bash
cd backend
python -m venv .venv && source .venv/bin/activate
pip install -e '.[dev]'

# Offline dry run — talks to a fixture, not the modem.
signal-helper probe --mock

# Real modem — set the password first.
export MODEM_PASSWORD='...'
signal-helper probe

# Run the API (LAN-only).
signal-helper serve --host 0.0.0.0 --port 8765
```

## Layout

```
docs/
  ARCHITECTURE.md          # the design + the Arcadyan auth plan
backend/
  src/signal_helper/
    modem/                 # swappable adapters (Arcadyan + Mock)
    models.py              # SignalSnapshot, ModemStatus
    config.py              # env-driven Settings
    cli.py                 # `signal-helper probe|serve`
    api.py                 # FastAPI app
  tests/                   # respx-based adapter tests
```
