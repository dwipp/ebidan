import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { db } from "../firebase.js";
import { getMonthString } from "../helpers.js";

const REGION = "asia-southeast2";

export const incrementKehamilanCount = onDocumentCreated(
  { document: "kehamilan/{kehamilanId}", region: REGION },
  async (event) => {
    const kehamilanData = event.data?.data();
    if (!kehamilanData || !kehamilanData.id_bidan) return;

    const idBidan = kehamilanData.id_bidan;
    const statsRef = db.doc(`statistics/${idBidan}`);

    // ambil tanggal dari field created_at di dokumen kehamilan
    let currentMonth = null;
    if (kehamilanData.created_at?.toDate) {
      currentMonth = getMonthString(kehamilanData.created_at.toDate());
    } else if (kehamilanData.created_at) {
      currentMonth = getMonthString(new Date(kehamilanData.created_at));
    } else {
      // fallback jika tidak ada created_at
      currentMonth = getMonthString(new Date());
    }

    await db.runTransaction(async (t) => {
      const doc = await t.get(statsRef);

      if (!doc.exists) {
        t.set(statsRef, {
          kehamilan: { all_bumil_count: 1 },
          last_updated_month: currentMonth,
          by_month: {
            [currentMonth]: { kehamilan: { total: 1 } }
          }
        });
        console.log(`Created new statistics for bidan: ${idBidan}, month: ${currentMonth}`);
        return;
      }

      const data = doc.data();
      const kehamilan = data.kehamilan || { all_bumil_count: 0 };
      const byMonth = data.by_month || {};

      // pastikan struktur by_month ada
      if (!byMonth[currentMonth]) byMonth[currentMonth] = {};
      if (!byMonth[currentMonth].kehamilan) byMonth[currentMonth].kehamilan = { total: 0 };

      // increment total kehamilan
      byMonth[currentMonth].kehamilan.total++;

      // --- LOGIC BATAS 13 BULAN ---
      const months = Object.keys(byMonth).sort(); // YYYY-MM format -> urut ascending
      if (months.length > 13) {
        const oldestMonth = months[0];
        delete byMonth[oldestMonth];
        console.log(`Month limit exceeded. Deleted oldest month: ${oldestMonth} for bidan: ${idBidan}`);
      }

      t.set(statsRef, {
        ...data,
        kehamilan: { all_bumil_count: (kehamilan.all_bumil_count || 0) + 1 },
        last_updated_month: currentMonth,
        by_month: byMonth
      }, { merge: true });

      console.log(`Incremented kehamilan count for month: ${currentMonth}, bidan: ${idBidan}`);
    });
  }
);
