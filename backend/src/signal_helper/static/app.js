import { bearingBetween, angleDelta } from "/geo.js";
import { compass } from "/compass.js";
import { sensors, requestOrientationPermission, startGeolocation } from "/sensors.js";
import { signalStream, startSignalStream } from "/signal-stream.js";

// ---- persisted tower coordinates ------------------------------------
const STORAGE_KEY = "signal-helper.tower.v1";

function loadTower() {
  try {
    return JSON.parse(localStorage.getItem(STORAGE_KEY)) || null;
  } catch { return null; }
}
function saveTower(t) {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(t));
}
let tower = loadTower();

// ---- DOM refs -------------------------------------------------------
const $ = (id) => document.getElementById(id);

const dot = $("statusDot");
const banner = $("banner");
const deltaLabel = $("deltaLabel");
const orientBtn = $("orientPermBtn");
const gpsBtn = $("gpsPermBtn");
const settings = $("settings");
const settingsBtn = $("settingsBtn");
const towerLat = $("towerLat");
const towerLon = $("towerLon");
const towerLabel = $("towerLabel");

// Metric fields
const mRsrp = $("mRsrp");
const mRsrq = $("mRsrq");
const mSinr = $("mSinr");
const mCell = $("mCell");
const mBand = $("mBand");

// ---- settings drawer ------------------------------------------------
if (tower) {
  towerLat.value = tower.lat ?? "";
  towerLon.value = tower.lon ?? "";
  towerLabel.value = tower.label ?? "";
}

settingsBtn.addEventListener("click", () => settings.showModal());
settings.addEventListener("close", () => {
  if (settings.returnValue === "save") {
    const lat = parseFloat(towerLat.value);
    const lon = parseFloat(towerLon.value);
    if (Number.isFinite(lat) && Number.isFinite(lon)) {
      tower = { lat, lon, label: towerLabel.value.trim() || null };
      saveTower(tower);
    }
    recomputeTarget();
  }
});

// ---- permission gating ---------------------------------------------
orientBtn.addEventListener("click", async () => {
  const state = await requestOrientationPermission();
  if (state === "granted") orientBtn.hidden = true;
});
gpsBtn.addEventListener("click", () => {
  startGeolocation();
  gpsBtn.hidden = true;
});

// iOS 13+ requires a user gesture for DeviceOrientation. On other
// browsers we just attach the listener silently.
if (
  window.DeviceOrientationEvent &&
  typeof window.DeviceOrientationEvent.requestPermission === "function"
) {
  orientBtn.hidden = false;
} else {
  requestOrientationPermission();
}

// Geolocation always needs a prompt — button gives the user control
// over when the OS dialog appears.
gpsBtn.hidden = false;

// ---- secure-origin banner ------------------------------------------
if (!window.isSecureContext) {
  banner.hidden = false;
  banner.classList.add("warn");
  banner.textContent =
    "Sensors need a secure origin. On HTTP LAN, add this URL to Chrome's " +
    "'Insecure origins treated as secure' flag on the phone.";
}

// ---- signal stream -------------------------------------------------
startSignalStream();

signalStream.subscribe(({ latest, error, connected }) => {
  if (error) {
    dot.dataset.state = "error";
    banner.hidden = false;
    banner.classList.remove("warn");
    banner.textContent = `Modem: ${error.error}`;
  } else if (!connected) {
    dot.dataset.state = "stale";
  } else {
    dot.dataset.state = "live";
    if (!window.isSecureContext) {
      // Keep the secure-origin warning visible; don't overwrite it.
    } else {
      banner.hidden = true;
    }
  }
  renderMetrics(latest);
});

function renderMetrics(snap) {
  if (!snap) return;
  mRsrp.textContent = fmt(snap.rsrp, 1);
  mRsrq.textContent = fmt(snap.rsrq, 1);
  mSinr.textContent = fmt(snap.sinr, 1);
  mCell.textContent = snap.cell_id ?? "—";
  mBand.textContent = snap.band ?? "";

  // Border color for the RSRP tile
  const cls = qualityLabel(snap.rsrp);
  mRsrp.parentElement.className = `metric rsrp-${cls}`;
}

function fmt(n, digits) {
  return typeof n === "number" && Number.isFinite(n) ? n.toFixed(digits) : "—";
}

function qualityLabel(rsrp) {
  if (typeof rsrp !== "number") return "unknown";
  if (rsrp >= -80) return "excellent";
  if (rsrp >= -90) return "good";
  if (rsrp >= -100) return "fair";
  return "poor";
}

// ---- sensors + bearing math ---------------------------------------
sensors.subscribe(({ heading, lat, lon }) => {
  compass.setHeading(heading ?? 0);
  recomputeTarget(heading, lat, lon);
});

function recomputeTarget(heading = sensors.latest.heading,
                        lat = sensors.latest.lat,
                        lon = sensors.latest.lon) {
  if (!tower || lat == null || lon == null) {
    compass.setTargetBearing(null);
    deltaLabel.textContent = tower ? "Waiting for GPS…" : "Set tower coordinates";
    return;
  }
  const bearing = bearingBetween(lat, lon, tower.lat, tower.lon);
  compass.setTargetBearing(bearing);

  if (heading == null) {
    deltaLabel.textContent = `Bearing ${bearing.toFixed(0)}°`;
    return;
  }
  const delta = angleDelta(heading, bearing);
  const arrow = delta > 3 ? "↻" : delta < -3 ? "↺" : "●";
  deltaLabel.textContent = `${arrow} ${Math.abs(delta).toFixed(0)}° ${
    Math.abs(delta) < 3 ? "on target" : delta > 0 ? "right" : "left"
  }`;
}

// ---- service worker (best-effort, offline shell) -------------------
if ("serviceWorker" in navigator) {
  window.addEventListener("load", () => {
    navigator.serviceWorker.register("/sw.js").catch(() => { /* fine */ });
  });
}
