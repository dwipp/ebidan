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

      // pastikan bulan dan objek kunjungan ada
      if (!byMonth[currentMonth]) {
        byMonth[currentMonth] = { 
          kunjungan: { 
            total:0, 
            k1:0, 
            k2:0, 
            k3:0, 
            k4:0, 
            k5:0, 
            k6:0, 
            k1_murni:0, 
            k1_akses:0 
          } 
        };
      } else if (!byMonth[currentMonth].kunjungan) {
        byMonth[currentMonth].kunjungan = { 
          total:0, 
          k1:0, 
          k2:0, 
          k3:0, 
          k4:0, 
          k5:0, 
          k6:0, 
          k1_murni:0, 
          k1_akses:0 
        };
      }

      const kunjungan = byMonth[currentMonth].kunjungan;

      // Update sesuai status dengan proteksi agar tidak minus
      kunjungan.total = Math.max(kunjungan.total - 1, 0);
      if (status === "k1") {
        kunjungan.k1 = Math.max(kunjungan.k1 - 1, 0);
        if (uk <= 12) {
          kunjungan.k1_murni = Math.max(kunjungan.k1_murni - 1, 0);
        } else {
          kunjungan.k1_akses = Math.max(kunjungan.k1_akses - 1, 0);
        }
      }
      if (status === "k2") kunjungan.k2 = Math.max(kunjungan.k2 - 1, 0);
      if (status === "k3") kunjungan.k3 = Math.max(kunjungan.k3 - 1, 0);
      if (status === "k4") kunjungan.k4 = Math.max(kunjungan.k4 - 1, 0);
      if (status === "k5") kunjungan.k5 = Math.max(kunjungan.k5 - 1, 0);
      if (status === "k6") kunjungan.k6 = Math.max(kunjungan.k6 - 1, 0);

      t.set(statsRef, { 
        ...existing, 
        by_month: byMonth,
        last_updated_month: currentMonth
      }, { merge: true });
    });
  }
);
