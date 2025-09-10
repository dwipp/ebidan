import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { db } from "../firebase.js";

const REGION = "asia-southeast2";

export const incrementKehamilanCount = onDocumentCreated(
  { document: "kehamilan/{kehamilanId}", region: REGION },
  async (event) => {
    const kehamilanData = event.data?.data();
    if (!kehamilanData || !kehamilanData.id_bidan) return;

    const idBidan = kehamilanData.id_bidan;
    const statsRef = db.doc(`statistics/${idBidan}`);
    const currentMonth = getMonthString(new Date());

    await db.runTransaction(async (t) => {
      const doc = await t.get(statsRef);

      if (!doc.exists) {
        t.set(statsRef, {
          bumil: { all_bumil_count: 1 },
          last_updated_month: currentMonth,
          by_month: {
            [currentMonth]: { kehamilan: { total: 1 } }
          }
        });
        return;
      }

      const data = doc.data();
      const bumil = data.bumil || { all_bumil_count: 0 };
      const byMonth = data.by_month || {};

      // pastikan struktur by_month ada
      if (!byMonth[currentMonth]) byMonth[currentMonth] = {};
      if (!byMonth[currentMonth].kehamilan) byMonth[currentMonth].kehamilan = { total: 0 };

      // increment total kehamilan
      byMonth[currentMonth].kehamilan.total++;

      t.set(statsRef, {
        ...data,
        bumil: { all_bumil_count: (bumil.all_bumil_count || 0) + 1 },
        last_updated_month: currentMonth,
        by_month: byMonth
      }, { merge: true });
    });
  }
);
