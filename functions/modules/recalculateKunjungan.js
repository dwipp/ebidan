// recalculateKunjungan.js
import { onRequest } from "firebase-functions/v2/https";
import { getMonthString } from "./helpers.js";
import { db } from "./firebase.js";

const REGION = "asia-southeast2";
const statusesToCount = ["K1", "K4", "K5", "K6"];

// Parse "X minggu Y hari" -> total minggu sebagai desimal
function parseTotalWeeks(ukValue) {
  if (!ukValue) return 0;
  const match = ukValue.match(/(\d+)\s+minggu\s*(\d+)?\s*hari?/);
  if (!match) return 0;
  const weeks = parseInt(match[1], 10);
  const days = match[2] ? parseInt(match[2], 10) : 0;
  return weeks + days / 7;
}

export const recalculateKunjunganStats = onRequest({ region: REGION }, async (req, res) => {
  try {
    const snapshot = await db.collection("kunjungan").get();
    const statsByBidan = {};

    snapshot.forEach(doc => {
      const data = doc.data();
      if (!data.id_bidan || !data.status) return;

      const idBidan = data.id_bidan;
      const status = data.status;
      if (!statusesToCount.includes(status)) return;

      const createdAt = data.createdAt?.toDate ? data.createdAt.toDate() : new Date();
      const monthKey = getMonthString(createdAt);

      if (!statsByBidan[idBidan]) statsByBidan[idBidan] = { by_month: {} };
      if (!statsByBidan[idBidan].by_month[monthKey]) {
        statsByBidan[idBidan].by_month[monthKey] = {
          k1: 0, k4: 0, k5: 0, k6: 0,
          k1_murni: 0, k1_akses: 0
        };
      }

      // Increment status count
      const key = status.toLowerCase();
      statsByBidan[idBidan].by_month[monthKey][key]++;

      // Tambahan k1_murni & k1_akses
      if (status === "K1") {
        const totalWeeks = parseTotalWeeks(data.uk);
        if (totalWeeks <= 12) statsByBidan[idBidan].by_month[monthKey].k1_murni++;
        else statsByBidan[idBidan].by_month[monthKey].k1_akses++;
      }
    });

    const batch = db.batch();
    const currentMonth = getMonthString(new Date());

    for (const [idBidan, stats] of Object.entries(statsByBidan)) {
      const ref = db.doc(`statistics/${idBidan}`);

      // Ambil data existing agar tidak overwrite bumil map
      const doc = await ref.get();
      const existing = doc.exists ? doc.data() : {};
      const byMonth = existing.by_month || {};

      // Merge bulan yang dihitung
      for (const [month, counts] of Object.entries(stats.by_month)) {
        if (!byMonth[month]) byMonth[month] = {
          k1:0, k4:0, k5:0, k6:0, k1_murni:0, k1_akses:0
        };
        for (const key of ["k1","k4","k5","k6","k1_murni","k1_akses"]) {
          byMonth[month][key] = counts[key];
        }
      }

      batch.set(ref, {
        ...existing,
        by_month: byMonth,
        last_updated_month: currentMonth
      }, { merge: true });
    }

    await batch.commit();
    res.status(200).send({ message: "Recalculation kunjungan complete", statsByBidan });

  } catch (error) {
    console.error("Recalculation kunjungan error:", error);
    res.status(500).send({ error: error.message });
  }
});
