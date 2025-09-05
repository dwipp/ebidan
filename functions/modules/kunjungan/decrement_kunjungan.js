import { onDocumentDeleted } from "firebase-functions/v2/firestore";
import { getMonthString, parseUK } from "../helpers.js";
import { db } from "../firebase.js";

const REGION = "asia-southeast2";

export const decrementKunjunganCount = onDocumentDeleted(
  { document: "kunjungan/{kunjunganId}", region: REGION },
  async (event) => {
    const dataKunjungan = event.data?.data();
    if (!dataKunjungan || !dataKunjungan.id_bidan || !dataKunjungan.status) return;

    const idBidan = dataKunjungan.id_bidan;
    const status = dataKunjungan.status.toLowerCase();
    const uk = dataKunjungan.uk ? parseUK(dataKunjungan.uk) : 0;

    const statsRef = db.doc(`statistics/${idBidan}`);
    const currentMonth = getMonthString(new Date());

    await db.runTransaction(async (t) => {
      const doc = await t.get(statsRef);
      if (!doc.exists) return;

      const existing = doc.data();
      const byMonth = existing.by_month || {};

      if (!byMonth[currentMonth]) byMonth[currentMonth] = { k1:0, k4:0, k5:0, k6:0, k1_murni:0, k1_akses:0 };

      // Update sesuai status
      if (status === "k1") {
        byMonth[currentMonth].k1 = Math.max(byMonth[currentMonth].k1 - 1, 0);
        if (uk <= 12) byMonth[currentMonth].k1_murni = Math.max(byMonth[currentMonth].k1_murni - 1, 0);
        else byMonth[currentMonth].k1_akses = Math.max(byMonth[currentMonth].k1_akses - 1, 0);
      }
      if (status === "k4") byMonth[currentMonth].k4 = Math.max(byMonth[currentMonth].k4 - 1, 0);
      if (status === "k5") byMonth[currentMonth].k5 = Math.max(byMonth[currentMonth].k5 - 1, 0);
      if (status === "k6") byMonth[currentMonth].k6 = Math.max(byMonth[currentMonth].k6 - 1, 0);

      t.set(statsRef, { ...existing, by_month: byMonth }, { merge: true });
    });
  }
);
