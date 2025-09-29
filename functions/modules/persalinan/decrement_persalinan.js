import { onDocumentUpdated } from "firebase-functions/v2/firestore";
import { db } from "../firebase.js";
import { getMonthString, safeDecrement } from "../helpers.js";

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

      await db.runTransaction(async (t) => {
        const doc = await t.get(statRef);
        if (!doc.exists) return;

        const existing = doc.data() || {};
        const byMonth = existing.by_month || {};

        if (!byMonth[monthKey]) byMonth[monthKey] = {};
        if (!byMonth[monthKey].persalinan) byMonth[monthKey].persalinan = { total: 0 };
        if (!byMonth[monthKey].kunjungan) byMonth[monthKey].kunjungan = { abortus: 0 };
        if (!byMonth[monthKey].kehamilan) byMonth[monthKey].kehamilan = { abortus: 0 };

        // decrement persalinan
        safeDecrement(byMonth[monthKey].persalinan, "total");

        // decrement abortus kalau memang abortus
        if (isAbortus) {
          safeDecrement(byMonth[monthKey].kunjungan, "abortus");
          safeDecrement(byMonth[monthKey].kehamilan, "abortus");
        }

        t.set(
          statRef,
          {
            ...existing,
            by_month: byMonth,
            last_updated_month: monthKey,
          },
          { merge: true }
        );
      });

      console.log(
        `Decremented persalinan count for month: ${monthKey}, bidan: ${idBidan}${
          isAbortus ? " (abortus)" : ""
        }`
      );
    }
  }
);
