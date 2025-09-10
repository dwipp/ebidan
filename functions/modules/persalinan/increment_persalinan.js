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

    for (const p of newPersalinan) {
      if (!p.tgl_persalinan) continue;

      // tgl_persalinan adalah Firestore Timestamp
      const date = p.tgl_persalinan.toDate();
      const monthKey = getMonthString(date);

      // ambil id_bidan dari doc kehamilan
      const idBidan = after.id_bidan;
      if (!idBidan) continue;

      const statRef = db.collection("statistics").doc(idBidan);

      await statRef.set(
        {
          by_month: {
            [monthKey]: {
              persalinan: {
                total: FieldValue.increment(1),
              },
            },
          },
        },
        { merge: true }
      );
    }
  }
);
