// SSE consumer with auto-reconnect. Emits the last snapshot or a modem
// error to any subscriber. Kept tiny — EventSource does the heavy lifting.

const listeners = new Set();

const bus = {
  latest: null,     // last successful SignalSnapshot
  error: null,      // last modem error, or null while healthy
  connected: false,
  subscribe(fn) {
    listeners.add(fn);
    fn(bus);
    return () => listeners.delete(fn);
  },
  _emit() { for (const fn of listeners) fn(bus); },
};

let es = null;
let retryMs = 500;

export function startSignalStream() {
  if (es) return;

  const open = () => {
    es = new EventSource("/api/signal/stream");

    es.onopen = () => {
      bus.connected = true;
      retryMs = 500;
      bus._emit();
    };

    es.onmessage = (ev) => {
      try {
        const snap = JSON.parse(ev.data);
        bus.latest = snap;
        bus.error = null;
        bus._emit();
      } catch { /* ignore malformed frame */ }
    };

    es.addEventListener("modem_error", (ev) => {
      try {
        bus.error = JSON.parse(ev.data);
      } catch {
        bus.error = { error: "unknown", type: "ParseError" };
      }
      bus._emit();
    });

    es.onerror = () => {
      bus.connected = false;
      bus._emit();
      if (es) es.close();
      es = null;
      setTimeout(open, retryMs);
      retryMs = Math.min(retryMs * 2, 8000);
    };
  };

  open();
}

export const signalStream = bus;
