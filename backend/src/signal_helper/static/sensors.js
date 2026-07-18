// Thin bridge over the phone's magnetometer + GPS.
// Handles the iOS permission dance, screen-orientation compensation on
// Android, and exposes a small event bus so the UI doesn't care which
// browser produced the reading.

const listeners = new Set();

const bus = {
  latest: {
    heading: null,     // degrees clockwise from true north, 0..360
    headingAccuracy: null, // degrees or null
    lat: null,
    lon: null,
    gpsError: null,
    orientError: null,
    orientPermission: "unknown",  // "granted" | "denied" | "unknown"
    gpsPermission: "unknown",
  },
  subscribe(fn) {
    listeners.add(fn);
    fn(bus.latest);
    return () => listeners.delete(fn);
  },
  _emit(patch) {
    Object.assign(bus.latest, patch);
    for (const fn of listeners) fn(bus.latest);
  },
};

function normalizedHeadingFromEvent(e) {
  // iOS: webkitCompassHeading is already relative to true north, cw.
  if (typeof e.webkitCompassHeading === "number") {
    return {
      heading: e.webkitCompassHeading,
      accuracy: e.webkitCompassAccuracy ?? null,
    };
  }
  // Android/Chromium: alpha is 0..360 CCW from magnetic north when the
  // device is flat. We convert to CW-from-north and compensate for the
  // current screen orientation so tilting into landscape doesn't spin
  // the compass.
  const alpha = e.alpha;
  if (typeof alpha !== "number") return null;

  const screenAngle =
    (screen.orientation && screen.orientation.angle) ||
    window.orientation ||
    0;

  // Absolute (`deviceorientationabsolute`) already accounts for true north
  // via the OS on Android; relative would drift with the initial pose.
  const heading = (360 - alpha + screenAngle + 360) % 360;
  return { heading, accuracy: null };
}

function attachOrientationListener() {
  const handler = (e) => {
    const r = normalizedHeadingFromEvent(e);
    if (!r) return;
    bus._emit({
      heading: r.heading,
      headingAccuracy: r.accuracy,
      orientError: null,
    });
  };

  // Prefer the absolute event where available.
  if ("ondeviceorientationabsolute" in window) {
    window.addEventListener("deviceorientationabsolute", handler, true);
  }
  window.addEventListener("deviceorientation", handler, true);
}

export async function requestOrientationPermission() {
  const DOE = window.DeviceOrientationEvent;
  if (DOE && typeof DOE.requestPermission === "function") {
    try {
      const state = await DOE.requestPermission();
      bus._emit({ orientPermission: state });
      if (state === "granted") attachOrientationListener();
      return state;
    } catch (err) {
      bus._emit({ orientPermission: "denied", orientError: String(err) });
      return "denied";
    }
  }
  // Non-iOS: no explicit prompt; just attach.
  attachOrientationListener();
  bus._emit({ orientPermission: "granted" });
  return "granted";
}

export function startGeolocation() {
  if (!("geolocation" in navigator)) {
    bus._emit({ gpsError: "no geolocation API", gpsPermission: "denied" });
    return () => {};
  }
  const id = navigator.geolocation.watchPosition(
    (pos) => {
      bus._emit({
        lat: pos.coords.latitude,
        lon: pos.coords.longitude,
        gpsError: null,
        gpsPermission: "granted",
      });
    },
    (err) => {
      bus._emit({
        gpsError: err.message || String(err),
        gpsPermission: err.code === err.PERMISSION_DENIED ? "denied" : bus.latest.gpsPermission,
      });
    },
    { enableHighAccuracy: true, maximumAge: 2000, timeout: 15000 },
  );
  return () => navigator.geolocation.clearWatch(id);
}

export const sensors = bus;
