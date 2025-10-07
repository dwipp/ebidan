import { onRequest } from "firebase-functions/v2/https";
import { getMonthString } from "../helpers.js";
import { db } from "../firebase.js";

const REGION = "asia-southeast2";

// helper kecil untuk aman mengubah berbagai bentuk tanggal ke JS Date atau null
const toSafeDate = (v) => {
  if (!v) return null;
  // Firestore Timestamp
  if (typeof v?.toDate === "function") return v.toDate();
  // plain object like { seconds: ..., nanoseconds: ... }
  if (v.seconds && typeof v.seconds === "number") return new Date(v.seconds * 1000);
  // fallback: try parse string
  const d = new Date(v);
  return isNaN(d.getTime()) ? null : d;
};

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

      // --- Hitung pasien ---
      statsByBidan[idBidan].pasien.all_pasien_count++;
      if (!statsByBidan[idBidan].by_month[pasienMonthKey]) {
        statsByBidan[idBidan].by_month[pasienMonthKey] = { kehamilan: {}, pasien: {}, resti: {} };
      }
      statsByBidan[idBidan].by_month[pasienMonthKey].pasien.total = 
        (statsByBidan[idBidan].by_month[pasienMonthKey].pasien.total || 0) + 1;

      // --- Jika hamil ---
      if (data.is_hamil) {
        statsByBidan[idBidan].kehamilan.all_bumil_count++;
        if (!statsByBidan[idBidan].by_month[kehamilanMonthKey]) {
          statsByBidan[idBidan].by_month[kehamilanMonthKey] = { kehamilan: {}, pasien: {}, resti: {} };
        }

        statsByBidan[idBidan].by_month[kehamilanMonthKey].kehamilan.total = 
          (statsByBidan[idBidan].by_month[kehamilanMonthKey].kehamilan.total || 0) + 1;

        // --- Hitung resti.jarak_hamil ---
        const latestKehamilan = data.latest_kehamilan;
        const riwayat = data.riwayat || [];

        let lastBirthDate = null;
        if (riwayat.length > 0) {
          const birthDates = riwayat
            .map(r => toSafeDate(r.tgl_lahir))
            .filter(d => d !== null)
            .sort((a, b) => b.getTime() - a.getTime());

          if (birthDates.length > 0) {
            lastBirthDate = birthDates[0];
          }
        }

        const latestCreatedAt = toSafeDate(latestKehamilan?.created_at);

        if (lastBirthDate && latestCreatedAt) {
          const diffMs = latestCreatedAt.getTime() - lastBirthDate.getTime();
          const diffDays = Math.floor(diffMs / (1000 * 60 * 60 * 24));
          const diffYears = diffDays / 365;

          console.log(`rekalkulasi: idBidan=${idBidan} lastBirth=${lastBirthDate.toISOString()} latest=${latestCreatedAt.toISOString()} diffYears=${diffYears}`);

          if (diffYears < 2) {
            statsByBidan[idBidan].by_month[kehamilanMonthKey].resti.jarak_hamil =
              (statsByBidan[idBidan].by_month[kehamilanMonthKey].resti.jarak_hamil || 0) + 1;
          }
        }

        // === Hitung resti.bb_bayi_under_2500 ===
        const hasLowWeight = riwayat.some(r => {
          const bb = Number(r.berat_bayi);
          return !isNaN(bb) && bb > 0 && bb < 2500;
        });

        if (hasLowWeight) {
          statsByBidan[idBidan].by_month[kehamilanMonthKey].resti.bb_bayi_under_2500 =
            (statsByBidan[idBidan].by_month[kehamilanMonthKey].resti.bb_bayi_under_2500 || 0) + 1;
        }
      }
    });

    // --- Simpan ke Firestore ---
    const now = new Date();
    const startMonthDate = new Date(now.getFullYear(), now.getMonth() - 12, 1);
    const startMonthKey = getMonthString(startMonthDate);

    const batch = db.batch();

    for (const [idBidan, stats] of Object.entries(statsByBidan)) {
      const ref = db.doc(`statistics/${idBidan}`);
      const doc = await ref.get();
      const existing = doc.exists ? doc.data() : {};
      const byMonth = {};
      const skippedMonths = [];

      if (existing.by_month) {
        for (const [month, counts] of Object.entries(existing.by_month)) {
          if (month >= startMonthKey) {
            byMonth[month] = counts;
          } else {
            skippedMonths.push(month);
          }
        }
      }

      for (const [month, counts] of Object.entries(stats.by_month)) {
        if (month < startMonthKey) {
          skippedMonths.push(month);
          continue;
        }

        if (!byMonth[month]) byMonth[month] = { kehamilan: {}, pasien: {}, resti: {} };

        byMonth[month].kehamilan.total = counts.kehamilan.total ?? 0;
        byMonth[month].pasien.total = counts.pasien.total ?? 0;
        byMonth[month].resti.jarak_hamil = counts.resti?.jarak_hamil ?? 0;
        byMonth[month].resti.bb_bayi_under_2500 = counts.resti?.bb_bayi_under_2500 ?? 0;
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
    res.status(200).send({ message: "Recalculation complete with jarak_hamil + bb_bayi_under_2500", statsByBidan });

  } catch (error) {
    console.error("Recalculation error:", error);
    res.status(500).send({ error: error.message });
  }
});
