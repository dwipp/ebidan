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
      let bumilThisMonth = data.bumilThisMonth || 0;
      let bumilByMonth = data.bumilByMonth || {};

      if (data.lastUpdatedMonth !== currentMonth) {
        bumilThisMonth = 0;
      }

      if (bumilByMonth[currentMonth]) {
        bumilByMonth[currentMonth] = Math.max(bumilByMonth[currentMonth] - 1, 0);
      }

      t.update(statsRef, {
        bumilTotal: Math.max((data.bumilTotal || 1) - 1, 0),
        bumilThisMonth: Math.max(bumilThisMonth - 1, 0),
        lastUpdatedMonth: currentMonth,
        bumilByMonth: bumilByMonth
      });
    });
  }
);
