"""Adapter tests use respx to stand in for the modem HTTP surface."""

from __future__ import annotations

import httpx
import pytest
import respx

from signal_helper.modem import ModemAuthError, ModemUnreachableError
from signal_helper.modem.arcadyan import ArcadyanAdapter


HOST = "192.168.1.1"
BASE = f"http://{HOST}"


@pytest.fixture
def adapter() -> ArcadyanAdapter:
    return ArcadyanAdapter(host=HOST, username="admin", password="secret")


@pytest.mark.asyncio
async def test_form_login_and_cgi_json_metrics(adapter: ArcadyanAdapter) -> None:
    with respx.mock(base_url=BASE, assert_all_called=False) as router:
        router.get("/").respond(
            200,
            text="<html><input name='nonce' value='abc123'/><input name='csrf_token' value='tok'/></html>",
        )
        router.post("/cgi-bin/login").respond(
            200,
            headers={"set-cookie": "sessionID=deadbeef; Path=/"},
            json={"result": "ok"},
        )
        router.get("/cgi-bin/qcmap_web_cgi", params={"Page": "Status_5G"}).respond(
            200,
            json={
                "RSRP": "-88 dBm",
                "RSRQ": "-10.5",
                "SINR": 14,
                "CellID": "0x0A1B2C",
                "Band": "n78",
                "TAC": "1A2B",
                "PLMN": "50503",
                "Status": "Connected",
            },
        )

        snap = await adapter.read_snapshot()

    assert adapter.firmware_mode == "form"
    assert snap.rsrp == -88.0
    assert snap.rsrq == -10.5
    assert snap.sinr == 14.0
    assert snap.cell_id == "0x0A1B2C"
    assert snap.band == "n78"
    assert snap.connected is True


@pytest.mark.asyncio
async def test_jsonrpc_login_and_metrics_when_form_unavailable(adapter: ArcadyanAdapter) -> None:
    with respx.mock(base_url=BASE, assert_all_called=False) as router:
        router.get("/").respond(200, text="<html></html>")
        router.post("/cgi-bin/login").respond(404)
        router.post("/login").respond(404)
        router.post("/JRD/webapi").mock(
            side_effect=[
                httpx.Response(200, json={"result": {"token": "tk-xyz"}}),
                httpx.Response(
                    200,
                    json={
                        "result": {
                            "nr5g": {
                                "rsrp": -92,
                                "rsrq": -11,
                                "sinr": 9.5,
                                "cellId": "42",
                                "band": "n78",
                            },
                            "status": "connected",
                        }
                    },
                ),
            ]
        )

        snap = await adapter.read_snapshot()

    assert adapter.firmware_mode == "jsonrpc"
    assert snap.rsrp == -92.0
    assert snap.sinr == 9.5
    assert snap.cell_id == "42"
    assert snap.connected is True


@pytest.mark.asyncio
async def test_bad_password_surfaces_as_auth_error(adapter: ArcadyanAdapter) -> None:
    with respx.mock(base_url=BASE, assert_all_called=False) as router:
        router.get("/").respond(200, text="<html><input name='nonce' value='n'/></html>")
        router.post("/cgi-bin/login").respond(401, text="nope")

        with pytest.raises(ModemAuthError):
            await adapter.read_snapshot()


@pytest.mark.asyncio
async def test_network_error_surfaces_as_unreachable(adapter: ArcadyanAdapter) -> None:
    with respx.mock(base_url=BASE, assert_all_called=False) as router:
        router.get("/").mock(side_effect=httpx.ConnectError("no route to host"))
        router.post("/JRD/webapi").mock(side_effect=httpx.ConnectError("no route to host"))
        router.post("/cgi-bin/luci/;stok=/api/auth").mock(side_effect=httpx.ConnectError("no route"))

        with pytest.raises(ModemUnreachableError):
            await adapter.read_snapshot()


@pytest.mark.asyncio
async def test_html_status_page_fallback_parses_table_rows(adapter: ArcadyanAdapter) -> None:
    html = """
    <html><body><table>
      <tr><th>RSRP</th><td>-95 dBm</td></tr>
      <tr><th>RSRQ</th><td>-12 dB</td></tr>
      <tr><th>SINR</th><td>7</td></tr>
      <tr><th>Cell ID</th><td>0xBEEF</td></tr>
      <tr><th>Status</th><td>Connected</td></tr>
    </table></body></html>
    """
    with respx.mock(base_url=BASE, assert_all_called=False) as router:
        router.get("/").respond(200, text="<html><input name='nonce' value='n'/></html>")
        router.post("/cgi-bin/login").respond(
            200, headers={"set-cookie": "sessionID=x"}, json={"result": "ok"}
        )
        # CGI JSON endpoints 404; HTML status page answers.
        router.get("/cgi-bin/qcmap_web_cgi").respond(404)
        router.get("/cgi-bin/status_5g").respond(200, headers={"content-type": "text/html"}, text=html)

        snap = await adapter.read_snapshot()

    assert snap.rsrp == -95.0
    assert snap.rsrq == -12.0
    assert snap.sinr == 7.0
    assert snap.cell_id == "0xBEEF"
    assert snap.connected is True
