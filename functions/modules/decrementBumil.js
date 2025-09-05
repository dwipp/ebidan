// decrement.js
import { onDocumentDeleted } from "firebase-functions/v2/firestore";
import { getFirestore } from "firebase-admin/firestore";
import { getMonthString } from "./helpers.js";
import { db } from "./firebase.js";

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
      let bumilThisMonth = data.bumil_this_month || 0;
      let bumilByMonth = data.bumil_by_month || {};

      if (data.last_updated_month !== currentMonth) {
        bumilThisMonth = 0;
      }

      if (bumilByMonth[currentMonth]) {
        bumilByMonth[currentMonth] = Math.max(bumilByMonth[currentMonth] - 1, 0);
      }

      t.update(statsRef, {
        bumil_total: Math.max((data.bumil_total || 1) - 1, 0),
        bumil_this_month: Math.max(bumilThisMonth - 1, 0),
        last_updated_month: currentMonth,
        bumil_by_month: bumilByMonth
      });
    });
  }
);
