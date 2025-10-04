import { onDocumentUpdated } from "firebase-functions/v2/firestore";
import { db } from "../firebase.js";
import { getMonthString } from "../helpers.js"; // helper untuk format yyyy-MM

const REGION = "asia-southeast2";

export const updateKehamilanStats = onDocumentUpdated(
  { document: "bumil/{bumilId}", region: REGION },
  async (event) => {
    const before = event.data?.before?.data();
    const after = event.data?.after?.data();
    if (!before || !after || !after.id_bidan) return;

    const statsRef = db.doc(`statistics/${after.id_bidan}`);
    const now = new Date();
    const currentMonth = getMonthString(now); // contoh hasil: "2025-09"

    // hanya jalankan jika is_hamil berubah dari false -> true
    if (!before.is_hamil && after.is_hamil) {
      const latestKehamilan = after.latest_kehamilan;
      const riwayat = after.riwayat || [];

      // ambil tanggal lahir bayi terakhir
      let lastBirthDate = null;
      if (riwayat.length > 0) {
        const sorted = riwayat
          .filter(r => r.tgl_lahir)
          .sort((a, b) => new Date(b.tgl_lahir) - new Date(a.tgl_lahir));
        if (sorted.length > 0) {
          lastBirthDate = new Date(sorted[0].tgl_lahir);
        }
      }

      if (lastBirthDate && latestKehamilan?.created_at) {
        const createdAt = new Date(latestKehamilan.created_at);
        const diffMs = createdAt - lastBirthDate;
        const diffDays = Math.floor(diffMs / (1000 * 60 * 60 * 24));
        const diffYears = diffDays / 365;

        if (diffYears < 2) {
          // counting ke statistics
          await db.runTransaction(async (t) => {
            const doc = await t.get(statsRef);
            const existing = doc.exists ? doc.data() : {};
            const current = existing?.by_month?.[currentMonth]?.resti?.jarak_hamil || 0;

            t.set(statsRef, {
              by_month: {
                [currentMonth]: {
                  resti: {
                    jarak_hamil: current + 1
                  }
                }
              }
            }, { merge: true });
          });
        }
      }
    }

    // logic existing tetap jalan untuk is_hamil true -> false
    if (before.is_hamil && !after.is_hamil) {
      await db.runTransaction(async (t) => {
        const doc = await t.get(statsRef);
        if (!doc.exists) return;

        const existing = doc.data();
        const currentCount = existing?.kehamilan?.all_bumil_count || 0;
        const newCount = Math.max(currentCount - 1, 0);

        t.set(statsRef, {
          kehamilan: { all_bumil_count: newCount }
        }, { merge: true });
      });
    }
  }
);
