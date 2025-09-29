import { onDocumentUpdated } from "firebase-functions/v2/firestore";
import { db } from "../firebase.js";
import { getMonthString, safeIncrement } from "../helpers.js";

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

      for (const p of newPersalinan) {
        if (!p.tgl_persalinan) continue;

        let tgl;
        if (p.tgl_persalinan?.toDate) tgl = p.tgl_persalinan.toDate();
        else if (p.tgl_persalinan) tgl = new Date(p.tgl_persalinan);
        if (!tgl || isNaN(tgl)) continue;

        const monthKey = getMonthString(tgl);

        // pastikan struktur bulan ada
        if (!byMonth[monthKey]) {
          byMonth[monthKey] = {
            persalinan: { total: 0 },
            kunjungan: { abortus: 0 },
            kehamilan: { abortus: 0 },
          };
        } else {
          if (!byMonth[monthKey].persalinan) {
            byMonth[monthKey].persalinan = { total: 0 };
          }
          if (!byMonth[monthKey].kunjungan) {
            byMonth[monthKey].kunjungan = { abortus: 0 };
          }
          if (!byMonth[monthKey].kehamilan) {
            byMonth[monthKey].kehamilan = { abortus: 0 };
          }
        }

        // increment total persalinan
        safeIncrement(byMonth[monthKey].persalinan, "total");

        // cek abortus
        if (p.status_bayi === "Abortus") {
          let umurMinggu = null;
          let lebihDariMinggu = false;

          if (typeof p.umur_kehamilan === "string") {
            // contoh: "20 minggu" atau "20 minggu 5 hari"
            const match = p.umur_kehamilan.match(/(\d+)\s*minggu(?:\s+(\d+)\s*hari)?/i);
            if (match) {
              umurMinggu = parseInt(match[1], 10);
              if (match[2]) {
                const umurHari = parseInt(match[2], 10);
                if (umurHari > 0) lebihDariMinggu = true;
              }
            }
          } else if (typeof p.umur_kehamilan === "number") {
            // kalau langsung angka (anggap minggu)
            umurMinggu = p.umur_kehamilan;
          }

          if (
            umurMinggu !== null &&
            umurMinggu >= 0 &&
            umurMinggu <= 20 &&
            !lebihDariMinggu
          ) {
            safeIncrement(byMonth[monthKey].kunjungan, "abortus");
            safeIncrement(byMonth[monthKey].kehamilan, "abortus");
          }
        }

        // --- LOGIC BATAS 13 BULAN ---
        const months = Object.keys(byMonth).sort(); // YYYY-MM format -> urut ascending
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
