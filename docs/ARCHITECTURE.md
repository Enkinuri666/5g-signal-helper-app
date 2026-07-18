# 5G Signal Alignment Tool — Architecture

## Goal

A live "5G Alignment Compass" that overlays the modem's real radio metrics
(RSRP, RSRQ, SINR, Cell ID) on a compass driven by the phone's own sensors,
so the modem can be physically rotated toward the strongest cell.

## Constraints

- **Local-first.** Never send modem credentials or radio telemetry off the LAN.
- **Firmware-tolerant.** The Arcadyan web UI reshapes between builds; the
  scraping layer must be swappable without touching the UI or compass code.
- **Ignore phone cellular.** All signal metrics come from the modem's radio,
  never `navigator.connection` / Android telephony.
- **Mobile-first UI.** Optimized for a phone held next to the modem while
  it's being rotated.

## Layered design

```
┌────────────────────────────────────────────────────────────────┐
│  PWA (frontend/)                                               │
│    Compass canvas · Sensor bridge (DeviceOrientation + GPS)    │
│    Bearing math   · Metric overlay (RSRP/RSRQ/SINR + Cell ID)  │
└───────────────────────────┬────────────────────────────────────┘
                            │  HTTP(S) on LAN, JSON, SSE stream
┌───────────────────────────▼────────────────────────────────────┐
│  Backend API (FastAPI, backend/)                               │
│    /api/signal          latest SignalSnapshot                  │
│    /api/signal/stream   SSE, ~1 Hz push                        │
│    /api/health          adapter status + last error            │
└───────────────────────────┬────────────────────────────────────┘
                            │
┌───────────────────────────▼────────────────────────────────────┐
│  ModemAdapter (backend/src/signal_helper/modem/)               │
│    base.ModemAdapter        abstract interface                 │
│    arcadyan.ArcadyanAdapter Vodafone AU 5G FWA                 │
│    mock.MockAdapter         fixtures for offline dev           │
└────────────────────────────────────────────────────────────────┘
```

The adapter is the only piece that knows about a specific modem. Everything
above it consumes a stable `SignalSnapshot` dataclass, so a firmware bump
that renames a JSON field only touches the adapter's parser.

## Data flow

1. Backend runs on a device on the modem's LAN (laptop, Pi, or the modem's
   own USB host if available).
2. A poller inside the backend calls `adapter.read_snapshot()` every ~1 s.
3. Each snapshot is cached in-memory and pushed to any connected SSE clients.
4. The PWA renders the compass at 60 fps from sensor data locally, and
   overlays the last snapshot at whatever cadence the SSE stream delivers.

Decoupling the poll loop from the render loop keeps the compass smooth
even if the modem is slow to respond.

## Orientation engine (frontend, next phase)

- `DeviceOrientationEvent` gives heading (`webkitCompassHeading` on iOS,
  `alpha` corrected for screen orientation on Android).
- `navigator.geolocation.watchPosition` gives current lat/lon.
- User enters tower lat/lon in Settings, persisted in `localStorage`.
- Target bearing = `atan2(sin(Δλ)·cos(φ₂), cos(φ₁)·sin(φ₂) − sin(φ₁)·cos(φ₂)·cos(Δλ))`
  (forward azimuth on the WGS-84 sphere; good enough for FWA).
- Compass renders: cardinal ring, phone heading (fixed at top), a marker at
  `targetBearing − phoneHeading`, and an RSRP/SINR gauge that colors green
  as the marker approaches 0°.

## Local-first & security

- Backend binds to the LAN interface only; no cloud dependency, no telemetry.
- Modem password is read from an env var / `.env`, never from a query string.
- CORS is limited to `http://<lan-ip>:<port>`.
- The PWA is served by the same backend so there's no cross-origin surface.

## Router (Archer BE500) considerations

If the phone can't reach `192.168.1.1` directly because the BE500 is doing
NAT on top of the modem, two options:

1. **AP mode on the BE500** (recommended). The modem stays the DHCP server
   and the phone lands on the modem's subnet, so `192.168.1.1` is reachable.
2. **Static route on the BE500**: add `192.168.1.0/24 → <modem-LAN-IP>` and
   turn off SIP-ALG / DNS rebind protection for that range. Keeps double-NAT
   but exposes the modem UI to LAN clients.

The backend doesn't need `192.168.1.1` from the phone — only from wherever
it runs. If the backend runs on a device already on the modem's subnet
(e.g. a Pi wired into the modem's LAN port before the BE500), the phone
only needs to reach the *backend*, which the BE500 can route to fine.

## Arcadyan authentication — plan

The exact handshake for the Vodafone AU Arcadyan 5G FWA isn't publicly
documented, and there are at least two firmware families in the wild.
The adapter probes both, in order, and remembers what worked:

### Mode A — form-login + session cookie (older firmwares)

1. `GET /` → scrape a CSRF token / nonce from a hidden `<input>` or
   `Set-Cookie`.
2. `POST /login` (or `/cgi-bin/login`) with
   `username=<user>&password=<sha256(password + nonce)>&csrf=<token>`.
3. Server sets `sessionID` (or `SID`) cookie.
4. Metric endpoints, typically:
   - `GET /cgi-bin/status_lte` or `/status_5g` → HTML, scrape with a parser.
   - `GET /cgi-bin/qcmap_web_cgi?Page=Status_5G` → JSON.

### Mode B — JSON-RPC (newer firmwares)

1. `POST /cgi-bin/luci/;stok=/api/auth` or `/JRD/webapi` with
   `{"method":"login","params":{"username":"admin","password":"…"}}`.
2. Response includes a `token`; subsequent calls carry it as either a
   header (`Authorization: Bearer …`) or a query string (`;stok=<token>`).
3. `POST /JRD/webapi` with
   `{"method":"GetNetworkInfo"}` / `GetSignalInfo` / `GetCellInfo`.

Both modes are implemented as small strategy objects behind
`ArcadyanAdapter._authenticate()`. Whichever succeeds first is cached
until the session dies (401/403), at which point the adapter re-probes.

### What we scrape

The adapter normalizes into `SignalSnapshot`:

| Field       | Type   | Unit  | Source (typical)                    |
|-------------|--------|-------|-------------------------------------|
| rsrp        | float  | dBm   | 5G NR primary                       |
| rsrq        | float  | dB    | 5G NR primary                       |
| sinr        | float  | dB    | 5G NR primary                       |
| cell_id     | str    | —     | NR PCI or gNB cell identity         |
| band        | str    | —     | e.g. "n78"                          |
| tac         | str    | —     | Tracking area code                  |
| plmn        | str    | —     | Public Land Mobile Network id       |
| connected   | bool   | —     | true iff radio state is "connected" |
| taken_at    | datetime | UTC | when the snapshot was read          |

Unknown fields are left `None` — the UI degrades gracefully.

## Error handling

- Every network call is wrapped in a bounded retry (2 attempts, 250 ms).
- Auth failure raises `ModemAuthError`; the API surfaces it as 502 with a
  human-readable message and the poller backs off to 5 s until it clears.
- Parser failures raise `ModemParseError` with the raw payload elided of
  credentials, logged locally only.
- The PWA shows "Modem unreachable" and freezes the last-known snapshot
  rather than blanking the gauge — better UX while walking around.

## Roadmap

- [x] Architecture doc, adapter interface, mock adapter, probe CLI.
- [ ] Arcadyan Mode A + Mode B handshake, verified against a real unit.
- [ ] FastAPI `/api/signal` + SSE stream.
- [ ] PWA compass (sensor bridge + bearing math + gauge overlay).
- [ ] Persisted history for post-alignment review.
