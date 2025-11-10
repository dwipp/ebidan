
import { db, admin } from "../firebase.js";
import { onMessagePublished } from "firebase-functions/v2/pubsub";

const GOOGLE_SERVICE_ACCOUNT_JSON = defineSecret("GOOGLE_SERVICE_ACCOUNT_JSON");
const RTDN_TOPIC = "subs-rtdn-topic"; // Ganti jika Anda menggunakan nama berbeda

// 1. Tentukan fungsi Pub/Sub Trigger
export const handleSubscriptionUpdate = onMessagePublished(
  {
    topic: RTDN_TOPIC,
    secrets: [GOOGLE_SERVICE_ACCOUNT_JSON],
  },
  async (event) => {
    // Pastikan payload notifikasi ada
    if (!event.data.message.data) {
        console.log("No data in Pub/Sub message.");
        return;
    }

    try {
      // 2. Dekode Payload (datanya base64)
      const dataBuffer = Buffer.from(event.data.message.data, "base64");
      const jsonPayload = JSON.parse(dataBuffer.toString());
      
      const { notificationType, subscriptionNotification } = jsonPayload;

      if (!subscriptionNotification) {
          console.log(`Payload bukan notifikasi langganan. Tipe: ${notificationType}`);
          return;
      }
      
      const { purchaseToken, packageName, subscriptionId } = subscriptionNotification;
      
      console.log(`[RTDN] Notif Tipe: ${notificationType}, Token: ${purchaseToken}`);
      
      // Filter notifikasi penting: RENEWED (perpanjangan) atau EXPIRED
      if (notificationType !== 2 && notificationType !== 3) { // 2=RENEWED, 3=EXPIRED
          console.log(`Notifikasi tipe ${notificationType} diabaikan.`);
          return;
      }

      // 3. Cari UserID berdasarkan Purchase Token
      const userSnap = await db.collection('bidan')
          .where('subscription.purchase_token', '==', purchaseToken)
          .limit(1)
          .get();
      
      if (userSnap.empty) {
          console.error(`User tidak ditemukan dengan purchaseToken: ${purchaseToken}`);
          return;
      }
      
      const userId = userSnap.docs[0].id;
      const userRef = db.collection("bidan").doc(userId);

      // 4. Panggil Google Play API untuk Verifikasi Terbaru
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
      
      // Tentukan status berdasarkan data Google Play
      let status = "active";
      const nowMillis = admin.firestore.Timestamp.now().toMillis();

      if (nowMillis > expiryDate) {
          status = "expired";
      } else if (purchase.cancelReason !== undefined || purchase.autoRenewing === false) {
          status = "canceled";
      }
      
      // 5. Update Firestore dengan data baru
      await userRef.set(
        {
          subscription: {
            expiry_date: expiryDate, // Ini adalah tanggal terbaru dari Google
            status: status, 
            auto_renew: purchase.autoRenewing ?? false,
            last_verified: nowMillis,
          },
        },
        { merge: true }
      );
      
      console.log(`✅ [RTDN] User ${userId} subscription diperbarui. Expire: ${expiryDate}`);

      // Opsional: Tambahkan log ke sub-koleksi subscription_logs

    } catch (error) {
      console.error("Error memproses notifikasi RTDN:", error);
      // PENTING: Jangan melempar error di fungsi Pub/Sub, karena akan menyebabkan retry terus-menerus.
    }
});