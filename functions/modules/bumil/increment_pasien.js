import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { getMonthString, safeIncrement } from "../helpers.js";
import { db } from "../firebase.js";

const REGION = "asia-southeast2";

export const incrementPasienCount = onDocumentCreated(
  { document: "bumil/{bumilId}", region: REGION },
  async (event) => {
    const bumilData = event.data?.data();
    if (!bumilData || !bumilData.id_bidan) return;

    const idBidan = bumilData.id_bidan;
    const statsRef = db.doc(`statistics/${idBidan}`);
    
    let currentMonth = null;
    if (bumilData.created_at?.toDate) {
      currentMonth = getMonthString(bumilData.created_at.toDate());
    } else if (bumilData.created_at) {
      currentMonth = getMonthString(new Date(bumilData.created_at));
    } else {
      currentMonth = getMonthString(new Date()); // fallback
    }

    await db.runTransaction(async (t) => {
      const doc = await t.get(statsRef);
      const existing = doc.exists ? doc.data() : {};
      const byMonth = existing.by_month || {};
      const skippedMonths = [];

      // --- Pastikan struktur by_month ada ---
      if (!byMonth[currentMonth]) byMonth[currentMonth] = { pasien: { total: 0 } };
      else if (!byMonth[currentMonth].pasien) byMonth[currentMonth].pasien = { total: 0 };

      // --- Increment pakai safeIncrement ---
      safeIncrement(byMonth[currentMonth].pasien, "total");

      // --- LOGIC BATAS 13 BULAN ---
      const months = Object.keys(byMonth).sort(); // YYYY-MM format -> urut ascending
      if (months.length > 13) {
        const oldestMonth = months[0];
        delete byMonth[oldestMonth];
        skippedMonths.push(oldestMonth);
        console.log(`Month limit exceeded. Deleted oldest month: ${oldestMonth} for bidan: ${idBidan}`);
      }

      // --- Simpan ke Firestore ---
      t.set(statsRef, {
        ...existing,
        last_updated_month: currentMonth,
        by_month: byMonth
      }, { merge: true });

      console.log(
        `Incremented pasien count for month: ${currentMonth}, bidan: ${idBidan}. Total bulan tersimpan: ${Object.keys(byMonth).length}, skipped: ${skippedMonths.join(", ")}`
      );
    });
  }
);
