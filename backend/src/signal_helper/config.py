"""Runtime configuration.

Values come from environment variables so credentials never appear in
the process argv or on disk (beyond an operator-provided .env).
"""

from __future__ import annotations

import os
from dataclasses import dataclass


@dataclass(frozen=True)
class Settings:
    modem_host: str
    modem_username: str
    modem_password: str
    poll_interval_s: float
    request_timeout_s: float
    use_mock_adapter: bool

    @classmethod
    def from_env(cls) -> "Settings":
        return cls(
            modem_host=os.getenv("MODEM_HOST", "192.168.1.1"),
            modem_username=os.getenv("MODEM_USERNAME", "admin"),
            modem_password=os.getenv("MODEM_PASSWORD", ""),
            poll_interval_s=float(os.getenv("POLL_INTERVAL_S", "1.0")),
            request_timeout_s=float(os.getenv("REQUEST_TIMEOUT_S", "3.0")),
            use_mock_adapter=os.getenv("USE_MOCK_ADAPTER", "").lower() in {"1", "true", "yes"},
        )
