"""Self-signed TLS cert helper.

Web APIs the compass depends on — DeviceOrientation, geolocation,
service worker install — require a "secure context". Localhost qualifies,
but a phone talking to a Pi on the LAN over plain HTTP does not. This
module mints a self-signed cert with matching SAN entries so the browser
treats the URL as HTTPS after a one-off "proceed anyway" tap.

The cert is intentionally short-lived (365 days) — regenerating is
cheap, and a stolen cert has a bounded blast radius.
"""

from __future__ import annotations

import datetime
import ipaddress
import os
import socket
from dataclasses import dataclass
from pathlib import Path
from typing import Sequence

from cryptography import x509
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import rsa
from cryptography.x509.oid import NameOID


DEFAULT_TLS_DIR = Path.home() / ".signal-helper" / "tls"
DEFAULT_CERT_PATH = DEFAULT_TLS_DIR / "cert.pem"
DEFAULT_KEY_PATH = DEFAULT_TLS_DIR / "key.pem"


@dataclass
class GeneratedCert:
    cert_path: Path
    key_path: Path
    subject_alt_names: list[str]
    not_after: datetime.datetime


def _outbound_ip() -> str | None:
    """Best-effort local IP the phone would use to reach us.

    The trick: opening a UDP socket to a public address makes the kernel
    pick the outbound interface without sending any packets.
    """
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        s.connect(("8.8.8.8", 80))
        return s.getsockname()[0]
    except OSError:
        return None
    finally:
        s.close()


def _classify(name: str) -> tuple[str, x509.GeneralName]:
    """Return ('ip'|'dns', GeneralName) for a SAN candidate."""
    try:
        addr = ipaddress.ip_address(name)
        return "ip", x509.IPAddress(addr)
    except ValueError:
        return "dns", x509.DNSName(name)


def collect_default_sans(extras: Sequence[str] = ()) -> list[str]:
    """localhost + 127.0.0.1 + auto-detected LAN IP + whatever the caller adds."""
    sans: list[str] = ["localhost", "127.0.0.1"]
    lan = _outbound_ip()
    if lan and lan not in sans:
        sans.append(lan)
    for e in extras:
        if e and e not in sans:
            sans.append(e)
    return sans


def generate_self_signed(
    sans: Sequence[str],
    cert_path: Path = DEFAULT_CERT_PATH,
    key_path: Path = DEFAULT_KEY_PATH,
    days_valid: int = 365,
    common_name: str = "5G Signal Helper",
) -> GeneratedCert:
    """Write a fresh (cert, key) pair, overwriting any existing files."""
    if not sans:
        raise ValueError("at least one SAN is required")

    cert_path.parent.mkdir(parents=True, exist_ok=True)

    key = rsa.generate_private_key(public_exponent=65537, key_size=2048)

    subject = issuer = x509.Name(
        [x509.NameAttribute(NameOID.COMMON_NAME, common_name)]
    )

    san_extension = x509.SubjectAlternativeName([_classify(s)[1] for s in sans])
    now = datetime.datetime.now(datetime.timezone.utc)

    cert = (
        x509.CertificateBuilder()
        .subject_name(subject)
        .issuer_name(issuer)
        .public_key(key.public_key())
        .serial_number(x509.random_serial_number())
        .not_valid_before(now - datetime.timedelta(minutes=5))
        .not_valid_after(now + datetime.timedelta(days=days_valid))
        .add_extension(san_extension, critical=False)
        .add_extension(x509.BasicConstraints(ca=False, path_length=None), critical=True)
        .add_extension(
            x509.KeyUsage(
                digital_signature=True,
                content_commitment=False,
                key_encipherment=True,
                data_encipherment=False,
                key_agreement=False,
                key_cert_sign=False,
                crl_sign=False,
                encipher_only=False,
                decipher_only=False,
            ),
            critical=True,
        )
        .add_extension(
            x509.ExtendedKeyUsage([x509.ExtendedKeyUsageOID.SERVER_AUTH]),
            critical=False,
        )
        .sign(private_key=key, algorithm=hashes.SHA256())
    )

    cert_path.write_bytes(cert.public_bytes(serialization.Encoding.PEM))
    key_path.write_bytes(
        key.private_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PrivateFormat.PKCS8,
            encryption_algorithm=serialization.NoEncryption(),
        )
    )
    # Key is a secret; even in $HOME we don't want it group/other-readable.
    os.chmod(key_path, 0o600)

    return GeneratedCert(
        cert_path=cert_path,
        key_path=key_path,
        subject_alt_names=list(sans),
        not_after=cert.not_valid_after_utc,
    )
