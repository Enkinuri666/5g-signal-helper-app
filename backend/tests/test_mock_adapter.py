import pytest

from signal_helper.modem.mock import MockAdapter


@pytest.mark.asyncio
async def test_mock_snapshot_populates_all_fields() -> None:
    async with MockAdapter() as adapter:
        snap = await adapter.read_snapshot()
    assert snap.rsrp is not None
    assert snap.rsrq is not None
    assert snap.sinr is not None
    assert snap.cell_id
    assert snap.band == "n78"
    assert snap.connected is True


@pytest.mark.asyncio
async def test_mock_status_reports_healthy() -> None:
    async with MockAdapter() as adapter:
        await adapter.read_snapshot()
        status = await adapter.status()
    assert status.reachable and status.authenticated
    assert status.firmware_mode == "mock"
    assert status.last_snapshot_at is not None
