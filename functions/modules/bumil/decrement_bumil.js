import { onDocumentDeleted } from "firebase-functions/v2/firestore";
import { getMonthString } from "../helpers.js";
import { db } from "../firebase.js";

const REGION = "asia-southeast2";

export const decrementBumilCount = onDocumentDeleted(
  { document: "bumil/{bumilId}", region: REGION },
  async (event) => {
    const bumilData = event.data?.data();
    if (!bumilData || !bumilData.id_bidan) return;

    const idBidan = bumilData.id_bidan;
    const statsRef = db.doc(`statistics/${idBidan}`);
    const currentMonth = getMonthString(new Date());

    await db.runTransaction(async (t) => {
      const doc = await t.get(statsRef);
      if (!doc.exists) return;

      const data = doc.data();
      const bumil = data.bumil || { all_bumil_count: 0 };
      const byMonth = data.by_month || {};

      // pastikan struktur ada
      if (!byMonth[currentMonth]) byMonth[currentMonth] = {};
      if (!byMonth[currentMonth].bumil) byMonth[currentMonth].bumil = { total: 0 };

      // decrement, tapi tidak boleh negatif
      byMonth[currentMonth].bumil.total = Math.max((byMonth[currentMonth].bumil.total || 0) - 1, 0);

      const newAllCount = Math.max((bumil.all_bumil_count || 0) - 1, 0);

      t.set(statsRef, {
        ...data,
        bumil: { 
          all_bumil_count: newAllCount
        },
        last_updated_month: currentMonth,
        by_month: byMonth
      }, { merge: true });
    });
  }
);
