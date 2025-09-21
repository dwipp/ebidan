import { onRequest } from "firebase-functions/v2/https";
import { db } from "../firebase.js";
import { getMonthString, safeIncrement } from "../helpers.js";

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

          if (!statsByBidan[idBidan].by_month[monthKey]) {
            statsByBidan[idBidan].by_month[monthKey] = { 
              persalinan: { total: 0 },
              kunjungan: { abortus: 0 },
            };
          } else {
            if (!statsByBidan[idBidan].by_month[monthKey].persalinan) {
              statsByBidan[idBidan].by_month[monthKey].persalinan = { total: 0 };
            }
            if (!statsByBidan[idBidan].by_month[monthKey].kunjungan) {
              statsByBidan[idBidan].by_month[monthKey].kunjungan = { abortus: 0 };
            }
          }

          // hitung total persalinan (pakai safeIncrement)
          safeIncrement(statsByBidan[idBidan].by_month[monthKey].persalinan, "total");

          // --- logika abortus (umur_kehamilan <= 20 minggu TANPA tambahan hari) ---
          if (p.status_bayi === "Abortus") {
            let umurMinggu = null;
            let lebihDariMinggu = false;

            if (typeof p.umur_kehamilan === "string") {
              // contoh: "20 minggu" atau "20 minggu 5 hari"
              const match = p.umur_kehamilan.match(/(\d+)\s*minggu(?:\s+(\d+)\s*hari)?/i);
              if (match) {
                umurMinggu = parseInt(match[1], 10);
                if (match[2]) {
                  const umurHari = parseInt(match[2], 10);
                  if (umurHari > 0) lebihDariMinggu = true;
                }
              }
            } else if (typeof p.umur_kehamilan === "number") {
              // kalau langsung angka (anggap minggu)
              umurMinggu = p.umur_kehamilan;
            }

            if (
              umurMinggu !== null &&
              umurMinggu >= 0 &&
              umurMinggu <= 20 &&
              !lebihDariMinggu
            ) {
              safeIncrement(statsByBidan[idBidan].by_month[monthKey].kunjungan, "abortus");
            }
          }
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
              if (!byMonth[month].kunjungan) byMonth[month].kunjungan = { abortus: 0 };
              if (typeof byMonth[month].kunjungan.abortus !== "number") {
                byMonth[month].kunjungan.abortus = 0;
              }
              if (!byMonth[month].persalinan) byMonth[month].persalinan = { total: 0 };
            }
          }
        }

        // tambahkan data baru dari stats
        for (const [month, counts] of Object.entries(stats.by_month)) {
          if (month < startMonthKey) continue; // skip bulan lama
          if (!byMonth[month]) byMonth[month] = { persalinan: { total: 0 }, kunjungan: { abortus: 0 } };

          byMonth[month].persalinan.total = counts.persalinan.total;
          byMonth[month].kunjungan.abortus = counts.kunjungan.abortus;
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
