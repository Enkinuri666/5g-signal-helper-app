// Draws the compass. Tick marks and cardinals are generated once at
// boot; per-frame the rotation transform on #dial is set from
// (0 − heading) so N floats to the top, and #target is spun to the
// target bearing so it rides the dial.

const dial = document.getElementById("dial");
const ticks = document.getElementById("ticks");
const cardinals = document.getElementById("cardinals");
const target = document.getElementById("target");

const NS = "http://www.w3.org/2000/svg";

function el(tag, attrs = {}) {
  const n = document.createElementNS(NS, tag);
  for (const [k, v] of Object.entries(attrs)) n.setAttribute(k, v);
  return n;
}

// Build ticks & cardinals once.
(function seedDial() {
  for (let deg = 0; deg < 360; deg += 5) {
    const major = deg % 30 === 0;
    const line = el("line", {
      x1: 0, y1: -90,
      x2: 0, y2: major ? -80 : -85,
      stroke: major ? "#94a3b8" : "#334155",
      "stroke-width": major ? 1.5 : 1,
      transform: `rotate(${deg})`,
    });
    ticks.appendChild(line);
  }

  const cards = [
    { text: "N", deg: 0, cls: "" },
    { text: "E", deg: 90, cls: "sub" },
    { text: "S", deg: 180, cls: "sub" },
    { text: "W", deg: 270, cls: "sub" },
  ];
  for (const c of cards) {
    const t = el("text", {
      x: 0, y: -66,
      transform: `rotate(${c.deg}) rotate(${-c.deg} 0 -66)`,
    });
    if (c.cls) t.setAttribute("class", c.cls);
    t.textContent = c.text;
    cardinals.appendChild(t);
  }
})();

let currentHeading = 0;      // rendered heading (smoothed)
let currentTarget = null;    // rendered target bearing

// Frame loop keeps the dial smooth even when sensor events arrive in
// bursts. Heading is exponentially smoothed to hide compass jitter.
let desiredHeading = 0;
let desiredTarget = null;

function tick() {
  const diff = shortestDelta(currentHeading, desiredHeading);
  currentHeading = (currentHeading + diff * 0.25 + 360) % 360;
  dial.setAttribute("transform", `rotate(${-currentHeading})`);

  if (desiredTarget !== null) {
    if (currentTarget === null) currentTarget = desiredTarget;
    const td = shortestDelta(currentTarget, desiredTarget);
    currentTarget = (currentTarget + td * 0.25 + 360) % 360;
    target.setAttribute("transform", `rotate(${currentTarget})`);
    target.style.opacity = 1;
  } else {
    target.style.opacity = 0;
  }

  requestAnimationFrame(tick);
}
requestAnimationFrame(tick);

function shortestDelta(from, to) {
  let d = ((to - from + 540) % 360) - 180;
  return d;
}

export const compass = {
  setHeading(deg) {
    if (typeof deg === "number" && !Number.isNaN(deg)) desiredHeading = deg;
  },
  setTargetBearing(deg) {
    desiredTarget = typeof deg === "number" && !Number.isNaN(deg) ? deg : null;
  },
};
