import { onDocumentCreated, onDocumentDeleted } from "firebase-functions/v2/firestore";
import { db } from "../firebase.js";

const REGION = "asia-southeast2";

export const decrementKehamilanCount = onDocumentDeleted(
  { document: "kehamilan/{kehamilanId}", region: REGION },
  async (event) => {
    const kehamilanData = event.data?.data();
    if (!kehamilanData || !kehamilanData.id_bidan) return;

    const idBidan = kehamilanData.id_bidan;
    const statsRef = db.doc(`statistics/${idBidan}`);
    const currentMonth = getMonthString(new Date());

    await db.runTransaction(async (t) => {
      const doc = await t.get(statsRef);
      if (!doc.exists) return;

      const data = doc.data();
      const bumil = data.bumil || { all_bumil_count: 0 };
      const byMonth = data.by_month || {};

      // pastikan struktur by_month ada
      if (!byMonth[currentMonth]) byMonth[currentMonth] = {};
      if (!byMonth[currentMonth].kehamilan) byMonth[currentMonth].kehamilan = { total: 0 };

      // decrement total kehamilan, tetap aman dari negatif
      byMonth[currentMonth].kehamilan.total = Math.max((byMonth[currentMonth].kehamilan.total || 0) - 1, 0);

      t.set(statsRef, {
        ...data,
        bumil: { all_bumil_count: Math.max((bumil.all_bumil_count || 0) - 1, 0) },
        last_updated_month: currentMonth,
        by_month: byMonth
      }, { merge: true });
    });
  }
);
