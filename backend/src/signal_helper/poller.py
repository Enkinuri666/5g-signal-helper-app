"""Single background poll loop feeding many SSE subscribers.

Design choice: one poll per interval regardless of subscriber count.
Multiple browsers connecting to the compass at once still hit the
modem's fragile web UI at ~1 Hz, not 3 Hz. The last snapshot (or the
last error) is fanned out to every subscriber's queue.
"""

from __future__ import annotations

import asyncio
import logging
from typing import AsyncIterator, Optional

from .modem import ModemAdapter, ModemError
from .models import SignalSnapshot

log = logging.getLogger(__name__)


class BroadcastPoller:
    """Polls a `ModemAdapter` on a fixed interval and fans results out."""

    def __init__(self, adapter: ModemAdapter, interval_s: float = 1.0) -> None:
        self._adapter = adapter
        self._interval_s = interval_s
        self._subscribers: set[asyncio.Queue[SignalSnapshot | ModemError]] = set()
        self._task: Optional[asyncio.Task[None]] = None
        self._latest: Optional[SignalSnapshot] = None
        self._backoff_until = 0.0

    @property
    def latest(self) -> Optional[SignalSnapshot]:
        return self._latest

    async def start(self) -> None:
        if self._task is None or self._task.done():
            self._task = asyncio.create_task(self._run(), name="signal-poller")

    async def stop(self) -> None:
        if self._task and not self._task.done():
            self._task.cancel()
            try:
                await self._task
            except asyncio.CancelledError:
                pass

    async def subscribe(self) -> AsyncIterator[SignalSnapshot | ModemError]:
        """Yield snapshots (or errors) as the poller produces them.

        A brand-new subscriber immediately gets the last cached snapshot
        so the compass has something to render before the next poll tick.
        """
        queue: asyncio.Queue[SignalSnapshot | ModemError] = asyncio.Queue(maxsize=4)
        self._subscribers.add(queue)
        try:
            if self._latest is not None:
                await queue.put(self._latest)
            while True:
                item = await queue.get()
                yield item
        finally:
            self._subscribers.discard(queue)

    async def _run(self) -> None:
        backoff = 1.0
        while True:
            try:
                snap = await self._adapter.read_snapshot()
                self._latest = snap
                self._broadcast(snap)
                backoff = 1.0
                await asyncio.sleep(self._interval_s)
            except ModemError as exc:
                self._broadcast(exc)
                log.warning("poll failed: %s (backoff %.1fs)", exc, backoff)
                await asyncio.sleep(backoff)
                backoff = min(backoff * 2, 15.0)
            except asyncio.CancelledError:
                raise
            except Exception:
                # Never let the loop die silently — log and back off.
                log.exception("poller crashed")
                await asyncio.sleep(5.0)

    def _broadcast(self, item: SignalSnapshot | ModemError) -> None:
        for q in list(self._subscribers):
            if q.full():
                # Drop the oldest so live viewers don't stall the poller.
                try:
                    q.get_nowait()
                except asyncio.QueueEmpty:
                    pass
            try:
                q.put_nowait(item)
            except asyncio.QueueFull:
                pass
