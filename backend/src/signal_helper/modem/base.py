"""Adapter contract every modem implementation satisfies."""

from __future__ import annotations

from abc import ABC, abstractmethod
from typing import Optional

from ..models import ModemStatus, SignalSnapshot


class ModemError(Exception):
    """Base class for all modem-side failures."""


class ModemUnreachableError(ModemError):
    """The modem's IP/port didn't answer (network, DNS, TLS, timeout)."""


class ModemAuthError(ModemError):
    """Credentials rejected or the session expired mid-poll."""


class ModemParseError(ModemError):
    """The modem answered but the payload didn't match any known shape."""


class ModemAdapter(ABC):
    """Talk to one modem family and return a normalized snapshot.

    Adapters own their own HTTP client and session state. Callers should
    hold an adapter for the lifetime of the process; `close()` is called
    on shutdown.
    """

    @abstractmethod
    async def read_snapshot(self) -> SignalSnapshot:
        """Return the current radio state.

        Implementations MUST re-authenticate transparently on session
        expiry so the caller can treat this as a plain read.
        """

    @abstractmethod
    async def status(self) -> ModemStatus:
        """Return adapter-level health for /api/health."""

    async def close(self) -> None:  # override if you hold resources
        return None

    async def __aenter__(self) -> "ModemAdapter":
        return self

    async def __aexit__(self, *_exc: object) -> None:
        await self.close()

    firmware_mode: Optional[str] = None
