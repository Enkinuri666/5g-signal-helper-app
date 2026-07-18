"""Modem adapters.

Each concrete adapter knows how to talk to one modem family. The rest of
the app depends only on `ModemAdapter`, so a firmware refresh — or a
totally different modem — is a single-file swap.
"""

from .base import ModemAdapter, ModemAuthError, ModemError, ModemParseError, ModemUnreachableError

__all__ = [
    "ModemAdapter",
    "ModemAuthError",
    "ModemError",
    "ModemParseError",
    "ModemUnreachableError",
]
