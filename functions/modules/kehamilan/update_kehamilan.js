import { onDocumentUpdated } from "firebase-functions/v2/firestore";
import { db } from "../firebase.js";

const REGION = "asia-southeast2";

export const updateKehamilanStats = onDocumentUpdated(
  { document: "bumil/{bumilId}", region: REGION },
  async (event) => {
    const before = event.data?.before?.data();
    const after = event.data?.after?.data();
    if (!before || !after || !after.id_bidan) return;

    const statsRef = db.doc(`statistics/${after.id_bidan}`);

    // hanya jalankan jika is_hamil berubah dari true → false
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
