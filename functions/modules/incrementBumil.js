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
          bumil_total: 1,
          bumil_this_month: 1,
          last_updated_month: currentMonth,
          bumil_by_month: { [currentMonth]: 1 }
        });
        return;
      }

      const data = doc.data();
      let bumilThisMonth = data.bumil_this_month || 0;
      let bumilByMonth = data.bumil_by_month || {};

      if (data.last_updated_month !== currentMonth) {
        bumilThisMonth = 0;
      }

      bumilByMonth[currentMonth] = (bumilByMonth[currentMonth] || 0) + 1;

      t.update(statsRef, {
        bumil_total: (data.bumil_total || 0) + 1,
        bumil_this_month: bumilThisMonth + 1,
        last_updated_month: currentMonth,
        bumil_by_month: bumilByMonth
      });
    });
  }
);
