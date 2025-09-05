// recalculate.js
import { onRequest } from "firebase-functions/v2/https";
import { getMonthString } from "./helpers.js";
import { db } from "./firebase.js";

const REGION = "asia-southeast2";

export const recalculateBumilStats = onRequest({ region: REGION }, async (req, res) => {
  try {
    const snapshot = await db.collection("bumil").get();

    let statsByBidan = {};

    snapshot.forEach(doc => {
      const data = doc.data();
      if (!data.id_bidan) return;

      const idBidan = data.id_bidan;
      if (!statsByBidan[idBidan]) {
        statsByBidan[idBidan] = { bumil: { bumil_total: 0 }, by_month: {} };
      }

      // Increment total
      statsByBidan[idBidan].bumil.bumil_total++;

      // Tentukan bulan
      const createdAt = data.createdAt?.toDate ? data.createdAt.toDate() : new Date();
      const monthKey = getMonthString(createdAt);

      // Increment per bulan
      if (!statsByBidan[idBidan].by_month[monthKey]) {
        statsByBidan[idBidan].by_month[monthKey] = { bumil: 0 };
      }
      statsByBidan[idBidan].by_month[monthKey].bumil++;
    });

    const batch = db.batch();
    const currentMonth = getMonthString(new Date());

    for (const [idBidan, stats] of Object.entries(statsByBidan)) {
      const bumil_this_month = stats.by_month[currentMonth]?.bumil || 0;
      const ref = db.doc(`statistics/${idBidan}`);

      batch.set(ref, {
        bumil: {
          bumil_total: stats.bumil.bumil_total,
          bumil_this_month
        },
        last_updated_month: currentMonth,
        by_month: stats.by_month
      });
    }

    await batch.commit();

    res.status(200).send({ message: "Recalculation complete", statsByBidan });
  } catch (error) {
    console.error("Recalculation error:", error);
    res.status(500).send({ error: error.message });
  }
});
