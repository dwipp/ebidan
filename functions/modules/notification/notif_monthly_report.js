import { onSchedule } from "firebase-functions/v2/scheduler";
import admin from "firebase-admin";

const REGION = "asia-southeast2";
const TIMEZONE = "Asia/Jakarta";

if (!admin.apps.length) {
  admin.initializeApp();
}

const sendToAll = async (title, body) => {
  return admin.messaging().send({
    topic: "all",
    notification: { title, body },
  });
};

const sendToBidanDesa = async (title, body) => {
  return admin.messaging().send({
    topic: "bidan_desa",
    notification: { title, body },
  });
};

const sendToPMB = async (title, body) => {
  return admin.messaging().send({
    topic: "pmb",
    notification: { title, body },
  });
};

const sendToKoordinator = async (title, body) => {
  return admin.messaging().send({
    topic: "koordinator",
    notification: { title, body },
  });
};


/**
 * ================================
 * 2. SETIAP TANGGAL 1
 * ================================
 */
export const monthlyReportBroadcast = onSchedule(
  {
    schedule: "1 of month 09:00",
    timeZone: TIMEZONE,
    region: REGION,
  },
  async () => {
    const now = new Date();
    const monthIndex = now.getMonth(); // 0–11

    const message =
      MONTHLY_REPORT_MESSAGES[
        monthIndex % MONTHLY_REPORT_MESSAGES.length
      ];

    await sendToAll(message.title, message.body);

    console.log(
      `[MONTHLY BROADCAST] title="${message.title}"`
    );
  }
);


// Bulanan – laporan
const MONTHLY_REPORT_MESSAGES = [
    {
        title: "Laporan Bulanan Siap 📊",
        body: "Laporan bulan sebelumnya sudah bisa di-generate melalui eBidan.",
    },
    {
        title: "Saatnya Generate Laporan 😊",
        body: "Anda sudah dapat membuat laporan untuk periode bulan lalu di eBidan.",
    },
    {
        title: "Laporan Bulanan Tersedia 📄",
        body: "Silakan generate laporan bulan sebelumnya untuk melengkapi dokumentasi.",
    },
    {
        title: "Laporan Bulanan Sudah Tersedia 📈",
        body: "Laporan untuk bulan sebelumnya sudah bisa Anda generate langsung di eBidan.",
    },
    {
        title: "Yuk, Cek Laporan Bulanan 📄",
        body: "Saatnya men-generate laporan bulan lalu agar dokumentasi tetap lengkap.",
    },
    {
        title: "Waktunya Rekap Bulanan 😊",
        body: "Laporan bulan sebelumnya sudah siap dan bisa dibuat melalui eBidan.",
    },
    {
        title: "Rekap Bulanan Siap Digenerate 🗂️",
        body: "Silakan generate laporan bulan lalu untuk kebutuhan pencatatan dan pelaporan.",
    },
    {
        title: "Laporan Bulan Lalu Sudah Siap 📊",
        body: "Anda sudah dapat membuat laporan periode bulan sebelumnya di eBidan.",
    },
    {
        title: "Lengkapi Laporan Bulanan ✨",
        body: "Generate laporan bulan sebelumnya agar data tersimpan rapi dan siap digunakan.",
    },
    {
        title: "Laporan Siap Digunakan 📘",
        body: "Laporan bulan lalu sudah tersedia dan bisa Anda generate kapan saja di eBidan.",
    }

];
