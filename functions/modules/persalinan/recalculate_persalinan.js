import { onRequest } from "firebase-functions/v2/https";
import { db } from "../firebase.js";
import { getMonthString } from "../helpers.js";

const REGION = "asia-southeast2";

export const recalculatePersalinanStats = onRequest(
  { region: REGION },
  async (req, res) => {
    try {
      const snapshot = await db.collection("kehamilan").get();
      const statsByBidan = {};

      snapshot.forEach((doc) => {
        const data = doc.data();
        if (!data.id_bidan) return;

        const idBidan = data.id_bidan;
        if (!statsByBidan[idBidan]) {
          statsByBidan[idBidan] = { by_month: {} };
        }

        const persalinanList = Array.isArray(data.persalinan) ? data.persalinan : [];
        for (const p of persalinanList) {
          let tgl;
          if (p.tgl_persalinan?.toDate) {
            tgl = p.tgl_persalinan.toDate();
          } else if (p.tgl_persalinan) {
            tgl = new Date(p.tgl_persalinan);
          }
          if (!tgl || isNaN(tgl)) continue;

          const monthKey = getMonthString(tgl);

          if (!statsByBidan[idBidan].by_month[monthKey]) {
            statsByBidan[idBidan].by_month[monthKey] = {
              persalinan: { total: 0 }
            };
          }

          statsByBidan[idBidan].by_month[monthKey].persalinan.total++;
        }
      });

      const batch = db.batch();
      for (const [idBidan, stats] of Object.entries(statsByBidan)) {
        const ref = db.collection("statistics").doc(idBidan);
        const doc = await ref.get();
        const existing = doc.exists ? doc.data() : {};
        const byMonth = existing.by_month || {};

        for (const [month, counts] of Object.entries(stats.by_month)) {
          if (!byMonth[month]) byMonth[month] = {};
          if (!byMonth[month].persalinan) byMonth[month].persalinan = { total: 0 };

          byMonth[month].persalinan.total = counts.persalinan.total;
        }

        batch.set(
          ref,
          { ...existing, by_month: byMonth },
          { merge: true }
        );
      }

      await batch.commit();

      res.status(200).json({
        success: true,
        message: "Recalculated persalinan stats",
        statsByBidan,
      });
    } catch (error) {
      console.error("Error recalculating persalinan stats:", error);
      res.status(500).json({ success: false, error: error.message });
    }
  }
);
