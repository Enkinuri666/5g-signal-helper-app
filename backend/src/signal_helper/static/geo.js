// Forward azimuth on the WGS-84 sphere — accurate enough for FWA alignment.
// Returns bearing in degrees clockwise from true north, 0..360.
export function bearingBetween(fromLat, fromLon, toLat, toLon) {
  const toRad = (d) => (d * Math.PI) / 180;
  const toDeg = (r) => (r * 180) / Math.PI;

  const φ1 = toRad(fromLat);
  const φ2 = toRad(toLat);
  const Δλ = toRad(toLon - fromLon);

  const y = Math.sin(Δλ) * Math.cos(φ2);
  const x =
    Math.cos(φ1) * Math.sin(φ2) -
    Math.sin(φ1) * Math.cos(φ2) * Math.cos(Δλ);

  return (toDeg(Math.atan2(y, x)) + 360) % 360;
}

// Great-circle distance in metres. Handy for the settings hint.
export function distanceMeters(fromLat, fromLon, toLat, toLon) {
  const R = 6371000;
  const toRad = (d) => (d * Math.PI) / 180;
  const φ1 = toRad(fromLat);
  const φ2 = toRad(toLat);
  const Δφ = toRad(toLat - fromLat);
  const Δλ = toRad(toLon - fromLon);
  const a =
    Math.sin(Δφ / 2) ** 2 +
    Math.cos(φ1) * Math.cos(φ2) * Math.sin(Δλ / 2) ** 2;
  return 2 * R * Math.asin(Math.sqrt(a));
}

// Smallest signed delta in degrees between two headings, -180..180.
export function angleDelta(fromDeg, toDeg) {
  let d = ((toDeg - fromDeg + 540) % 360) - 180;
  // -180 is equivalent to 180 for our purposes; prefer positive for symmetry.
  return d === -180 ? 180 : d;
}
