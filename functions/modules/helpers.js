export function getMonthString(date) {
  return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, "0")}`;
}

// Ambil usia kehamilan dalam minggu dari format "X minggu Y hari"
export function parseUK(ukString) {
  const match = ukString.match(/(\d+)\s*minggu\s*(\d+)?\s*hari?/i);
  if (!match) return 0;
  const minggu = parseInt(match[1] || 0);
  return minggu;
}

// Helper agar tidak pernah NaN
export function safeIncrement(obj, key, val = 1) {
  obj[key] = (typeof obj[key] === "number" ? obj[key] : 0) + val;
}

export function safeDecrement(obj, key, val = 1) {
  const current = typeof obj[key] === "number" ? obj[key] : 0;
  obj[key] = Math.max(current - val, 0);
}

