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
          kehamilan: { all_bumil_count: 0 },
          pasien: { all_pasien_count: 0 },
          by_month: {},
          latestMonth: null
        };
      }

      // --- Tentukan bulan untuk pasien dan kehamilan ---
      const createdAt = data.created_at?.toDate ? data.created_at.toDate() : new Date();
      const pasienMonthKey = getMonthString(createdAt);

      let kehamilanMonthKey = pasienMonthKey;
      if (data.latest_kehamilan?.created_at?.toDate) {
        kehamilanMonthKey = getMonthString(data.latest_kehamilan.created_at.toDate());
      } else if (data.latest_kehamilan?.created_at) {
        kehamilanMonthKey = getMonthString(new Date(data.latest_kehamilan.created_at));
      }

      // update latestMonth
      const updateLatest = (monthKey) => {
        if (!statsByBidan[idBidan].latestMonth || monthKey > statsByBidan[idBidan].latestMonth) {
          statsByBidan[idBidan].latestMonth = monthKey;
        }
      };
      updateLatest(pasienMonthKey);
      if (data.is_hamil) updateLatest(kehamilanMonthKey);

      // hitung semua pasien
      statsByBidan[idBidan].pasien.all_pasien_count++;
      if (!statsByBidan[idBidan].by_month[pasienMonthKey]) {
        statsByBidan[idBidan].by_month[pasienMonthKey] = { kehamilan: { total: 0 }, pasien: { total: 0 } };
      }
      statsByBidan[idBidan].by_month[pasienMonthKey].pasien.total++;

      // jika hamil
      if (data.is_hamil) {
        statsByBidan[idBidan].kehamilan.all_bumil_count++;
        if (!statsByBidan[idBidan].by_month[kehamilanMonthKey]) {
          statsByBidan[idBidan].by_month[kehamilanMonthKey] = { kehamilan: { total: 0 }, pasien: { total: 0 } };
        }
        statsByBidan[idBidan].by_month[kehamilanMonthKey].kehamilan.total++;
      }
    });

    // --- Tentukan bulan awal 13 bulan terakhir ---
    // StartMonthDate = 12 bulan sebelum bulan ini (termasuk bulan ini)
    const now = new Date();
    const startMonthDate = new Date(now.getFullYear(), now.getMonth() - 12, 1); // Bulan paling awal yang disimpan (YYYY-MM-01)
    const startMonthKey = getMonthString(startMonthDate);

    const batch = db.batch();

    for (const [idBidan, stats] of Object.entries(statsByBidan)) {
      const ref = db.doc(`statistics/${idBidan}`);
      const doc = await ref.get();
      const existing = doc.exists ? doc.data() : {};
      const byMonth = {};
      const skippedMonths = [];

      // gabungkan existing.by_month yang masih dalam 13 bulan terakhir
      if (existing.by_month) {
        for (const [month, counts] of Object.entries(existing.by_month)) {
          if (month >= startMonthKey) {
            byMonth[month] = counts;
          } else {
            skippedMonths.push(month);
          }
        }
      }

      // tambahkan data baru dari stats
      for (const [month, counts] of Object.entries(stats.by_month)) {
        if (month < startMonthKey) {
          skippedMonths.push(month);
          continue; // skip bulan di luar 13 bulan terakhir
        }
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
        last_updated_month: stats.latestMonth ?? getMonthString(new Date()),
        by_month: byMonth
      }, { merge: true });

      console.log(`Bidan: ${idBidan} | Total bulan tersimpan: ${Object.keys(byMonth).length} | Bulan terbaru: ${stats.latestMonth} | Bulan di-skip: ${skippedMonths.join(", ")}`);
    }

    await batch.commit();
    res.status(200).send({ message: "Recalculation complete", statsByBidan });

  } catch (error) {
    console.error("Recalculation error:", error);
    res.status(500).send({ error: error.message });
  }
});
