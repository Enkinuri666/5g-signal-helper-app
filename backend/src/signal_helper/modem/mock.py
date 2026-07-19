"""In-memory adapter that fakes a modem so the UI/API can be developed
without hardware. Values wobble slightly on each read so gauges animate.
"""

from __future__ import annotations

import math
import time
from typing import Optional

from ..models import ModemStatus, SignalSnapshot
from .base import ModemAdapter


class MockAdapter(ModemAdapter):
    firmware_mode = "mock"

    def __init__(self, *, base_rsrp: float = -88.0, cell_id: str = "0x0A1B2C") -> None:
        self._base_rsrp = base_rsrp
        self._cell_id = cell_id
        self._t0 = time.monotonic()
        self._last_error: Optional[str] = None
        self._last_snapshot: Optional[SignalSnapshot] = None

    async def read_snapshot(self) -> SignalSnapshot:
        elapsed = time.monotonic() - self._t0
        wobble = math.sin(elapsed / 2.0) * 3.0
        snap = SignalSnapshot(
            rsrp=self._base_rsrp + wobble,
            rsrq=-11.0 + wobble / 2,
            sinr=12.5 + wobble,
            cell_id=self._cell_id,
            band="n78",
            tac="1A2B",
            plmn="50503",
            connected=True,
        )
        self._last_snapshot = snap
        return snap

    async def status(self) -> ModemStatus:
        return ModemStatus(
            reachable=True,
            authenticated=True,
            last_error=self._last_error,
            firmware_mode=self.firmware_mode,
            last_snapshot_at=self._last_snapshot.taken_at if self._last_snapshot else None,
        )
