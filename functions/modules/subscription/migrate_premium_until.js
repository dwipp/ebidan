import { onRequest } from "firebase-functions/v2/https";
import { db } from "../firebase.js";

const REGION = "asia-southeast2";

// helper kecil untuk aman konversi tanggal
const toSafeDate = (v) => {
  if (!v) return null;
  if (typeof v?.toDate === "function") return v.toDate();
  if (v.seconds && typeof v.seconds === "number") return new Date(v.seconds * 1000);
  const d = new Date(v);
  return isNaN(d.getTime()) ? null : d;
};

export const migratePremiumUntil = onRequest(
  { region: REGION },
  async (req, res) => {
    try {
      const snapshot = await db.collection("bidan").get();
      const batch = db.batch();

      let migratedCount = 0;
      let skippedCount = 0;

      snapshot.forEach((doc) => {
        const data = doc.data();
        const ref = doc.ref;

        // jika sudah punya premium_until → skip
        if (data.premium_until) {
          skippedCount++;
          return;
        }

        // 1️⃣ cek subscription
        const subExpiry = toSafeDate(data.subscription?.expiry_date);
        if (subExpiry) {
          batch.update(ref, {
            premium_until: subExpiry,
            premium_source: "subscription",
          });
          migratedCount++;
          return;
        }

        // 2️⃣ fallback ke trial
        const trialExpiry = toSafeDate(data.trial?.expiry_date);
        if (trialExpiry) {
          batch.update(ref, {
            premium_until: trialExpiry,
            premium_source: "trial",
          });
          migratedCount++;
          return;
        }

        // tidak ada data premium sama sekali
        skippedCount++;
      });

      await batch.commit();

      res.status(200).send({
        message: "Premium migration completed",
        migrated: migratedCount,
        skipped: skippedCount,
      });
    } catch (error) {
      console.error("Premium migration error:", error);
      res.status(500).send({
        error: error.message,
      });
    }
  }
);
