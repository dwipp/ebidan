import { db, admin } from "../firebase.js";
import { google } from "googleapis";
import { defineSecret } from "firebase-functions/params";
import { onMessagePublished } from "firebase-functions/v2/pubsub";

const GOOGLE_SERVICE_ACCOUNT_JSON = defineSecret("GOOGLE_SERVICE_ACCOUNT_JSON");
const RTDN_TOPIC = "subs-rtdn-topic"; 
const REGION = "asia-southeast2";

export const handleSubscriptionUpdate = onMessagePublished(
  {
    region: REGION,
    topic: RTDN_TOPIC,
    secrets: [GOOGLE_SERVICE_ACCOUNT_JSON],
  },
  async (event) => {
    if (!event.data.message.data) {
      console.log("No data in Pub/Sub message.");
      return;
    }

    try {
      // 1. Decode payload
      const dataBuffer = Buffer.from(event.data.message.data, "base64");
      const jsonPayload = JSON.parse(dataBuffer.toString());
      console.log("[RTDN RAW PAYLOAD]", jsonPayload);

      // Ambil tipe notifikasi dari subscriptionNotification
      const subscription = jsonPayload.subscriptionNotification;
      const notificationType = subscription?.notificationType;
      const purchaseToken = subscription?.purchaseToken;
      const packageName = jsonPayload.packageName;
      const subscriptionId = subscription?.subscriptionId;

      if (!subscription) {
        console.log(`Payload bukan notifikasi langganan. Tipe: ${notificationType}`);
        return;
      }

      console.log(`[RTDN] Notif Tipe: ${notificationType}, Token: ${purchaseToken}`);

      // 2. Filter event penting (2=RENEWED, 3=EXPIRED)
      if (notificationType !== 2 && notificationType !== 3) {
        console.log(`Notifikasi tipe ${notificationType} diabaikan.`);
        return;
      }

      // 3. Ambil user berdasarkan purchaseToken
      const userSnap = await db
        .collection("bidan")
        .where("subscription.purchase_token", "==", purchaseToken)
        .limit(1)
        .get();

      if (userSnap.empty) {
        console.error(`User tidak ditemukan dengan purchaseToken: ${purchaseToken}`);
        return;
      }

      const userId = userSnap.docs[0].id;
      const userRef = db.collection("bidan").doc(userId);
      const logsRef = userRef.collection("subscription_logs");

      // 4. Verifikasi ke Google Play API
      const authClient = await new google.auth.GoogleAuth({
        credentials: JSON.parse(GOOGLE_SERVICE_ACCOUNT_JSON.value()),
        scopes: ["https://www.googleapis.com/auth/androidpublisher"],
      }).getClient();

      const playDeveloper = google.androidpublisher("v3");

      const res = await playDeveloper.purchases.subscriptions.get({
        auth: authClient,
        packageName,
        subscriptionId,
        token: purchaseToken,
      });

      const purchase = res.data;
      const expiryDate = Number(purchase.expiryTimeMillis);
      const now = admin.firestore.Timestamp.now();
      const nowMillis = now.toMillis();

      // 5. Tentukan status
      let status = "active";
      if (nowMillis > expiryDate) {
        status = "expired";
      } else if (purchase.cancelReason !== undefined || purchase.autoRenewing === false) {
        status = "canceled";
      }

      // 6. Update data di Firestore
      await userRef.set(
        {
          premium_source: "subscription",
          premium_until: expiryDate,
          subscription: {
            expiry_date: expiryDate,
            status,
            auto_renew: purchase.autoRenewing ?? false,
            last_verified: nowMillis,
          },
        },
        { merge: true }
      );

      // 7. Tentukan tipe log berdasarkan notifikasi
      let actionType = "verify";
      if (notificationType === 2) actionType = "renewed";
      else if (notificationType === 3) actionType = "expired";

      // 8. Tambah log baru
      await logsRef.add({
        action: actionType,
        timestamp: now,
        performed_by: "system_rtdn",
        details: {
          product_id: subscriptionId,
          order_id: purchase.orderId || null,
          purchase_token: purchaseToken,
          status,
          expiry_date: expiryDate,
          auto_renew: purchase.autoRenewing ?? false,
          platform: "android",
        },
      });

      // 9. Hapus log lama jika > 50
      const logsSnap = await logsRef.orderBy("timestamp", "desc").get();
      if (logsSnap.size > 50) {
        const oldLogs = logsSnap.docs.slice(50);
        const batch = db.batch();
        oldLogs.forEach((doc) => batch.delete(doc.ref));
        await batch.commit();
      }

      console.log(`✅ [RTDN] User ${userId} subscription diperbarui (${actionType}). Expire: ${expiryDate}`);

    } catch (error) {
      console.error("Error memproses notifikasi RTDN:", error);
    }
  }
);
