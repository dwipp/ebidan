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
          bumil: { all_bumil_count: 0 }, 
          by_month: {} 
        };
      }

      // increment total semua bumil
      statsByBidan[idBidan].bumil.all_bumil_count++;

      const createdAt = data.createdAt?.toDate ? data.createdAt.toDate() : new Date();
      const monthKey = getMonthString(createdAt);

      // inisialisasi by_month[monthKey] dengan object
      if (!statsByBidan[idBidan].by_month[monthKey]) {
        statsByBidan[idBidan].by_month[monthKey] = { bumil: { total: 0 } };
      }

      // increment total per bulan
      statsByBidan[idBidan].by_month[monthKey].bumil.total++;
    });

    const batch = db.batch();
    const currentMonth = getMonthString(new Date());

    for (const [idBidan, stats] of Object.entries(statsByBidan)) {
      const ref = db.doc(`statistics/${idBidan}`);
      const doc = await ref.get();
      const existing = doc.exists ? doc.data() : {};
      const byMonth = existing.by_month || {};

      for (const [month, counts] of Object.entries(stats.by_month)) {
        if (!byMonth[month]) byMonth[month] = { bumil: { total: 0 } };
        byMonth[month].bumil.total = counts.bumil.total;
      }

      batch.set(ref, {
        ...existing,
        bumil: { 
          all_bumil_count: stats.bumil.all_bumil_count
        },
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
