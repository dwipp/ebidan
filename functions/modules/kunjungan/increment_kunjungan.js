import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { getMonthString, parseUK, safeIncrement } from "../helpers.js";
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
    const isUsg = !!dataKunjungan.tgl_periksa_usg;
    const kontrolDokter = dataKunjungan.kontrol_dokter;
    const isK1_4t = dataKunjungan.k1_4t === true;
    const periksaUsg = dataKunjungan.periksa_usg === true;

    // Ambil bulan dari created_at dokumen kunjungan
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

      // --- Pastikan bulan dan objek kunjungan sudah ada ---
      if (!byMonth[currentMonth]) {
        byMonth[currentMonth] = { kunjungan: {}, resti: {} };
      } else {
        if (!byMonth[currentMonth].kunjungan) byMonth[currentMonth].kunjungan = {};
        if (!byMonth[currentMonth].resti) byMonth[currentMonth].resti = {};
      }

      const kunjungan = byMonth[currentMonth].kunjungan;
      const resti = byMonth[currentMonth].resti;

      // --- Update counts sesuai status ---
      safeIncrement(kunjungan, "total");

      if (status === "k1") {
        safeIncrement(kunjungan, "k1");
        if (uk <= 12) {
          safeIncrement(kunjungan, "k1_murni");
          if (isUsg) safeIncrement(kunjungan, "k1_murni_usg");
          if (kontrolDokter) safeIncrement(kunjungan, "k1_murni_dokter");
        } else {
          safeIncrement(kunjungan, "k1_akses");
          if (isUsg) safeIncrement(kunjungan, "k1_akses_usg");
          if (kontrolDokter) safeIncrement(kunjungan, "k1_akses_dokter");
        }
        if (isUsg) safeIncrement(kunjungan, "k1_usg");
        if (kontrolDokter) safeIncrement(kunjungan, "k1_dokter");
        if (isK1_4t) safeIncrement(kunjungan, "k1_4t");

        // --- Cek tekanan darah untuk resti hipertensi ---
        if (typeof dataKunjungan.td === "string") {
          const [sistolStr, diastolStr] = dataKunjungan.td.split("/").map(s => s.trim());
          const sistol = parseInt(sistolStr, 10);
          const diastol = parseInt(diastolStr, 10);

          if ((sistol && sistol >= 140) || (diastol && diastol >= 90)) {
            safeIncrement(resti, "hipertensi");
          }
        }
      } else if (status === "k2") {
        safeIncrement(kunjungan, "k2");
      } else if (status === "k3") {
        safeIncrement(kunjungan, "k3");
      } else if (status === "k4") {
        safeIncrement(kunjungan, "k4");
      } else if (status === "k5") {
        safeIncrement(kunjungan, "k5");
        if (periksaUsg) safeIncrement(kunjungan, "k5_usg");
      } else if (status === "k6") {
        safeIncrement(kunjungan, "k6");
        if (periksaUsg) safeIncrement(kunjungan, "k6_usg");
      }

      // --- LOGIC BATAS 13 BULAN ---
      const months = Object.keys(byMonth).sort(); // YYYY-MM format -> urut ascending
      if (months.length > 13) {
        const oldestMonth = months[0];
        delete byMonth[oldestMonth];
        console.log(`Month limit exceeded. Deleted oldest month: ${oldestMonth} for bidan: ${idBidan}`);
      }

      // --- Simpan ke Firestore ---
      t.set(
        statsRef,
        {
          ...existing,
          by_month: byMonth,
          last_updated_month: currentMonth,
        },
        { merge: true }
      );

      console.log(`Incremented kunjungan count for month: ${currentMonth}, bidan: ${idBidan}`);
    });
  }
);
