import { onDocumentUpdated } from "firebase-functions/v2/firestore";
import { db } from "../firebase.js";
import { getMonthString } from "../helpers.js";

const REGION = "asia-southeast2";

const toSafeDate = (v) => {
  if (!v) return null;
  if (typeof v?.toDate === "function") return v.toDate();
  if (v.seconds && typeof v.seconds === "number") return new Date(v.seconds * 1000);
  const d = new Date(v);
  return isNaN(d.getTime()) ? null : d;
};

export const updateKehamilanStats = onDocumentUpdated(
  { document: "bumil/{bumilId}", region: REGION },
  async (event) => {
    const before = event.data?.before?.data();
    const after = event.data?.after?.data();
    if (!before || !after || !after.id_bidan) return;

    const statsRef = db.doc(`statistics/${after.id_bidan}`);
    const latestKehamilan = after.latest_kehamilan;
    const riwayat = after.riwayat || [];
    const currentMonth = getMonthString(
      toSafeDate(latestKehamilan?.created_at) || new Date()
    );

    await db.runTransaction(async (t) => {
      const doc = await t.get(statsRef);
      const existing = doc.exists ? doc.data() : {};
      const byMonth = existing.by_month || {};
      const monthData = byMonth[currentMonth] || {};
      const resti = monthData.resti || {};
      const kehamilanExisting = existing.kehamilan || {};

      let jarakHamil = resti.jarak_hamil || 0;
      let bbBayiUnder2500 = resti.bb_bayi_under_2500 || 0;
      let allBumilCount = kehamilanExisting.all_bumil_count || 0;

      // === is_hamil: false -> true ===
      if (!before.is_hamil && after.is_hamil) {
        // cari last birth date
        const birthDates = riwayat
          .map((r) => toSafeDate(r?.tgl_lahir))
          .filter((d) => d)
          .sort((a, b) => b.getTime() - a.getTime());
        const lastBirthDate = birthDates.length > 0 ? birthDates[0] : null;
        const createdAt = toSafeDate(latestKehamilan?.created_at);

        // resti jarak kehamilan < 2 tahun
        if (lastBirthDate && createdAt) {
          const diffDays = Math.floor((createdAt.getTime() - lastBirthDate.getTime()) / (1000 * 60 * 60 * 24));
          const diffYears = diffDays / 365;
          console.log(`[updateKehamilanStats] ${after.id_bidan}: diffYears=${diffYears}`);
          if (diffYears < 2) jarakHamil++;
        }

        // resti riwayat untuk berat bayi < 2500
        const hasUnder2500 = riwayat.some((r) => {
          const w = r?.berat_bayi;
          return w !== undefined && w !== null && !isNaN(Number(w)) && Number(w) < 2500;
        });
        if (hasUnder2500) bbBayiUnder2500++;
      }

      // === is_hamil: true -> false ===
      if (before.is_hamil && !after.is_hamil) {
        allBumilCount = Math.max(allBumilCount - 1, 0);
      }

      t.set(
        statsRef,
        {
          kehamilan: { all_bumil_count: allBumilCount },
          by_month: {
            [currentMonth]: {
              resti: {
                jarak_hamil: jarakHamil,
                bb_bayi_under_2500: bbBayiUnder2500,
              },
            },
          },
        },
        { merge: true }
      );
    });
  }
);
