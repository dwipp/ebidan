// increment.js
import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { getFirestore } from "firebase-admin/firestore";
import { getMonthString } from "./helpers.js";
import { db } from "./firebase.js";

const REGION = "asia-southeast2";

export const incrementBumilCount = onDocumentCreated(
  { document: "bumil/{bumilId}", region: REGION },
  async (event) => {
    const bumilData = event.data?.data();
    if (!bumilData || !bumilData.id_bidan) return;

    const idBidan = bumilData.id_bidan;
    const statsRef = db.doc(`statistics/${idBidan}`);
    const currentMonth = getMonthString(new Date());

    await db.runTransaction(async (t) => {
      const doc = await t.get(statsRef);

      if (!doc.exists) {
        t.set(statsRef, {
          bumilTotal: 1,
          bumilThisMonth: 1,
          lastUpdatedMonth: currentMonth,
          bumilByMonth: { [currentMonth]: 1 }
        });
        return;
      }

      const data = doc.data();
      let bumilThisMonth = data.bumilThisMonth || 0;
      let bumilByMonth = data.bumilByMonth || {};

      if (data.lastUpdatedMonth !== currentMonth) {
        bumilThisMonth = 0;
      }

      bumilByMonth[currentMonth] = (bumilByMonth[currentMonth] || 0) + 1;

      t.update(statsRef, {
        bumilTotal: (data.bumilTotal || 0) + 1,
        bumilThisMonth: bumilThisMonth + 1,
        lastUpdatedMonth: currentMonth,
        bumilByMonth: bumilByMonth
      });
    });
  }
);
