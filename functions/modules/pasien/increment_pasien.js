import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { getMonthString } from "../helpers.js";
import { db, FieldValue } from "../firebase.js";

const REGION = "asia-southeast2";

export const incrementPasienCount = onDocumentCreated(
  { document: "bumil/{bumilId}", region: REGION },
  async (event) => {
    const bumilData = event.data?.data();
    if (!bumilData || !bumilData.id_bidan) return;

    const idBidan = bumilData.id_bidan;
    const statsRef = db.doc(`statistics/${idBidan}`);
    const currentMonth = getMonthString(new Date());

    await db.runTransaction(async (t) => {
      const doc = await t.get(statsRef);
      const existing = doc.exists ? doc.data() : {};
      const byMonth = existing.by_month || {};
      const skippedMonths = [];

      // --- LOGIC BATAS 13 BULAN ---
      const months = Object.keys(byMonth).sort(); // YYYY-MM ascending
      if (months.length >= 13 && !byMonth[currentMonth]) {
        const oldestMonth = months[0];
        delete byMonth[oldestMonth];
        skippedMonths.push(oldestMonth);
        console.log(`Month limit exceeded. Deleted oldest month: ${oldestMonth} for bidan: ${idBidan}`);
      }

      // --- Simpan ke Firestore dengan increment ---
      const update = {
        [`by_month.${currentMonth}.pasien.total`]: FieldValue.increment(1),
        last_updated_month: currentMonth,
      };

      t.set(statsRef, { ...existing, ...update, by_month: byMonth }, { merge: true });

      console.log(
        `Incremented pasien count for month: ${currentMonth}, bidan: ${idBidan}. ` +
        `Total bulan tersimpan: ${Object.keys(byMonth).length}, skipped: ${skippedMonths.join(", ")}`
      );
    });
  }
);
