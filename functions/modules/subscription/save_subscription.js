import { db } from "../firebase.js";
import { onCall, HttpsError } from "firebase-functions/v2/https";

const REGION = "asia-southeast2";

export const saveSubscription = onCall(
  { region: REGION }, 
  async (request) => {
  const { data, auth } = request;
  const { userId, productId, purchaseToken, orderId, platform } = data;

  if (!auth || !userId) {
    throw new HttpsError("unauthenticated", "User not authenticated.");
  }

  try {
    const userRef = db.collection("bidan").doc(userId);
    const logsRef = userRef.collection("subscription_logs");
    const now = new Date();

    const subscriptionData = {
      product_id: productId,
      purchase_token: purchaseToken,
      order_id: orderId || null,
      platform: platform || "android",
      status: "pending",
      start_date: now,
      expiry_date: null,
      last_verified: null,
      updated_at: now,
    };

    // 🔄 Simpan atau update data utama subscription
    await userRef.set({ subscription: subscriptionData }, { merge: true });

    // 🪵 Tambahkan log baru
    await logsRef.add({
      action: "save",
      timestamp: now,
      performed_by: "user",
      details: {
        product_id: productId,
        order_id: orderId || null,
        purchase_token: purchaseToken,
        platform: platform || "android",
        status: "pending",
      },
    });

    // 🧹 Hapus log lama jika lebih dari 50
    const logsSnap = await logsRef.orderBy("timestamp", "desc").get();
    if (logsSnap.size > 50) {
      const oldLogs = logsSnap.docs.slice(50);
      const batch = db.batch();
      oldLogs.forEach((doc) => batch.delete(doc.ref));
      await batch.commit();
    }

    return { success: true, message: "Subscription saved successfully." };
  } catch (error) {
    console.error("Error saving subscription:", error);
    throw new HttpsError("internal", "Failed to save subscription.");
  }
});
