"""Cert generator smoke tests — mint one, parse it back, check the SANs."""

from __future__ import annotations

import datetime
import ipaddress
from pathlib import Path

import pytest
from cryptography import x509

from signal_helper.tls import (
    collect_default_sans,
    generate_self_signed,
)


def test_generate_self_signed_writes_pem_pair_with_expected_sans(tmp_path: Path) -> None:
    cert_path = tmp_path / "cert.pem"
    key_path = tmp_path / "key.pem"

    result = generate_self_signed(
        ["localhost", "127.0.0.1", "192.168.1.50", "modem.local"],
        cert_path=cert_path,
        key_path=key_path,
        days_valid=7,
    )

    assert cert_path.exists() and key_path.exists()
    assert result.subject_alt_names == ["localhost", "127.0.0.1", "192.168.1.50", "modem.local"]

    # Key file must not be world-readable.
    assert (key_path.stat().st_mode & 0o077) == 0

    cert = x509.load_pem_x509_certificate(cert_path.read_bytes())
    san_ext = cert.extensions.get_extension_for_class(x509.SubjectAlternativeName).value

    dns_names = san_ext.get_values_for_type(x509.DNSName)
    ip_addresses = san_ext.get_values_for_type(x509.IPAddress)

    assert "localhost" in dns_names
    assert "modem.local" in dns_names
    assert ipaddress.IPv4Address("127.0.0.1") in ip_addresses
    assert ipaddress.IPv4Address("192.168.1.50") in ip_addresses

    now = datetime.datetime.now(datetime.timezone.utc)
    assert cert.not_valid_before_utc <= now < cert.not_valid_after_utc


def test_collect_default_sans_dedupes_and_includes_localhost() -> None:
    sans = collect_default_sans(["localhost", "192.168.1.50", "192.168.1.50"])
    assert sans[0] == "localhost"
    assert "127.0.0.1" in sans
    assert sans.count("192.168.1.50") == 1


def test_generate_self_signed_rejects_empty_san_list(tmp_path: Path) -> None:
    with pytest.raises(ValueError):
        generate_self_signed(
            [],
            cert_path=tmp_path / "c.pem",
            key_path=tmp_path / "k.pem",
        )
