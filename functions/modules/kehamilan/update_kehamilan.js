import { onDocumentUpdated } from "firebase-functions/v2/firestore";
import { db } from "../firebase.js";
import { getMonthString } from "../helpers.js";

const REGION = "asia-southeast2";

// helper aman untuk parsing berbagai format tanggal
const toSafeDate = (v) => {
  if (!v) return null;
  if (typeof v?.toDate === "function") return v.toDate(); // Firestore Timestamp
  if (v.seconds && typeof v.seconds === "number") return new Date(v.seconds * 1000); // { seconds }
  const d = new Date(v); // fallback string
  return isNaN(d.getTime()) ? null : d;
};

export const updateKehamilanStats = onDocumentUpdated(
  { document: "bumil/{bumilId}", region: REGION },
  async (event) => {
    const before = event.data?.before?.data();
    const after = event.data?.after?.data();
    if (!before || !after || !after.id_bidan) return;

    const statsRef = db.doc(`statistics/${after.id_bidan}`);

    // === Ketika is_hamil berubah dari false -> true ===
    if (!before.is_hamil && after.is_hamil) {
      const latestKehamilan = after.latest_kehamilan;
      const riwayat = after.riwayat || [];
      const currentMonth = getMonthString(latestKehamilan.created_at?.toDate ? latestKehamilan.created_at.toDate() : new Date()); // contoh hasil: "2025-10"

      // cari tanggal lahir terakhir yang valid
      let lastBirthDate = null;
      if (riwayat.length > 0) {
        const birthDates = riwayat
          .map(r => toSafeDate(r.tgl_lahir))
          .filter(d => d !== null)
          .sort((a, b) => b.getTime() - a.getTime());

        if (birthDates.length > 0) lastBirthDate = birthDates[0];
      }

      const createdAt = toSafeDate(latestKehamilan?.created_at);

      if (lastBirthDate && createdAt) {
        const diffMs = createdAt.getTime() - lastBirthDate.getTime();
        const diffDays = Math.floor(diffMs / (1000 * 60 * 60 * 24));
        const diffYears = diffDays / 365;

        // debug opsional
        console.log(`[updateKehamilanStats] ${after.id_bidan}: diffYears=${diffYears}`);

        if (diffYears < 2) {
          // tambahkan ke resti.jarak_hamil
          await db.runTransaction(async (t) => {
            const doc = await t.get(statsRef);
            const existing = doc.exists ? doc.data() : {};
            const current = existing?.by_month?.[currentMonth]?.resti?.jarak_hamil || 0;

            t.set(
              statsRef,
              {
                by_month: {
                  [currentMonth]: {
                    resti: {
                      jarak_hamil: current + 1,
                    },
                  },
                },
              },
              { merge: true }
            );
          });
        }
      }
    }

    // === Ketika is_hamil berubah dari true -> false ===
    if (before.is_hamil && !after.is_hamil) {
      await db.runTransaction(async (t) => {
        const doc = await t.get(statsRef);
        if (!doc.exists) return;

        const existing = doc.data();
        const currentCount = existing?.kehamilan?.all_bumil_count || 0;
        const newCount = Math.max(currentCount - 1, 0);

        t.set(
          statsRef,
          { kehamilan: { all_bumil_count: newCount } },
          { merge: true }
        );
      });
    }
  }
);
