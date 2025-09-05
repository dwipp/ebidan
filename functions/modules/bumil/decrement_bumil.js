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
      const bumil = data.bumil || { bumil_total: 0, bumil_this_month: 0 };
      const byMonth = data.by_month || {};

      const bumilThisMonth = data.last_updated_month === currentMonth ? bumil.bumil_this_month : 0;

      if (!byMonth[currentMonth]) byMonth[currentMonth] = { bumil: 0 };
      byMonth[currentMonth].bumil = Math.max(byMonth[currentMonth].bumil - 1, 0);

      t.set(statsRef, {
        ...data,
        bumil: { bumil_total: Math.max(bumil.bumil_total - 1, 0), bumil_this_month: Math.max(bumilThisMonth - 1, 0) },
        last_updated_month: currentMonth,
        by_month: byMonth
      }, { merge: true });
    });
  }
);
