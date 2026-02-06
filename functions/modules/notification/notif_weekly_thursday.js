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


/**
 * ================================
 * 1. SETIAP HARI KAMIS
 * ================================
 */
export const weeklyThursdayBroadcast = onSchedule(
  {
    schedule: "every thursday 09:00",
    timeZone: TIMEZONE,
    region: REGION,
    retryCount: 0,
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

    if (weekNumber % 2 === 1) {
      // minggu ganjil → ibu hamil
      const idx = weekNumber % WEDNESDAY_PREGNANCY_MESSAGES.length;
      message = WEDNESDAY_PREGNANCY_MESSAGES[idx];
    } else {
      // minggu genap → manual
      const idx = weekNumber % WEDNESDAY_MANUAL_MESSAGES.length;
      message = WEDNESDAY_MANUAL_MESSAGES[idx];
    }

    await sendToBidan(message.title, message.body);

    console.log(
      `[WEDNESDAY BROADCAST] week=${weekNumber} title="${message.title}"`
    );
  }
);


/**
 * ================================
 * WORDING VARIANTS
 * ================================
 */

// Minggu ganjil – input data ibu hamil
const WEDNESDAY_PREGNANCY_MESSAGES = [
    {
        title: "Jangan Lupa Input Data, ya 🌸",
        body: "Data kehamilan, kunjungan, dan persalinan yang lengkap membantu pencatatan dan laporan jadi lebih mudah.",
    },
    {
        title: "Yuk, Lengkapi Data Ibu Hamil 🤍",
        body: "Luangkan sedikit waktu untuk melengkapi data kehamilan, kunjungan, dan persalinan agar tetap terpantau.",
    },
    {
        title: "Pengingat Pencatatan Ibu Hamil 😊",
        body: "Pastikan data kehamilan, kunjungan, dan persalinan sudah terinput dengan rapi di eBidan.",
    },
    {
        title: "Sedikit Waktu, Data Lebih Rapi 🌼",
        body: "Lengkapi data kehamilan, kunjungan, dan persalinan agar pencatatan tetap tertib dan mudah ditelusuri.",
    },
    {
        title: "Yuk, Update Data Ibu Hamil 🤍",
        body: "Update data kehamilan, kunjungan, dan persalinan membantu pemantauan berjalan lebih optimal.",
    },
    {
        title: "Catatan Ibu Hamil Perlu Dicek ✍️",
        body: "Pastikan data kehamilan, kunjungan, dan persalinan sudah terinput dengan lengkap dan benar.",
    },
    {
        title: "Lengkapi Catatan Layanan 🌷",
        body: "Pencatatan kehamilan, kunjungan, dan persalinan yang lengkap memudahkan rekap dan laporan.",
    },
    {
        title: "Data Lengkap, Layanan Lebih Baik 😊",
        body: "Dengan melengkapi data kehamilan, kunjungan, dan persalinan, pemantauan ibu hamil jadi lebih optimal.",
    },
    {
        title: "Yuk, Rapikan Data Layanan 📘",
        body: "Rapikan data kehamilan, kunjungan, dan persalinan agar semua catatan tersimpan rapi di eBidan.",
    },
    {
        title: "Pengingat Input Data Ibu Hamil 🌸",
        body: "Luangkan waktu untuk memastikan data kehamilan, kunjungan, dan persalinan sudah tercatat dengan baik.",
    }

];

// Minggu genap – input data manual
const WEDNESDAY_MANUAL_MESSAGES = [
    {
        title: "Pindahkan Data Kohort ke eBidan 📘",
        body: "Yuk, pindahkan data kohort manual ke eBidan supaya pencatatan lebih rapi dan mudah dikelola.",
    },
    {
        title: "Kohort Manual Bisa Masuk Aplikasi ✍️",
        body: "Data dari buku kohort manual dapat Anda input ke eBidan agar tersimpan lebih aman dan siap jadi laporan.",
    },
    {
        title: "Rapikan Data Kohort Manual 🌼",
        body: "Saatnya memindahkan data kohort manual ke eBidan untuk memudahkan monitoring dan pelaporan.",
    },
    {
        title: "Data Kohort Lebih Praktis 📊",
        body: "Dengan memindahkan data kohort manual ke eBidan, pencatatan kehamilan dan layanan jadi lebih teratur.",
    },
    {
        title: "Yuk, Digitalisasi Data Kohort 💡",
        body: "Input data kohort manual ke eBidan agar pencatatan dan laporan bisa dilakukan lebih cepat.",
    },
    {
        title: "Saatnya Pindah ke Digital 📱",
        body: "Data kohort manual bisa Anda pindahkan ke eBidan agar pencatatan lebih rapi dan mudah dicari kembali.",
    },
    {
        title: "Kohort Manual, Kini Lebih Rapi 🌷",
        body: "Yuk, masukkan data kohort dari buku manual ke eBidan untuk memudahkan pemantauan dan laporan.",
    },
    {
        title: "Buku Kohort Bisa Jadi Digital 📘➡️📲",
        body: "Data dari buku kohort manual dapat diinput ke eBidan supaya tersimpan lebih aman dan tidak tercecer.",
    },
    {
        title: "Sedikit Input, Banyak Manfaat ✨",
        body: "Memindahkan data kohort manual ke eBidan membantu pencatatan kehamilan, kunjungan, dan persalinan lebih tertata.",
    },
    {
        title: "Rapikan Kohort Lama 📂",
        body: "Kohort manual yang sudah ada bisa Anda input ke eBidan agar data lebih lengkap dan siap digunakan.",
    },
    {
        title: "Kohort Digital, Kerja Lebih Ringan 😊",
        body: "Dengan memindahkan data kohort manual ke eBidan, pencatatan dan pelaporan jadi lebih praktis.",
    },
    {
        title: "Yuk, Lengkapi Data Kohort 📊",
        body: "Input data kohort manual ke eBidan untuk membantu monitoring ibu hamil dan layanan kebidanan.",
    }
];