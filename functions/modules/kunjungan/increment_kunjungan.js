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

    // ambil bulan dari created_at dokumen kunjungan
    let currentMonth;
    if (dataKunjungan.created_at?.toDate) {
      currentMonth = getMonthString(dataKunjungan.created_at.toDate());
    } else if (dataKunjungan.created_at) {
      currentMonth = getMonthString(new Date(dataKunjungan.created_at));
    } else {
      currentMonth = getMonthString(new Date()); // fallback
    }

    const statsRef = db.doc(`statistics/${idBidan}`);

    await db.runTransaction(async (t) => {
      const doc = await t.get(statsRef);
      const existing = doc.exists ? doc.data() : {};
      const byMonth = existing.by_month || {};

      // pastikan bulan dan objek kunjungan sudah ada
      if (!byMonth[currentMonth]) {
        byMonth[currentMonth] = { 
          kunjungan: { 
            total: 0, 
            k1: 0, 
            k2: 0, 
            k3: 0, 
            k4: 0, 
            k5: 0, 
            k6: 0, 
            k1_murni: 0, 
            k1_akses: 0 
          } 
        };
      } else if (!byMonth[currentMonth].kunjungan) {
        byMonth[currentMonth].kunjungan = { 
          total: 0, 
          k1: 0, 
          k2: 0, 
          k3: 0, 
          k4: 0, 
          k5: 0, 
          k6: 0, 
          k1_murni: 0, 
          k1_akses: 0 
        };
      }

      const kunjungan = byMonth[currentMonth].kunjungan;

      // Update sesuai status
      kunjungan.total++;
      if (status === "k1") {
        kunjungan.k1++;
        if (uk <= 12) kunjungan.k1_murni++;
        else kunjungan.k1_akses++;
      } else if (status === "k2") kunjungan.k2++;
      else if (status === "k3") kunjungan.k3++;
      else if (status === "k4") kunjungan.k4++;
      else if (status === "k5") kunjungan.k5++;
      else if (status === "k6") kunjungan.k6++;

      t.set(statsRef, { 
        ...existing, 
        by_month: byMonth,
        last_updated_month: currentMonth
      }, { merge: true });
    });
  }
);
