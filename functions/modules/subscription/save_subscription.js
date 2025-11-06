// functions/handlers/saveSubscription.js
import { db, FieldValue } from "../firebase.js";
import { HttpsError } from "firebase-functions/v2/https";

export async function saveSubscription(data, context) {
  const { userId, productId, purchaseToken, orderId, platform } = data;

  if (!context.auth || !userId) {
    throw new HttpsError("unauthenticated", "User not authenticated.");
  }

  try {
    const userRef = db.collection("bidan").doc(userId);
    const logsRef = userRef.collection("subscription_logs");
    const now = new Date();

    const subscriptionData = {
      productId,
      purchaseToken,
      orderId: orderId || null,
      platform: platform || "android",
      status: "pending",
      startDate: now,
      expiryDate: null,
      lastVerified: null,
      updatedAt: now,
    };

    // 🔄 Simpan atau update data utama subscription
    await userRef.set({ subscription: subscriptionData }, { merge: true });

    // 🪵 Tambahkan log baru
    await logsRef.add({
      action: "save",
      timestamp: now,
      performedBy: "user",
      details: {
        productId,
        orderId: orderId || null,
        purchaseToken,
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
}
