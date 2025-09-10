import { onRequest } from "firebase-functions/v2/https";
import { getMonthString } from "../helpers.js";
import { db } from "../firebase.js";

const REGION = "asia-southeast2";

export const recalculateBumilStats = onRequest({ region: REGION }, async (req, res) => {
  try {
    const snapshot = await db.collection("bumil").get();
    const statsByBidan = {};

    snapshot.forEach(doc => {
      const data = doc.data();
      if (!data.id_bidan) return;

      const idBidan = data.id_bidan;
      if (!statsByBidan[idBidan]) {
        statsByBidan[idBidan] = { 
          kehamilan: { all_bumil_count: 0 }, // hanya yang hamil
          pasien: { all_pasien_count: 0 },   // semua bumil
          by_month: {} 
        };
      }

      // hitung semua pasien
      statsByBidan[idBidan].pasien.all_pasien_count++;

      const createdAt = data.createdAt?.toDate ? data.createdAt.toDate() : new Date();
      const monthKey = getMonthString(createdAt);

      // pastikan by_month[monthKey] ada
      if (!statsByBidan[idBidan].by_month[monthKey]) {
        statsByBidan[idBidan].by_month[monthKey] = {
          kehamilan: { total: 0 },
          pasien: { total: 0 }
        };
      }

      // increment total pasien per bulan (semua bumil)
      statsByBidan[idBidan].by_month[monthKey].pasien.total++;

      // increment total bumil hamil per bulan
      if (data.is_hamil) {
        statsByBidan[idBidan].kehamilan.all_bumil_count++;
        statsByBidan[idBidan].by_month[monthKey].kehamilan.total++;
      }
    });

    const batch = db.batch();
    const currentMonth = getMonthString(new Date());

    for (const [idBidan, stats] of Object.entries(statsByBidan)) {
      const ref = db.doc(`statistics/${idBidan}`);
      const doc = await ref.get();
      const existing = doc.exists ? doc.data() : {};
      const byMonth = existing.by_month || {};

      for (const [month, counts] of Object.entries(stats.by_month)) {
        if (!byMonth[month]) byMonth[month] = {};
        if (!byMonth[month].kehamilan) byMonth[month].kehamilan = { total: 0 };
        if (!byMonth[month].pasien) byMonth[month].pasien = { total: 0 };

        byMonth[month].kehamilan.total = counts.kehamilan.total ?? 0;
        byMonth[month].pasien.total = counts.pasien.total ?? 0;
      }

      batch.set(ref, {
        ...existing,
        kehamilan: { all_bumil_count: stats.kehamilan.all_bumil_count ?? 0 },
        pasien: { all_pasien_count: stats.pasien.all_pasien_count ?? 0 },
        last_updated_month: currentMonth,
        by_month: byMonth
      }, { merge: true });
    }

    await batch.commit();
    res.status(200).send({ message: "Recalculation complete", statsByBidan });

  } catch (error) {
    console.error("Recalculation error:", error);
    res.status(500).send({ error: error.message });
  }
});
