import { onDocumentUpdated } from "firebase-functions/v2/firestore";
import { db } from "../firebase.js";
import { getMonthString } from "../helpers.js";

const REGION = "asia-southeast2";

export const incrementPersalinanCount = onDocumentUpdated(
  {
    document: "kehamilan/{kehamilanId}",
    region: REGION,
  },
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();

    if (!before || !after) return;

    const beforePersalinan = before.persalinan || [];
    const afterPersalinan = after.persalinan || [];

    // hanya jalan kalau ada item baru
    if (afterPersalinan.length <= beforePersalinan.length) return;

    // ambil item baru
    const newPersalinan = afterPersalinan.slice(beforePersalinan.length);

    const idBidan = after.id_bidan;
    if (!idBidan) return;

    const statsRef = db.doc(`statistics/${idBidan}`);

    await db.runTransaction(async (t) => {
      const doc = await t.get(statsRef);
      const existing = doc.exists ? doc.data() : {};
      const byMonth = existing.by_month || {};

      for (const p of newPersalinan) {
        if (!p.tgl_persalinan) continue;

        const monthKey = getMonthString(p.tgl_persalinan.toDate());

        // pastikan struktur bulan & persalinan ada
        if (!byMonth[monthKey]) byMonth[monthKey] = {};
        if (!byMonth[monthKey].persalinan) byMonth[monthKey].persalinan = { total: 0 };

        // increment total persalinan
        byMonth[monthKey].persalinan.total++;

        // --- LOGIC BATAS 13 BULAN ---
        const months = Object.keys(byMonth).sort(); // YYYY-MM format -> urut ascending
        if (months.length > 13) {
          const oldestMonth = months[0];
          delete byMonth[oldestMonth];
          console.log(`Month limit exceeded. Deleted oldest month: ${oldestMonth} for bidan: ${idBidan}`);
        }

        console.log(`Incremented persalinan count for month: ${monthKey}, bidan: ${idBidan}`);
      }

      // --- Simpan ke Firestore ---
      t.set(statsRef, {
        ...existing,
        by_month: byMonth,
        last_updated_month: newPersalinan.length ? getMonthString(newPersalinan[newPersalinan.length - 1].tgl_persalinan.toDate()) : getMonthString(new Date())
      }, { merge: true });
    });
  }
);
