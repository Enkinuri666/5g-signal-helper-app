"""Domain types shared by every layer."""

from __future__ import annotations

from datetime import datetime, timezone
from typing import Optional

from pydantic import BaseModel, Field


class SignalSnapshot(BaseModel):
    """One point-in-time reading of the modem's radio state.

    All fields except `taken_at` are optional so a partial parse still
    yields a useful snapshot — the UI degrades one metric at a time
    instead of blanking the whole dashboard.
    """

    rsrp: Optional[float] = Field(default=None, description="Reference Signal Received Power, dBm")
    rsrq: Optional[float] = Field(default=None, description="Reference Signal Received Quality, dB")
    sinr: Optional[float] = Field(default=None, description="Signal-to-Interference-plus-Noise Ratio, dB")
    cell_id: Optional[str] = Field(default=None, description="Serving cell identifier (PCI or gNB cell id)")
    band: Optional[str] = Field(default=None, description="NR band, e.g. 'n78'")
    tac: Optional[str] = Field(default=None, description="Tracking Area Code")
    plmn: Optional[str] = Field(default=None, description="Public Land Mobile Network id")
    connected: bool = Field(default=False, description="True iff the radio reports 'connected'")
    taken_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))

    def quality_label(self) -> str:
        """Rough human label for RSRP; mirrors what the UI colors on."""
        if self.rsrp is None:
            return "unknown"
        if self.rsrp >= -80:
            return "excellent"
        if self.rsrp >= -90:
            return "good"
        if self.rsrp >= -100:
            return "fair"
        return "poor"


class ModemStatus(BaseModel):
    """Adapter-level status, surfaced by /api/health."""

    reachable: bool
    authenticated: bool
    last_error: Optional[str] = None
    firmware_mode: Optional[str] = Field(
        default=None,
        description="Which auth handshake succeeded ('form' | 'jsonrpc' | None)",
    )
    last_snapshot_at: Optional[datetime] = None
