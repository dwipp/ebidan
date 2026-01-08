import { onSchedule } from "firebase-functions/v2/scheduler";
import admin from "firebase-admin";

const REGION = "asia-southeast2";
const TIMEZONE = "Asia/Jakarta";

if (!admin.apps.length) {
  admin.initializeApp();
}

const sendToBidan = async (title, body) => {
  return admin.messaging().send({
    topic: "bidan",
    notification: { title, body },
  });
};

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
 * 1. SETIAP HARI SUNDAY
 * ================================
 */
export const weeklySundayBroadcast = onSchedule(
  {
    schedule: "every sunday 19:00",
    timeZone: TIMEZONE,
    region: REGION,
  },
  async () => {
    const now = new Date();

    // hitung minggu ke-N dalam tahun
    const startOfYear = new Date(now.getFullYear(), 0, 1);
    const diffDays = Math.floor(
      (now.getTime() - startOfYear.getTime()) / 86400000
    );
    const weekNumber = Math.ceil((diffDays + startOfYear.getDay() + 1) / 7);

    let message;
    const idx = weekNumber % SUNDAY_EDU_MESSAGES.length;
    message = SUNDAY_EDU_MESSAGES[idx];

    await sendToAll(message.title, message.body);

    console.log(
      `[SUNDAY BROADCAST] week=${weekNumber} title="${message.title}"`
    );
  }
);


const SUNDAY_EDU_MESSAGES = [
    {
        title: "eBidan bisa offline mode loh",
        body: "Tidak ada jaringan internet? Tidak masalah, eBidan tetap lancar digunakan :)",
    },
    {
        title: "Sedang Posyandu?",
        body: "Langsung input saja data ibu hamil dan kunjungannya ke eBidan :)",
    },
    {
        title: "eBidan bisa deteksi resti loh",
        body: "eBidan bisa kasih tau kamu resti dari ibu hamil, coba deh lengkapi data ibu hamil nya :)",
    },
    {
        title: "GPA di eBidan otomatis loh",
        body: "Tidak perlu buka data kohort untuk menghitung GPA ibu hamil, eBidan sudah siapkan untuk kamu :)",
    },
    {
        title: "HTP otomatis buat kehamilan baru",
        body: "Tidak perlu hitung-hitung lagi, sudah disiapkan oleh eBidan :)",
    },
    {
        title: "Usia Kehamilan otomatis di Kunjungan",
        body: "Kamu tidak perlu hitung-hitung lagi ya, percaya aja sama eBidan :)",
    },
    {
        title: "Data pasien gampang dicari loh",
        body: "Kamu bisa cari pasien berdasarkan NIK atau berdasarkan riwayat kunjungan :)",
    },
    {
        title: "Manfaatkan Laporan eBidan",
        body: "Laporan bulanan dari eBidan sangat berguna loh buat mempermudah pekerjaan mu :)",
    },
    {
        title: "Penasaran dengan progress kehamilan?",
        body: "eBidan punya fitur grafik Kunjungan untuk melihat progress kehamilan setiap ibu hamil :)",
    },
    {
        title: "Penasaran dengan statistik kehamilan?",
        body: "Kamu bisa cek statistiknya di eBidan, semua tersusun dengan rapi dan mudah dibaca :)",
    },
    {
        title: "Ada persalinan?",
        body: "Catat persalinannya di eBidan, biarkan eBidan kelola datanya :)",
    },
];