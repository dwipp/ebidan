import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { getMonthString, parseUK } from "../helpers.js";
import { db } from "../firebase.js";

const REGION = "asia-southeast2";

export const incrementKunjunganCount = onDocumentCreated(
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
      const existing = doc.exists ? doc.data() : {};
      const byMonth = existing.by_month || {};

      // pastikan bulan dan objek kunjungan sudah ada
      if (!byMonth[currentMonth]) {
        byMonth[currentMonth] = { kunjungan: { k1:0, k4:0, k5:0, k6:0, k1_murni:0, k1_akses:0 } };
      } else if (!byMonth[currentMonth].kunjungan) {
        byMonth[currentMonth].kunjungan = { k1:0, k4:0, k5:0, k6:0, k1_murni:0, k1_akses:0 };
      }

      const kunjungan = byMonth[currentMonth].kunjungan;

      // Update sesuai status
      if (status === "k1") {
        kunjungan.k1++;
        if (uk <= 12) kunjungan.k1_murni++;
        else kunjungan.k1_akses++;
      }
      if (status === "k4") kunjungan.k4++;
      if (status === "k5") kunjungan.k5++;
      if (status === "k6") kunjungan.k6++;

      t.set(statsRef, { 
        ...existing, 
        by_month: byMonth,
        last_updated_month: currentMonth
      }, { merge: true });
    });
  }
);
