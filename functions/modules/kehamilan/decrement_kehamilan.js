import { onDocumentDeleted } from "firebase-functions/v2/firestore";
import { db } from "../firebase.js";
import { getMonthString, safeDecrement } from "../helpers.js";

const REGION = "asia-southeast2";

export const decrementKehamilanCount = onDocumentDeleted(
  { document: "kehamilan/{kehamilanId}", region: REGION },
  async (event) => {
    const kehamilanData = event.data?.data();
    if (!kehamilanData || !kehamilanData.id_bidan) return;

    const idBidan = kehamilanData.id_bidan;
    const statsRef = db.doc(`statistics/${idBidan}`);

    // ambil bulan dari created_at kehamilan
    let currentMonth;
    if (kehamilanData.created_at?.toDate) {
      currentMonth = getMonthString(kehamilanData.created_at.toDate());
    } else if (kehamilanData.created_at) {
      currentMonth = getMonthString(new Date(kehamilanData.created_at));
    } else {
      currentMonth = getMonthString(new Date()); // fallback
    }

    await db.runTransaction(async (t) => {
      const doc = await t.get(statsRef);
      if (!doc.exists) return;

      const data = doc.data();
      const kehamilan = data.kehamilan || { all_bumil_count: 0 };
      const byMonth = data.by_month || {};

      // pastikan struktur by_month ada
      if (!byMonth[currentMonth]) byMonth[currentMonth] = {};
      if (!byMonth[currentMonth].kehamilan) byMonth[currentMonth].kehamilan = { total: 0 };

      // decrement pakai safeDecrement
      safeDecrement(byMonth[currentMonth].kehamilan, "total");
      safeDecrement(kehamilan, "all_bumil_count");

      t.set(statsRef, {
        ...data,
        kehamilan,
        last_updated_month: currentMonth,
        by_month: byMonth
      }, { merge: true });
    });
  }
);
