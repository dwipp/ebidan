import { onRequest } from "firebase-functions/v2/https";
import { getMonthString, parseUK } from "../helpers.js";
import { db } from "../firebase.js";

const REGION = "asia-southeast2";

export const recalculateKunjunganStats = onRequest({ region: REGION }, async (req, res) => {
  try {
    const snapshot = await db.collection("kunjungan").get();
    const statsByBidan = {};
    const latestMonthByBidan = {};

    snapshot.forEach(doc => {
      const data = doc.data();
      if (!data.id_bidan || !data.status) return;

      const idBidan = data.id_bidan;
      const status = data.status.toLowerCase();
      const uk = data.uk ? parseUK(data.uk) : 0;
      const isUsg = data.tgl_periksa_usg ? true : false;
      const kontrolDokter = data.kontrol_dokter;
      const isK1_4t = data.k1_4t === true;
      const periksaUsg = data.periksa_usg === true;

      if (!statsByBidan[idBidan]) statsByBidan[idBidan] = { by_month: {} };

      // Ambil bulan dari createdAt dokumen
      const createdAt = data.created_at?.toDate ? data.created_at.toDate() : new Date();
      const monthKey = getMonthString(createdAt);

      // Update latest month per bidan
      if (!latestMonthByBidan[idBidan] || monthKey > latestMonthByBidan[idBidan]) {
        latestMonthByBidan[idBidan] = monthKey;
      }

      if (!statsByBidan[idBidan].by_month[monthKey]) {
        statsByBidan[idBidan].by_month[monthKey] = { 
          kunjungan: { 
            total:0, k1:0, k2:0, k3:0, k4:0, k5:0, k6:0,
            k1_murni:0, k1_akses:0, k1_usg:0, k1_dokter:0, k1_4t:0,
            k5_usg:0, k6_usg:0, k1_murni_usg:0, k1_akses_usg:0, 
            k1_akses_dokter:0, k1_murni_dokter:0,
          } 
        };
      }

      const kunjungan = statsByBidan[idBidan].by_month[monthKey].kunjungan;

      // Hitung sesuai status
      kunjungan.total++;
      if (status === "k1") {
        kunjungan.k1++;
        if (uk <= 12) {
          kunjungan.k1_murni++;
          if (kontrolDokter) kunjungan.k1_murni_dokter++;
          if (isUsg) kunjungan.k1_murni_usg++;
        }
        else {
          kunjungan.k1_akses++;
          if (kontrolDokter) kunjungan.k1_akses_dokter++;
          if (isUsg) kunjungan.k1_akses_usg++;
        }
        if (isUsg) kunjungan.k1_usg++;
        if (kontrolDokter) kunjungan.k1_dokter++;
        if (isK1_4t) kunjungan.k1_4t++;
      }
      if (status === "k2") kunjungan.k2++;
      if (status === "k3") kunjungan.k3++;
      if (status === "k4") kunjungan.k4++;
      if (status === "k5") {
        kunjungan.k5++;
        if (periksaUsg) kunjungan.k5_usg++;
      }
      if (status === "k6") {
        kunjungan.k6++;
        if (periksaUsg) kunjungan.k6_usg++;
      }
    });

    const batch = db.batch();

    // Tentukan bulan awal 13 bulan terakhir
    const now = new Date();
    // StartMonthDate = 12 bulan sebelum bulan ini, termasuk bulan ini
    const startMonthDate = new Date(now.getFullYear(), now.getMonth() - 12, 1); 
    const startMonthKey = getMonthString(startMonthDate);

    for (const [idBidan, stats] of Object.entries(statsByBidan)) {
      const ref = db.doc(`statistics/${idBidan}`);
      const doc = await ref.get();
      const existing = doc.exists ? doc.data() : {};
      let byMonth = existing.by_month || {};
      const skippedMonths = [];

      // Filter existing.by_month agar tetap dalam 13 bulan terakhir
      byMonth = Object.entries(byMonth)
        .filter(([month]) => month >= startMonthKey)
        .reduce((acc, [month, counts]) => {
          acc[month] = counts;
          return acc;
        }, {});
      skippedMonths.push(...Object.keys(existing.by_month).filter(month => month < startMonthKey));

      // Merge data baru dari stats
      for (const [month, counts] of Object.entries(stats.by_month)) {
        if (month < startMonthKey) {
          skippedMonths.push(month);
          continue;
        }
        if (!byMonth[month]) {
          byMonth[month] = { 
            kunjungan: { 
              total:0, k1:0, k2:0, k3:0, k4:0, k5:0, k6:0,
              k1_murni:0, k1_akses:0, k1_usg:0, k1_dokter:0, k1_4t:0,
              k5_usg:0, k6_usg:0, k1_murni_usg:0, k1_akses_usg:0, 
              k1_akses_dokter:0, k1_murni_dokter:0,
            } 
          };
        }
        byMonth[month].kunjungan = { ...byMonth[month].kunjungan, ...counts.kunjungan };
      }

      // Urutkan bulan ascending sebelum disimpan
      byMonth = Object.fromEntries(
        Object.entries(byMonth).sort(([a], [b]) => a.localeCompare(b))
      );

      batch.set(ref, { 
        ...existing, 
        by_month: byMonth,
        last_updated_month: latestMonthByBidan[idBidan] || getMonthString(new Date()),
      }, { merge: true });

      console.log(`Bidan: ${idBidan} | Total bulan tersimpan: ${Object.keys(byMonth).length} | Bulan terbaru: ${latestMonthByBidan[idBidan]} | Bulan di-skip: ${skippedMonths.join(", ")}`);
    }

    await batch.commit();
    res.status(200).send({ message: "Kunjungan recalculation complete", statsByBidan });

  } catch (error) {
    console.error("Recalculation error:", error);
    res.status(500).send({ error: error.message });
  }
});
