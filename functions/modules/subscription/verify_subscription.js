import { db, admin } from "../firebase.js";
import { google } from "googleapis";
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { defineSecret } from "firebase-functions/params";

const GOOGLE_SERVICE_ACCOUNT_JSON = defineSecret("GOOGLE_SERVICE_ACCOUNT_JSON");


const REGION = "asia-southeast2";

export const verifySubscription = onCall(
  { 
    region: REGION,
    secrets: [GOOGLE_SERVICE_ACCOUNT_JSON] 
  }, 
  async (request) => {
  const { data, auth } = request;
  const { userId, packageName, productId, purchaseToken } = data;

  if (!auth || !userId) {
    throw new HttpsError("unauthenticated", "User not authenticated.");
  }

  try {
    const authClient = await new google.auth.GoogleAuth({
      credentials: JSON.parse(GOOGLE_SERVICE_ACCOUNT_JSON.value()),
      scopes: ["https://www.googleapis.com/auth/androidpublisher"],
    }).getClient();

    const playDeveloper = google.androidpublisher("v3");

    const res = await playDeveloper.purchases.subscriptions.get({
      auth: authClient,
      packageName,
      subscriptionId: productId,
      token: purchaseToken,
    });

    const purchase = res.data;
    if (!purchase || !purchase.expiryTimeMillis || !purchase.kind) {
      throw new HttpsError("not-found", "Invalid or missing subscription data.");
    }

    const now = admin.firestore.Timestamp.now().toMillis();
    const expiryDate = Number(purchase.expiryTimeMillis);
    const startDate = purchase.startTimeMillis ? Number(purchase.startTimeMillis) : null;

    let status = "active";
    if (now > expiryDate) {
      status = "expired";
    } else if (purchase.cancelReason !== undefined || purchase.autoRenewing === false) {
      status = "canceled";
    }

    const userRef = db.collection("bidan").doc(userId);
    const logsRef = userRef.collection("subscription_logs");

    // 🔄 Update data utama subscription
    const subscription = {
          product_id: productId,
          purchase_token: status === "expired" ? null : purchaseToken,
          order_id: purchase.orderId || null,
          start_date: startDate,
          expiry_date: expiryDate,
          status,
          platform: "android",
          auto_renew: purchase.autoRenewing ?? false,
          last_verified: now,
          updated_at: now,
        }
    await userRef.set(
      {
        premium_source: "subscription",
        premium_until: expiryDate,
        subscription,
      },
      { merge: true }
    );

    // 🪵 Tambahkan log baru
    await logsRef.add({
      action: "verify",
      timestamp: now,
      performed_by: "system",
      details: {
        product_id: productId,
        order_id: purchase.orderId || null,
        purchase_token: purchaseToken,
        status,
        expiry_date: expiryDate,
        auto_renew: purchase.autoRenewing ?? false,
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
      subscription,
    };

  } catch (error) {
    console.error("Error verifying subscription:", error);

    if (error instanceof HttpsError) throw error;
    throw new HttpsError("internal", error.message || "Failed to verify subscription.");
  }
});
