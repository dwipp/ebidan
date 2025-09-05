// helpers.js
// Fungsi pembantu
function getMonthString(date) {
  return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, "0")}`;
}

export { getMonthString };
