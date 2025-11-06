// functions/handlers/verifySubscription.js
import { db } from "../firebase.js";
import { google } from "googleapis";
import { HttpsError } from "firebase-functions/v2/https";

export async function verifySubscription(data, context) {
  const { userId, packageName, productId, purchaseToken } = data;

  if (!context.auth || !userId) {
    throw new HttpsError("unauthenticated", "User not authenticated.");
  }

  try {
    const auth = new google.auth.GoogleAuth({
      credentials: JSON.parse(process.env.GOOGLE_SERVICE_ACCOUNT_JSON),
      scopes: ["https://www.googleapis.com/auth/androidpublisher"],
    });

    const authClient = await auth.getClient();
    const playDeveloper = google.androidpublisher("v3");

    const res = await playDeveloper.purchases.subscriptions.get({
      auth: authClient,
      packageName,
      subscriptionId: productId,
      token: purchaseToken,
    });

    const purchase = res.data;
    if (!purchase || !purchase.expiryTimeMillis) {
      throw new HttpsError("not-found", "Subscription data not found.");
    }

    const now = new Date();
    const expiryDate = new Date(Number(purchase.expiryTimeMillis));
    const startDate = purchase.startTimeMillis
      ? new Date(Number(purchase.startTimeMillis))
      : null;

    const cancelReason = purchase.cancelReason;
    let status = "active";
    if (cancelReason !== undefined) {
      status = "canceled";
    } else if (Date.now() > Number(purchase.expiryTimeMillis)) {
      status = "expired";
    }

    const userRef = db.collection("bidan").doc(userId);
    const logsRef = userRef.collection("subscription_logs");

    // 🔄 Update data utama subscription
    await userRef.set(
      {
        subscription: {
          productId,
          purchaseToken,
          orderId: purchase.orderId || null,
          startDate,
          expiryDate,
          status,
          platform: "android",
          autoRenew: purchase.autoRenewing ?? false,
          lastVerified: now,
          updatedAt: now,
        },
      },
      { merge: true }
    );

    // 🪵 Tambahkan log baru
    await logsRef.add({
      action: "verify",
      timestamp: now,
      performedBy: "system",
      details: {
        productId,
        orderId: purchase.orderId || null,
        purchaseToken,
        status,
        expiryDate,
        autoRenew: purchase.autoRenewing ?? false,
        platform: "android",
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

    return {
      success: true,
      status,
      expiryDate,
      autoRenew: purchase.autoRenewing ?? false,
    };
  } catch (error) {
    console.error("Error verifying subscription:", error);

    if (error instanceof HttpsError) throw error;
    throw new HttpsError("internal", error.message || "Failed to verify subscription.");
  }
}
