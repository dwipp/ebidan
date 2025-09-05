import { onDocumentCreated, onDocumentDeleted } from "firebase-functions/v2/firestore";
import { onRequest } from "firebase-functions/v2/https";
import { getFirestore } from "firebase-admin/firestore";
import admin from "firebase-admin";

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = getFirestore();
const REGION = "asia-southeast2";

// Helper: bulan dalam format YYYY-MM
function getMonthString(date) {
  return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, "0")}`;
}

// --- Increment saat tambah bumil ---
export const incrementBumilCount = onDocumentCreated(
  { document: "bumil/{bumilId}", region: REGION },
  async (event) => {
    const bumilData = event.data?.data();
    if (!bumilData || !bumilData.id_bidan) return;

    const idBidan = bumilData.id_bidan;
    const statsRef = db.doc(`statistics/${idBidan}`);
    const currentMonth = getMonthString(new Date());

    await db.runTransaction(async (t) => {
      const doc = await t.get(statsRef);

      if (!doc.exists) {
        t.set(statsRef, {
          bumilTotal: 1,
          bumilThisMonth: 1,
          lastUpdatedMonth: currentMonth,
          bumilByMonth: { [currentMonth]: 1 }
        });
        return;
      }

      const data = doc.data();
      let bumilThisMonth = data.bumilThisMonth || 0;
      let bumilByMonth = data.bumilByMonth || {};

      if (data.lastUpdatedMonth !== currentMonth) {
        bumilThisMonth = 0;
      }

      bumilByMonth[currentMonth] = (bumilByMonth[currentMonth] || 0) + 1;

      t.update(statsRef, {
        bumilTotal: (data.bumilTotal || 0) + 1,
        bumilThisMonth: bumilThisMonth + 1,
        lastUpdatedMonth: currentMonth,
        bumilByMonth: bumilByMonth
      });
    });
  }
);

// --- Decrement saat hapus bumil ---
export const decrementBumilCount = onDocumentDeleted(
  { document: "bumil/{bumilId}", region: REGION },
  async (event) => {
    const bumilData = event.data?.data();
    if (!bumilData || !bumilData.id_bidan) return;

    const idBidan = bumilData.id_bidan;
    const statsRef = db.doc(`statistics/${idBidan}`);
    const currentMonth = getMonthString(new Date());

    await db.runTransaction(async (t) => {
      const doc = await t.get(statsRef);
      if (!doc.exists) return;

      const data = doc.data();
      let bumilThisMonth = data.bumilThisMonth || 0;
      let bumilByMonth = data.bumilByMonth || {};

      if (data.lastUpdatedMonth !== currentMonth) {
        bumilThisMonth = 0;
      }

      if (bumilByMonth[currentMonth]) {
        bumilByMonth[currentMonth] = Math.max(bumilByMonth[currentMonth] - 1, 0);
      }

      t.update(statsRef, {
        bumilTotal: Math.max((data.bumilTotal || 1) - 1, 0),
        bumilThisMonth: Math.max(bumilThisMonth - 1, 0),
        lastUpdatedMonth: currentMonth,
        bumilByMonth: bumilByMonth
      });
    });
  }
);

// --- HTTP Callable: Force Recalculation per bidan ---
export const recalculateBumilStats = onRequest({ region: REGION }, async (req, res) => {
  try {
    const snapshot = await db.collection("bumil").get();

    let statsByBidan = {};

    snapshot.forEach(doc => {
      const data = doc.data();
      if (!data.id_bidan) return;

      const idBidan = data.id_bidan;
      if (!statsByBidan[idBidan]) {
        statsByBidan[idBidan] = { bumilTotal: 0, bumilByMonth: {} };
      }

      statsByBidan[idBidan].bumilTotal++;
      const createdAt = data.createdAt?.toDate ? data.createdAt.toDate() : new Date();
      const monthKey = getMonthString(createdAt);

      statsByBidan[idBidan].bumilByMonth[monthKey] =
        (statsByBidan[idBidan].bumilByMonth[monthKey] || 0) + 1;
    });

    const batch = db.batch();
    const currentMonth = getMonthString(new Date());

    for (const [idBidan, stats] of Object.entries(statsByBidan)) {
      const bumilThisMonth = stats.bumilByMonth[currentMonth] || 0;
      const ref = db.doc(`statistics/${idBidan}`);

      batch.set(ref, {
        bumilTotal: stats.bumilTotal,
        bumilThisMonth,
        lastUpdatedMonth: currentMonth,
        bumilByMonth: stats.bumilByMonth
      });
    }

    await batch.commit();

    res.status(200).send({ message: "Recalculation complete", statsByBidan });
  } catch (error) {
    console.error("Recalculation error:", error);
    res.status(500).send({ error: error.message });
  }
});
