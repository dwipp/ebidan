import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { getMonthString, parseUK } from "../helpers.js";
import { db, FieldValue } from "../firebase.js";

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

      // pastikan struktur dasar bulan ada
      if (!byMonth[currentMonth]) byMonth[currentMonth] = {};
      if (!byMonth[currentMonth].kunjungan) byMonth[currentMonth].kunjungan = {};

      // build update object
      const update = {
        [`by_month.${currentMonth}.kunjungan.total`]: FieldValue.increment(1),
      };

      if (status === "k1") {
        update[`by_month.${currentMonth}.kunjungan.k1`] = FieldValue.increment(1);
        if (uk <= 12) {
          update[`by_month.${currentMonth}.kunjungan.k1_murni`] = FieldValue.increment(1);
          if (isUsg) update[`by_month.${currentMonth}.kunjungan.k1_murni_usg`] = FieldValue.increment(1);
          if (kontrolDokter) update[`by_month.${currentMonth}.kunjungan.k1_murni_dokter`] = FieldValue.increment(1);
        } else {
          update[`by_month.${currentMonth}.kunjungan.k1_akses`] = FieldValue.increment(1);
          if (isUsg) update[`by_month.${currentMonth}.kunjungan.k1_akses_usg`] = FieldValue.increment(1);
          if (kontrolDokter) update[`by_month.${currentMonth}.kunjungan.k1_akses_dokter`] = FieldValue.increment(1);
        }
        if (isUsg) update[`by_month.${currentMonth}.kunjungan.k1_usg`] = FieldValue.increment(1);
        if (kontrolDokter) update[`by_month.${currentMonth}.kunjungan.k1_dokter`] = FieldValue.increment(1);
        if (isK1_4t) update[`by_month.${currentMonth}.kunjungan.k1_4t`] = FieldValue.increment(1);
      } else if (status === "k2") {
        update[`by_month.${currentMonth}.kunjungan.k2`] = FieldValue.increment(1);
      } else if (status === "k3") {
        update[`by_month.${currentMonth}.kunjungan.k3`] = FieldValue.increment(1);
      } else if (status === "k4") {
        update[`by_month.${currentMonth}.kunjungan.k4`] = FieldValue.increment(1);
      } else if (status === "k5") {
        update[`by_month.${currentMonth}.kunjungan.k5`] = FieldValue.increment(1);
        if (periksaUsg) update[`by_month.${currentMonth}.kunjungan.k5_usg`] = FieldValue.increment(1);
      } else if (status === "k6") {
        update[`by_month.${currentMonth}.kunjungan.k6`] = FieldValue.increment(1);
        if (periksaUsg) update[`by_month.${currentMonth}.kunjungan.k6_usg`] = FieldValue.increment(1);
      }

      // --- LOGIC BATAS 13 BULAN ---
      const months = Object.keys(byMonth).sort();
      if (months.length > 13) {
        const oldestMonth = months[0];
        delete byMonth[oldestMonth];
        console.log(`Month limit exceeded. Deleted oldest month: ${oldestMonth} for bidan: ${idBidan}`);
        update["by_month"] = byMonth; // replace setelah delete
      }

      update["last_updated_month"] = currentMonth;

      t.set(statsRef, update, { merge: true });
      console.log(`Incremented kunjungan count for month: ${currentMonth}, bidan: ${idBidan}`);
    });
  }
);
