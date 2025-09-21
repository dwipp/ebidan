import { onDocumentUpdated } from "firebase-functions/v2/firestore";
import { db, FieldValue } from "../firebase.js";
import { getMonthString } from "../helpers.js";

const REGION = "asia-southeast2";

export const incrementPersalinanCount = onDocumentUpdated(
  {
    document: "kehamilan/{kehamilanId}",
    region: REGION,
  },
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();

    if (!before || !after) return;

    const beforePersalinan = before.persalinan || [];
    const afterPersalinan = after.persalinan || [];

    // hanya jalan kalau ada item baru
    if (afterPersalinan.length <= beforePersalinan.length) return;

    // ambil item baru
    const newPersalinan = afterPersalinan.slice(beforePersalinan.length);

    const idBidan = after.id_bidan;
    if (!idBidan) return;

    const statsRef = db.doc(`statistics/${idBidan}`);

    await db.runTransaction(async (t) => {
      const doc = await t.get(statsRef);
      const existing = doc.exists ? doc.data() : {};
      const byMonth = existing.by_month || {};
      const updates = {};

      for (const p of newPersalinan) {
        if (!p.tgl_persalinan) continue;

        let tgl;
        if (p.tgl_persalinan?.toDate) tgl = p.tgl_persalinan.toDate();
        else if (p.tgl_persalinan) tgl = new Date(p.tgl_persalinan);
        if (!tgl || isNaN(tgl)) continue;

        const monthKey = getMonthString(tgl);

        // pastikan struktur bulan ada di memory (bukan increment)
        if (!byMonth[monthKey]) {
          byMonth[monthKey] = { persalinan: {}, kunjungan: {} };
        }
        if (!byMonth[monthKey].persalinan) {
          byMonth[monthKey].persalinan = {};
        }
        if (!byMonth[monthKey].kunjungan) {
          byMonth[monthKey].kunjungan = {};
        }

        // increment total persalinan
        updates[`by_month.${monthKey}.persalinan.total`] = FieldValue.increment(1);

        // cek abortus
        if (p.status_bayi === "Abortus") {
          let umurMinggu = null;
          let lebihDariMinggu = false;

          if (typeof p.umur_kehamilan === "string") {
            const match = p.umur_kehamilan.match(/(\d+)\s*minggu(?:\s+(\d+)\s*hari)?/i);
            if (match) {
              umurMinggu = parseInt(match[1], 10);
              if (match[2]) {
                const umurHari = parseInt(match[2], 10);
                if (umurHari > 0) lebihDariMinggu = true;
              }
            }
          } else if (typeof p.umur_kehamilan === "number") {
            umurMinggu = p.umur_kehamilan;
          }

          if (
            umurMinggu !== null &&
            umurMinggu >= 0 &&
            umurMinggu <= 20 &&
            !lebihDariMinggu
          ) {
            updates[`by_month.${monthKey}.kunjungan.abortus`] = FieldValue.increment(1);
          }
        }

        // --- LOGIC BATAS 13 BULAN ---
        const months = Object.keys(byMonth).sort(); // YYYY-MM ascending
        if (months.length > 13) {
          const oldestMonth = months[0];
          delete byMonth[oldestMonth];
          console.log(
            `Month limit exceeded. Deleted oldest month: ${oldestMonth} for bidan: ${idBidan}`
          );
        }

        console.log(
          `Incremented persalinan count for month: ${monthKey}, bidan: ${idBidan}`
        );
      }

      // --- Simpan ke Firestore ---
      t.set(
        statsRef,
        {
          ...existing,
          ...updates,
          by_month: byMonth,
          last_updated_month: newPersalinan.length
            ? getMonthString(
                newPersalinan[newPersalinan.length - 1].tgl_persalinan.toDate
                  ? newPersalinan[newPersalinan.length - 1].tgl_persalinan.toDate()
                  : new Date(newPersalinan[newPersalinan.length - 1].tgl_persalinan)
              )
            : getMonthString(new Date()),
        },
        { merge: true }
      );
    });
  }
);
