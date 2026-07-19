"""Adapter for the Vodafone AU Arcadyan 5G FWA modem.

Two firmware families live in the wild and reshape the login handshake:

  * "form"    — POST to `/login` with a nonce-salted password, session
                is a `sessionID` cookie, metrics are HTML or CGI JSON.
  * "jsonrpc" — POST to `/JRD/webapi` with JSON envelopes; auth returns
                a token that goes back as a header on every call.

`ArcadyanAdapter._authenticate()` tries them in order and remembers what
worked. When the session is rejected mid-poll the adapter drops it and
re-probes, so a firmware upgrade under a running backend is survivable.

The metric parsers are intentionally forgiving: unknown keys are skipped,
and any single missing metric leaves the field `None` in the snapshot
instead of blowing up the whole read.
"""

from __future__ import annotations

import hashlib
import logging
import re
from typing import Any, Optional

import httpx
from bs4 import BeautifulSoup

from ..models import ModemStatus, SignalSnapshot
from .base import ModemAdapter, ModemAuthError, ModemParseError, ModemUnreachableError

log = logging.getLogger(__name__)


# Metrics can arrive as "-88 dBm", "-88.0", or plain "-88"; strip units.
_NUM_RE = re.compile(r"-?\d+(?:\.\d+)?")


def _to_float(raw: Any) -> Optional[float]:
    if raw is None:
        return None
    if isinstance(raw, (int, float)):
        return float(raw)
    m = _NUM_RE.search(str(raw))
    return float(m.group()) if m else None


def _to_str(raw: Any) -> Optional[str]:
    if raw is None:
        return None
    s = str(raw).strip()
    return s or None


class ArcadyanAdapter(ModemAdapter):
    """Talk to the Vodafone AU Arcadyan 5G FWA modem over LAN."""

    def __init__(
        self,
        *,
        host: str,
        username: str,
        password: str,
        timeout_s: float = 3.0,
        client: Optional[httpx.AsyncClient] = None,
    ) -> None:
        self._host = host.rstrip("/")
        self._username = username
        self._password = password
        self._base_url = f"http://{self._host}"
        self._client = client or httpx.AsyncClient(
            base_url=self._base_url,
            timeout=timeout_s,
            follow_redirects=True,
            headers={"User-Agent": "signal-helper/0.1 (+local)"},
        )
        self._owns_client = client is None
        self._authed = False
        self._token: Optional[str] = None
        self._last_error: Optional[str] = None
        self._last_snapshot: Optional[SignalSnapshot] = None
        self.firmware_mode: Optional[str] = None

    async def close(self) -> None:
        if self._owns_client:
            await self._client.aclose()

    # ---- public API ------------------------------------------------------

    async def read_snapshot(self) -> SignalSnapshot:
        try:
            if not self._authed:
                await self._authenticate()
            try:
                snap = await self._fetch_metrics()
            except ModemAuthError:
                # Session died — retry once with a fresh handshake.
                self._authed = False
                self._token = None
                await self._authenticate()
                snap = await self._fetch_metrics()
        except httpx.HTTPError as exc:
            self._last_error = f"{type(exc).__name__}: {exc}"
            raise ModemUnreachableError(self._last_error) from exc

        self._last_error = None
        self._last_snapshot = snap
        return snap

    async def status(self) -> ModemStatus:
        return ModemStatus(
            reachable=self._last_error is None or self._authed,
            authenticated=self._authed,
            last_error=self._last_error,
            firmware_mode=self.firmware_mode,
            last_snapshot_at=self._last_snapshot.taken_at if self._last_snapshot else None,
        )

    # ---- auth ------------------------------------------------------------

    async def _authenticate(self) -> None:
        """Probe both handshakes and stick with whichever succeeds."""
        errors: list[str] = []
        for mode, fn in (("form", self._auth_form), ("jsonrpc", self._auth_jsonrpc)):
            try:
                await fn()
                self.firmware_mode = mode
                self._authed = True
                log.info("arcadyan: authenticated via %s handshake", mode)
                return
            except ModemAuthError:
                # Explicit credential rejection: don't fall through to
                # the other mode — the same password is being tried, and
                # a fallthrough would just confuse the operator.
                self._authed = False
                raise
            except (ModemUnreachableError, ModemParseError, httpx.HTTPError) as exc:
                errors.append(f"{mode}: {type(exc).__name__}: {exc}")
                continue
        raise ModemUnreachableError(
            "no known Arcadyan handshake succeeded; tried: " + " | ".join(errors)
        )

    async def _auth_form(self) -> None:
        """Older firmware: form-login + sessionID cookie."""
        landing = await self._client.get("/")
        if landing.status_code >= 500:
            raise ModemUnreachableError(f"landing page returned {landing.status_code}")

        nonce = self._scrape_nonce(landing.text)
        csrf = self._scrape_csrf(landing.text)
        pw_field = self._hash_password(self._password, nonce)

        payload = {"username": self._username, "password": pw_field}
        if csrf:
            payload["csrf_token"] = csrf

        # Two known endpoint names — try the CGI one first, the plain one second.
        for path in ("/cgi-bin/login", "/login"):
            resp = await self._client.post(path, data=payload)
            if resp.status_code == 404:
                continue
            if resp.status_code in (401, 403):
                raise ModemAuthError(f"form-login rejected credentials at {path}")
            if resp.status_code >= 400:
                # unrecoverable for this mode, let the outer probe try the next
                raise ModemParseError(f"form-login {path} → HTTP {resp.status_code}")
            # Success is signaled by a fresh session cookie or a redirect.
            if any(c.name.lower() in {"sessionid", "sid"} for c in self._client.cookies.jar):
                return
            if resp.headers.get("location", "").endswith("/status") or resp.status_code == 302:
                return
            # Some builds embed {"result":"ok"} in the body.
            body = resp.text.lower()
            if '"ok"' in body or '"success":true' in body:
                return
            raise ModemParseError(f"form-login {path} returned unexpected body")
        raise ModemUnreachableError("no form-login endpoint accepted the request")

    async def _auth_jsonrpc(self) -> None:
        """Newer firmware: JSON-RPC over /JRD/webapi (or /cgi-bin/luci)."""
        for path in ("/JRD/webapi", "/cgi-bin/luci/;stok=/api/auth"):
            body = {
                "jsonrpc": "2.0",
                "id": 1,
                "method": "login",
                "params": {"username": self._username, "password": self._password},
            }
            resp = await self._client.post(path, json=body)
            if resp.status_code == 404:
                continue
            if resp.status_code in (401, 403):
                raise ModemAuthError(f"jsonrpc rejected credentials at {path}")
            if resp.status_code >= 400:
                raise ModemParseError(f"jsonrpc {path} → HTTP {resp.status_code}")

            try:
                data = resp.json()
            except ValueError as exc:
                raise ModemParseError(f"jsonrpc {path}: body was not JSON") from exc

            token = (
                data.get("result", {}).get("token")
                if isinstance(data.get("result"), dict)
                else data.get("token")
            )
            if not token:
                # Some firmwares put a code in "error"
                err = data.get("error") or data.get("result", {}).get("error")
                if err in ("wrong_password", -1001):
                    raise ModemAuthError(f"jsonrpc {path}: credentials rejected")
                raise ModemParseError(f"jsonrpc {path}: no token in response")
            self._token = token
            self._client.headers["Authorization"] = f"Bearer {token}"
            return
        raise ModemUnreachableError("no jsonrpc endpoint accepted the request")

    # ---- metrics ---------------------------------------------------------

    async def _fetch_metrics(self) -> SignalSnapshot:
        if self.firmware_mode == "form":
            return await self._fetch_metrics_form()
        if self.firmware_mode == "jsonrpc":
            return await self._fetch_metrics_jsonrpc()
        raise ModemParseError("no firmware_mode set — was _authenticate() skipped?")

    async def _fetch_metrics_form(self) -> SignalSnapshot:
        """Try the CGI JSON endpoint first, fall back to the status page."""
        for path in (
            "/cgi-bin/qcmap_web_cgi?Page=Status_5G",
            "/cgi-bin/status_5g",
            "/cgi-bin/status_lte",
        ):
            resp = await self._client.get(path)
            if resp.status_code in (401, 403):
                raise ModemAuthError(f"session expired hitting {path}")
            if resp.status_code == 404:
                continue
            if resp.status_code >= 400:
                continue

            ctype = resp.headers.get("content-type", "").lower()
            if "json" in ctype:
                return self._parse_form_json(resp.json())
            return self._parse_status_html(resp.text)

        raise ModemParseError("no known form-mode status endpoint responded")

    async def _fetch_metrics_jsonrpc(self) -> SignalSnapshot:
        for method in ("GetNetworkInfo", "GetSignalInfo", "GetCellInfo"):
            body = {"jsonrpc": "2.0", "id": 1, "method": method, "params": {}}
            resp = await self._client.post("/JRD/webapi", json=body)
            if resp.status_code in (401, 403):
                raise ModemAuthError(f"session expired calling {method}")
            if resp.status_code >= 400:
                continue
            try:
                data = resp.json()
            except ValueError:
                continue
            result = data.get("result") or {}
            if result:
                return self._parse_jsonrpc(result)
        raise ModemParseError("no JSON-RPC status method returned a usable result")

    # ---- parsers ---------------------------------------------------------

    @staticmethod
    def _scrape_nonce(html: str) -> str:
        soup = BeautifulSoup(html, "html.parser")
        for name in ("nonce", "loginNonce", "csrf_nonce", "salt"):
            el = soup.find("input", attrs={"name": name})
            if el and el.get("value"):
                return str(el["value"])
        # Some builds embed it as `var nonce = "…"` in a <script>.
        m = re.search(r"""(?:nonce|salt)\s*[:=]\s*["']([A-Za-z0-9+/=_-]+)["']""", html)
        return m.group(1) if m else ""

    @staticmethod
    def _scrape_csrf(html: str) -> str:
        soup = BeautifulSoup(html, "html.parser")
        el = soup.find("input", attrs={"name": re.compile("csrf", re.I)})
        return str(el["value"]) if el and el.get("value") else ""

    @staticmethod
    def _hash_password(password: str, nonce: str) -> str:
        if not nonce:
            return password
        return hashlib.sha256(f"{password}{nonce}".encode("utf-8")).hexdigest()

    def _parse_form_json(self, payload: dict[str, Any]) -> SignalSnapshot:
        # Vodafone AU CGI keys observed in the wild; unknown → None, don't fail.
        get = payload.get
        return SignalSnapshot(
            rsrp=_to_float(get("RSRP") or get("rsrp") or get("nr5g_rsrp")),
            rsrq=_to_float(get("RSRQ") or get("rsrq") or get("nr5g_rsrq")),
            sinr=_to_float(get("SINR") or get("sinr") or get("nr5g_sinr")),
            cell_id=_to_str(get("CellID") or get("cell_id") or get("nr5g_cell_id")),
            band=_to_str(get("Band") or get("band") or get("nr5g_band")),
            tac=_to_str(get("TAC") or get("tac")),
            plmn=_to_str(get("PLMN") or get("plmn") or get("mcc_mnc")),
            connected=str(get("Status") or get("status") or "").lower() in {"connected", "up", "registered"},
        )

    def _parse_status_html(self, html: str) -> SignalSnapshot:
        soup = BeautifulSoup(html, "html.parser")

        def field(*labels: str) -> Optional[str]:
            for label in labels:
                el = soup.find(id=label) or soup.find(attrs={"data-field": label})
                if el and el.get_text(strip=True):
                    return el.get_text(strip=True)
                # Two-column table row: <th>RSRP</th><td>-88 dBm</td>
                th = soup.find("th", string=re.compile(rf"^\s*{re.escape(label)}\s*$", re.I))
                if th and th.find_next_sibling("td"):
                    return th.find_next_sibling("td").get_text(strip=True)
            return None

        return SignalSnapshot(
            rsrp=_to_float(field("RSRP", "rsrp", "nr5g-rsrp")),
            rsrq=_to_float(field("RSRQ", "rsrq", "nr5g-rsrq")),
            sinr=_to_float(field("SINR", "sinr", "nr5g-sinr")),
            cell_id=_to_str(field("Cell ID", "CellID", "cell-id")),
            band=_to_str(field("Band", "band")),
            tac=_to_str(field("TAC", "tac")),
            plmn=_to_str(field("PLMN", "plmn")),
            connected=(field("Status", "status") or "").lower() in {"connected", "up", "registered"},
        )

    def _parse_jsonrpc(self, result: dict[str, Any]) -> SignalSnapshot:
        # JRD firmwares tuck the interesting fields under nested objects.
        nr = result.get("nr5g") or result.get("NR5G") or {}
        cell = result.get("cell") or result.get("Cell") or {}
        merged = {**result, **nr, **cell}
        return SignalSnapshot(
            rsrp=_to_float(merged.get("rsrp") or merged.get("RSRP")),
            rsrq=_to_float(merged.get("rsrq") or merged.get("RSRQ")),
            sinr=_to_float(merged.get("sinr") or merged.get("SINR")),
            cell_id=_to_str(merged.get("cellId") or merged.get("cell_id") or merged.get("pci")),
            band=_to_str(merged.get("band")),
            tac=_to_str(merged.get("tac")),
            plmn=_to_str(merged.get("plmn") or merged.get("mccMnc")),
            connected=str(merged.get("status") or "").lower() in {"connected", "up", "registered"},
        )
