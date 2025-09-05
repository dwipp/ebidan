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
      if (!statsByBidan[idBidan]) statsByBidan[idBidan] = { bumil: { bumil_total: 0 }, by_month: {} };

      statsByBidan[idBidan].bumil.bumil_total++;

      const createdAt = data.createdAt?.toDate ? data.createdAt.toDate() : new Date();
      const monthKey = getMonthString(createdAt);

      if (!statsByBidan[idBidan].by_month[monthKey]) statsByBidan[idBidan].by_month[monthKey] = { bumil: 0 };
      statsByBidan[idBidan].by_month[monthKey].bumil++;
    });

    const batch = db.batch();
    const currentMonth = getMonthString(new Date());

    for (const [idBidan, stats] of Object.entries(statsByBidan)) {
      const ref = db.doc(`statistics/${idBidan}`);
      const doc = await ref.get();
      const existing = doc.exists ? doc.data() : {};
      const byMonth = existing.by_month || {};

      for (const [month, counts] of Object.entries(stats.by_month)) {
        if (!byMonth[month]) byMonth[month] = { bumil: 0 };
        byMonth[month].bumil = counts.bumil;
      }

      const bumil_this_month = byMonth[currentMonth]?.bumil || 0;

      batch.set(ref, {
        ...existing,
        bumil: { bumil_total: stats.bumil.bumil_total, bumil_this_month },
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
