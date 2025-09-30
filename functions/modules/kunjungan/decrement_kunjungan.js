import { onDocumentDeleted } from "firebase-functions/v2/firestore";
import { getMonthString, parseUK, safeDecrement } from "../helpers.js";
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
    const isUsg = !!dataKunjungan.tgl_periksa_usg;
    const kontrolDokter = dataKunjungan.kontrol_dokter;
    const isK1_4t = dataKunjungan.k1_4t === true;
    const isPeriksaUsg = dataKunjungan.periksa_usg === true;

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
      if (!doc.exists) return;

      const existing = doc.data();
      const byMonth = existing.by_month || {};

      // pastikan bulan & objek kunjungan ada
      if (!byMonth[currentMonth]) {
        byMonth[currentMonth] = { kunjungan: {}, resti: {} };
      } else {
        if (!byMonth[currentMonth].kunjungan) byMonth[currentMonth].kunjungan = {};
        if (!byMonth[currentMonth].resti) byMonth[currentMonth].resti = {};
      }

      const kunjungan = byMonth[currentMonth].kunjungan;
      const resti = byMonth[currentMonth].resti;

      // --- Update counts sesuai status ---
      safeDecrement(kunjungan, "total");

      if (status === "k1") {
        safeDecrement(kunjungan, "k1");
        if (uk <= 12) {
          safeDecrement(kunjungan, "k1_murni");
          if (isUsg) safeDecrement(kunjungan, "k1_murni_usg");
          if (kontrolDokter) safeDecrement(kunjungan, "k1_murni_dokter");
        } else {
          safeDecrement(kunjungan, "k1_akses");
          if (isUsg) safeDecrement(kunjungan, "k1_akses_usg");
          if (kontrolDokter) safeDecrement(kunjungan, "k1_akses_dokter");
        }
        if (isUsg) safeDecrement(kunjungan, "k1_usg");
        if (kontrolDokter) safeDecrement(kunjungan, "k1_dokter");
        if (isK1_4t) safeDecrement(kunjungan, "k1_4t");

        // --- Cek tekanan darah untuk resti hipertensi ---
        if (typeof dataKunjungan.td === "string") {
          const [sistolStr, diastolStr] = dataKunjungan.td.split("/").map(s => s.trim());
          const sistol = parseInt(sistolStr, 10);
          const diastol = parseInt(diastolStr, 10);

          if ((sistol && sistol >= 140) || (diastol && diastol >= 90)) {
            safeDecrement(resti, "hipertensi");
          }
        }

        // --- Cek obesitas berdasarkan BMI ---
        const bb = Number(dataKunjungan.bb);   // berat badan (kg)
        const tbCm = Number(dataKunjungan.tb); // tinggi badan (cm)

        if (bb > 0 && tbCm > 0) {
          const tbMeter = tbCm / 100;
          const bmi = bb / (tbMeter * tbMeter);
          if (bmi >= 25) {
            safeDecrement(resti, "obesitas");
          }
        }
      } else if (status === "k2") {
        safeDecrement(kunjungan, "k2");

      } else if (status === "k3") {
        safeDecrement(kunjungan, "k3");

      } else if (status === "k4") {
        safeDecrement(kunjungan, "k4");

      } else if (status === "k5") {
        safeDecrement(kunjungan, "k5");
        if (isPeriksaUsg) safeDecrement(kunjungan, "k5_usg");

      } else if (status === "k6") {
        safeDecrement(kunjungan, "k6");
        if (isPeriksaUsg) safeDecrement(kunjungan, "k6_usg");
      }

      // simpan hasil
      t.set(
        statsRef,
        {
          ...existing,
          by_month: byMonth,
          last_updated_month: currentMonth,
        },
        { merge: true }
      );

      console.log(`Decremented kunjungan count for month: ${currentMonth}, bidan: ${idBidan}`);
    });
  }
);
