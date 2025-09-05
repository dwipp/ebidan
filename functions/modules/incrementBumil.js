// increment.js
import { onDocumentCreated } from "firebase-functions/v2/firestore";
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
          bumil: {
            bumil_total: 1,
            bumil_this_month: 1
          },
          last_updated_month: currentMonth,
          by_month: {
            [currentMonth]: { bumil: 1 }
          }
        });
        return;
      }

      const data = doc.data();
      const bumil = data.bumil || { bumil_total: 0, bumil_this_month: 0 };
      const byMonth = data.by_month || {};

      // Reset bulan baru
      let bumilThisMonth = (data.last_updated_month === currentMonth ? bumil.bumil_this_month : 0);

      // Increment by_month
      if (!byMonth[currentMonth]) {
        byMonth[currentMonth] = { bumil: 0 };
      }
      byMonth[currentMonth].bumil++;

      t.update(statsRef, {
        bumil: {
          bumil_total: bumil.bumil_total + 1,
          bumil_this_month: bumilThisMonth + 1
        },
        last_updated_month: currentMonth,
        by_month: byMonth
      });
    });
  }
);
