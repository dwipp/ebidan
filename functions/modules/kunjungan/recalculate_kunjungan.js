import { onRequest } from "firebase-functions/v2/https";
import { getMonthString, parseUK } from "../helpers.js";
import { db } from "../firebase.js";

const REGION = "asia-southeast2";

export const recalculateKunjunganStats = onRequest({ region: REGION }, async (req, res) => {
  try {
    const snapshot = await db.collection("kunjungan").get();
    const statsByBidan = {};

    snapshot.forEach(doc => {
      const data = doc.data();
      if (!data.id_bidan || !data.status) return;

      const idBidan = data.id_bidan;
      const status = data.status.toLowerCase();
      const uk = data.uk ? parseUK(data.uk) : 0;

      if (!statsByBidan[idBidan]) statsByBidan[idBidan] = { by_month: {} };

      const createdAt = data.createdAt?.toDate ? data.createdAt.toDate() : new Date();
      const monthKey = getMonthString(createdAt);

      if (!statsByBidan[idBidan].by_month[monthKey]) {
        statsByBidan[idBidan].by_month[monthKey] = { 
          kunjungan: { 
            total:0, 
            k1:0, 
            k2:0, 
            k3:0, 
            k4:0, 
            k5:0, 
            k6:0, 
            k1_murni:0, 
            k1_akses:0 
          } 
        };
      }

      const kunjungan = statsByBidan[idBidan].by_month[monthKey].kunjungan;

      // Hitung sesuai status
      kunjungan.total++;
      if (status === "k1") {
        kunjungan.k1++;
        if (uk <= 12) kunjungan.k1_murni++;
        else kunjungan.k1_akses++;
      }
      if (status === "k2") kunjungan.k2++;
      if (status === "k3") kunjungan.k3++;
      if (status === "k4") kunjungan.k4++;
      if (status === "k5") kunjungan.k5++;
      if (status === "k6") kunjungan.k6++;
    });

    const batch = db.batch();
    const currentMonth = getMonthString(new Date());

    for (const [idBidan, stats] of Object.entries(statsByBidan)) {
      const ref = db.doc(`statistics/${idBidan}`);
      const doc = await ref.get();
      const existing = doc.exists ? doc.data() : {};
      const byMonth = existing.by_month || {};

      for (const [month, counts] of Object.entries(stats.by_month)) {
        if (!byMonth[month]) byMonth[month] = { 
          kunjungan: { 
            total:0, 
            k1:0, 
            k2:0, 
            k3:0, 
            k4:0, 
            k5:0, 
            k6:0, 
            k1_murni:0, 
            k1_akses:0 
          } 
        };

        // gabungkan hasil baru
        byMonth[month].kunjungan = {
          ...byMonth[month].kunjungan,
          ...counts.kunjungan
        };
      }

      batch.set(ref, { 
        ...existing, 
        by_month: byMonth,
        last_updated_month: currentMonth,
      }, { merge: true });
    }

    await batch.commit();
    res.status(200).send({ message: "Kunjungan recalculation complete", statsByBidan });
  } catch (error) {
    console.error("Recalculation error:", error);
    res.status(500).send({ error: error.message });
  }
});
