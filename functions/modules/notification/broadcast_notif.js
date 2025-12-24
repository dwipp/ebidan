import { onSchedule } from "firebase-functions/v2/scheduler";
import admin from "firebase-admin";

const REGION = "asia-southeast2";
const TIMEZONE = "Asia/Jakarta";

// pastikan init hanya sekali
if (!admin.apps.length) {
  admin.initializeApp();
}

const sendToAll = async (title, body) => {
  return admin.messaging().send({
    topic: "all",
    notification: {
      title,
      body,
    },
  });
};

/**
 * ================================
 * 1. SETIAP HARI RABU (SELINGAN)
 * ================================
 * Minggu ganjil:
 * - Ingatkan input data ibu hamil
 * Minggu genap:
 * - Ingatkan input data manual
 */
export const weeklyWednesdayBroadcast = onSchedule(
  {
    schedule: "every wednesday 09:00",
    timeZone: TIMEZONE,
    region: REGION,
  },
  async () => {
    const now = new Date();

    // hitung minggu ke berapa dalam tahun
    const startOfYear = new Date(now.getFullYear(), 0, 1);
    const diffDays = Math.floor(
      (now.getTime() - startOfYear.getTime()) / 86400000
    );
    const weekNumber = Math.ceil((diffDays + startOfYear.getDay() + 1) / 7);

    let title;
    let body;

    if (weekNumber % 2 === 1) {
      // minggu ganjil
      title = "Jangan Lupa Input Data, ya 🌸";
      body =
        "Data kehamilan, kunjungan, dan persalinan yang lengkap membantu pencatatan dan laporan jadi lebih mudah.";
    } else {
      // minggu genap
      title = "Input Data Manual";
      body =
        "Anda dapat menginput data manual ke dalam aplikasi untuk melengkapi pencatatan.";
    }

    await sendToAll(title, body);

    console.log(
      `[WEDNESDAY BROADCAST] week=${weekNumber} title="${title}"`
    );
  }
);

/**
 * ================================
 * 2. SETIAP TANGGAL 1
 * ================================
 * Reminder generate laporan bulan sebelumnya
 */
export const monthlyReportBroadcast = onSchedule(
  {
    schedule: "1 of month 09:00",
    timeZone: TIMEZONE,
    region: REGION,
  },
  async () => {
    const title = "Laporan Bulanan Tersedia";
    const body =
      "Anda sudah dapat men-generate laporan untuk bulan sebelumnya melalui aplikasi 😊";

    await sendToAll(title, body);

    console.log("[MONTHLY BROADCAST] laporan bulanan dikirim");
  }
);
