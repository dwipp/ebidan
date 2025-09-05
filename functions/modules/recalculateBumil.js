// recalculate.js
import { onRequest } from "firebase-functions/v2/https";
import { getFirestore } from "firebase-admin/firestore";
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
        statsByBidan[idBidan] = { bumilTotal: 0, bumilByMonth: {} };
      }

      statsByBidan[idBidan].bumilTotal++;
      const createdAt = data.createdAt?.toDate ? data.createdAt.toDate() : new Date();
      const monthKey = getMonthString(createdAt);

      statsByBidan[idBidan].bumilByMonth[monthKey] =
        (statsByBidan[idBidan].bumilByMonth[monthKey] || 0) + 1;
    });

    const batch = db.batch();
    const currentMonth = getMonthString(new Date());

    for (const [idBidan, stats] of Object.entries(statsByBidan)) {
      const bumilThisMonth = stats.bumilByMonth[currentMonth] || 0;
      const ref = db.doc(`statistics/${idBidan}`);

      batch.set(ref, {
        bumilTotal: stats.bumilTotal,
        bumilThisMonth,
        lastUpdatedMonth: currentMonth,
        bumilByMonth: stats.bumilByMonth
      });
    }

    await batch.commit();

    res.status(200).send({ message: "Recalculation complete", statsByBidan });
  } catch (error) {
    console.error("Recalculation error:", error);
    res.status(500).send({ error: error.message });
  }
});
