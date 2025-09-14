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
      const latestMonthByBidan = {}; // track bulan terakhir per bidan

      snapshot.forEach((doc) => {
        const data = doc.data();
        if (!data.id_bidan) return;

        const idBidan = data.id_bidan;
        if (!statsByBidan[idBidan]) statsByBidan[idBidan] = { by_month: {} };

        const persalinanList = Array.isArray(data.persalinan) ? data.persalinan : [];
        for (const p of persalinanList) {
          let tgl;
          if (p.tgl_persalinan?.toDate) tgl = p.tgl_persalinan.toDate();
          else if (p.tgl_persalinan) tgl = new Date(p.tgl_persalinan);
          if (!tgl || isNaN(tgl)) continue;

          const monthKey = getMonthString(tgl);

          // track latest month per bidan
          if (!latestMonthByBidan[idBidan] || monthKey > latestMonthByBidan[idBidan]) {
            latestMonthByBidan[idBidan] = monthKey;
          }

          if (!statsByBidan[idBidan].by_month[monthKey])
            statsByBidan[idBidan].by_month[monthKey] = { persalinan: { total: 0 } };

          statsByBidan[idBidan].by_month[monthKey].persalinan.total++;
        }
      });

      const batch = db.batch();
      const now = new Date();
      const startMonthDate = new Date(now.getFullYear(), now.getMonth() - 12, 1); // 13 bulan terakhir
      const startMonthKey = getMonthString(startMonthDate);

      for (const [idBidan, stats] of Object.entries(statsByBidan)) {
        const ref = db.collection("statistics").doc(idBidan);
        const doc = await ref.get();
        const existing = doc.exists ? doc.data() : {};
        const byMonth = {};

        // gabungkan existing.by_month yang masih dalam 13 bulan terakhir
        if (existing.by_month) {
          for (const [month, counts] of Object.entries(existing.by_month)) {
            if (month >= startMonthKey) {
              byMonth[month] = counts;
            }
          }
        }

        // tambahkan data baru dari stats
        for (const [month, counts] of Object.entries(stats.by_month)) {
          if (month < startMonthKey) continue; // skip bulan lama
          if (!byMonth[month]) byMonth[month] = { persalinan: { total: 0 } };
          byMonth[month].persalinan.total = counts.persalinan.total;
        }

        // set last_updated_month sesuai bulan terbaru
        const lastUpdatedMonth = latestMonthByBidan[idBidan] || getMonthString(new Date());

        batch.set(
          ref,
          { ...existing, by_month: byMonth, last_updated_month: lastUpdatedMonth },
          { merge: true }
        );

        console.log(`Recalculated persalinan stats for bidan: ${idBidan}, last month: ${lastUpdatedMonth}`);
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
