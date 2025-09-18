import { onDocumentUpdated } from "firebase-functions/v2/firestore";
import { db, FieldValue } from "../firebase.js";
import { getMonthString } from "../helpers.js";

const REGION = "asia-southeast2";

export const decrementPersalinanCount = onDocumentUpdated(
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

    // hanya jalan kalau ada pengurangan persalinan
    if (afterPersalinan.length >= beforePersalinan.length) return;

    // ambil item yang hilang (dihapus)
    const removedPersalinan = beforePersalinan.slice(afterPersalinan.length);

    for (const p of removedPersalinan) {
      if (!p.tgl_persalinan) continue;

      let tgl;
      if (p.tgl_persalinan?.toDate) tgl = p.tgl_persalinan.toDate();
      else if (p.tgl_persalinan) tgl = new Date(p.tgl_persalinan);
      if (!tgl || isNaN(tgl)) continue;

      const monthKey = getMonthString(tgl);

      // ambil id_bidan dari doc kehamilan
      const idBidan = after.id_bidan || before.id_bidan;
      if (!idBidan) continue;

      const statRef = db.collection("statistics").doc(idBidan);

      // cek apakah abortus
      let isAbortus = false;
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
          umurMinggu = p.umur_kehamilan;
        }

        if (
          umurMinggu !== null &&
          umurMinggu >= 0 &&
          umurMinggu <= 20 &&
          !lebihDariMinggu
        ) {
          isAbortus = true;
        }
      }

      // update statistik dengan decrement
      const updateData = {
        by_month: {
          [monthKey]: {
            persalinan: {
              total: FieldValue.increment(-1),
            },
          },
        },
      };

      if (isAbortus) {
        updateData.by_month[monthKey].kunjungan = {
          abortus: FieldValue.increment(-1),
        };
      }

      // --- penting: merge supaya data bulan lain tidak hilang
      await statRef.set(updateData, { merge: true });

      console.log(
        `Decremented persalinan count for month: ${monthKey}, bidan: ${idBidan}${
          isAbortus ? " (abortus)" : ""
        }`
      );
    }
  }
);
