import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { getMonthString } from "../helpers.js";
import { db } from "../firebase.js";

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
          last_updated_month: currentMonth,
          by_month: { 
            [currentMonth]: { 
              bumil: { total: 1 } 
            } 
          }
        });
        return;
      }

      const data = doc.data();
      const byMonth = data.by_month || {};

      // pastikan struktur ada
      if (!byMonth[currentMonth]) byMonth[currentMonth] = {};
      if (!byMonth[currentMonth].bumil) byMonth[currentMonth].bumil = { total: 0 };

      byMonth[currentMonth].bumil.total++;

      t.set(statsRef, {
        ...data,
        last_updated_month: currentMonth,
        by_month: byMonth
      }, { merge: true });
    });
  }
);
