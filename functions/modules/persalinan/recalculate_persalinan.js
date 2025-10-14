import { onRequest } from "firebase-functions/v2/https";
import { db } from "../firebase.js";
import { getMonthString, safeIncrement } from "../helpers.js";

const REGION = "asia-southeast2";

export const recalculatePersalinanStats = onRequest(
  { region: REGION },
  async (req, res) => {
    try {
      const snapshot = await db.collection("kehamilan").get();
      const statsByBidan = {};
      const latestMonthByBidan = {}; // track bulan terakhir per bidan

      snapshot.forEach((doc) => {
        const data = doc.data();
        if (!data.id_bidan) return;

        const idBidan = data.id_bidan;
        if (!statsByBidan[idBidan]) statsByBidan[idBidan] = { by_month: {} };

        const persalinanList = Array.isArray(data.persalinan) ? data.persalinan : [];
        for (const p of persalinanList) {
          let tgl;
          if (p.tgl_persalinan?.toDate) tgl = p.tgl_persalinan.toDate();
          else if (p.tgl_persalinan) tgl = new Date(p.tgl_persalinan);
          if (!tgl || isNaN(tgl)) continue;

          const monthKey = getMonthString(tgl);

          // track latest month per bidan
          if (!latestMonthByBidan[idBidan] || monthKey > latestMonthByBidan[idBidan]) {
            latestMonthByBidan[idBidan] = monthKey;
          }

          if (!statsByBidan[idBidan].by_month[monthKey]) {
            statsByBidan[idBidan].by_month[monthKey] = { 
              persalinan: { 
                total: 0, tempat_rs: 0, tempat_rsb: 0, 
                tempat_klinik: 0, tempat_bpm: 0, tempat_pkm: 0, 
                tempat_poskesdes: 0, tempat_polindes: 0, persalinan_faskes: 0,
                tempat_rumah_nakes: 0, tempat_jalan_nakes: 0, persalinan_nakes: 0,
                tempat_rumah_dk_klg: 0, cara_normal: 0, cara_vacuum: 0, 
                cara_forceps: 0, cara_sc: 0
              },
              kunjungan: { abortus: 0 },
              resti: { abortus: 0 },
            };
          } else {
            if (!statsByBidan[idBidan].by_month[monthKey].persalinan) {
              statsByBidan[idBidan].by_month[monthKey].persalinan = { 
                total: 0, tempat_rs: 0, tempat_rsb: 0, 
                tempat_klinik: 0, tempat_bpm: 0, tempat_pkm: 0, 
                tempat_poskesdes: 0, tempat_polindes: 0, persalinan_faskes: 0,
                tempat_rumah_nakes: 0, tempat_jalan_nakes: 0, persalinan_nakes: 0,
                tempat_rumah_dk_klg: 0, cara_normal: 0, cara_vacuum: 0, 
                cara_forceps: 0, cara_sc: 0
              };
            }
            if (!statsByBidan[idBidan].by_month[monthKey].kunjungan) {
              statsByBidan[idBidan].by_month[monthKey].kunjungan = { abortus: 0 };
            }
            if (!statsByBidan[idBidan].by_month[monthKey].resti) {
              statsByBidan[idBidan].by_month[monthKey].resti = { abortus: 0 };
            }
          }

          // hitung total persalinan
          safeIncrement(statsByBidan[idBidan].by_month[monthKey].persalinan, "total");

          // hitung tempat_rs (p.tempat === "Rumah Sakit")
          if (typeof p.tempat === "string" && p.tempat.trim().toLowerCase() === "rumah sakit") {
            safeIncrement(statsByBidan[idBidan].by_month[monthKey].persalinan, "tempat_rs");
            safeIncrement(statsByBidan[idBidan].by_month[monthKey].persalinan, "persalinan_faskes");
          }

          // hitung tempat_rsb (p.tempat === "Rumah Sakit Bersalin")
          if (typeof p.tempat === "string" && p.tempat.trim().toLowerCase() === "rumah sakit bersalin") {
            safeIncrement(statsByBidan[idBidan].by_month[monthKey].persalinan, "tempat_rsb");
            safeIncrement(statsByBidan[idBidan].by_month[monthKey].persalinan, "persalinan_faskes");
          }

          // hitung tempat_klinik (p.tempat === "Klinik")
          if (typeof p.tempat === "string" && p.tempat.trim().toLowerCase() === "klinik") {
            safeIncrement(statsByBidan[idBidan].by_month[monthKey].persalinan, "tempat_klinik");
            safeIncrement(statsByBidan[idBidan].by_month[monthKey].persalinan, "persalinan_faskes");
          }

          // hitung tempat_bpm (p.tempat === "Bidan Praktik Mandiri")
          if (typeof p.tempat === "string" && p.tempat.trim().toLowerCase() === "bidan praktik mandiri") {
            safeIncrement(statsByBidan[idBidan].by_month[monthKey].persalinan, "tempat_bpm");
            safeIncrement(statsByBidan[idBidan].by_month[monthKey].persalinan, "persalinan_faskes");
          }

          // hitung tempat_pkm (p.tempat === "Puskesmas")
          if (typeof p.tempat === "string" && p.tempat.trim().toLowerCase() === "puskesmas") {
            safeIncrement(statsByBidan[idBidan].by_month[monthKey].persalinan, "tempat_pkm");
            safeIncrement(statsByBidan[idBidan].by_month[monthKey].persalinan, "persalinan_faskes");
          }

          // hitung tempat_poskesdes (p.tempat === "Poskesdes")
          if (typeof p.tempat === "string" && p.tempat.trim().toLowerCase() === "poskesdes") {
            safeIncrement(statsByBidan[idBidan].by_month[monthKey].persalinan, "tempat_poskesdes");
            safeIncrement(statsByBidan[idBidan].by_month[monthKey].persalinan, "persalinan_faskes");
          }

          // hitung tempat_polindes (p.tempat === "Polindes")
          if (typeof p.tempat === "string" && p.tempat.trim().toLowerCase() === "polindes") {
            safeIncrement(statsByBidan[idBidan].by_month[monthKey].persalinan, "tempat_polindes");
            safeIncrement(statsByBidan[idBidan].by_month[monthKey].persalinan, "persalinan_faskes");
          }

          // hitung tempat_rumah_nakes
          if (
            typeof p.tempat === "string" &&
            p.tempat.trim().toLowerCase() === "rumah" &&
            typeof p.penolong === "string" &&
            ["dokter", "bidan", "perawat"].includes(p.penolong.trim().toLowerCase())
          ) {
            safeIncrement(statsByBidan[idBidan].by_month[monthKey].persalinan, "tempat_rumah_nakes");
          }

          // hitung tempat_jalan_nakes
          if (
            typeof p.tempat === "string" &&
            p.tempat.trim().toLowerCase() === "jalan" &&
            typeof p.penolong === "string" &&
            ["dokter", "bidan", "perawat"].includes(p.penolong.trim().toLowerCase())
          ) {
            safeIncrement(statsByBidan[idBidan].by_month[monthKey].persalinan, "tempat_jalan_nakes");
          }

          // hitung persalinan_nakes
          const penolong = typeof p.penolong === "string" ? p.penolong.trim().toLowerCase() : "";
          const tempat = typeof p.tempat === "string" ? p.tempat.trim().toLowerCase() : "";

          const persalinanNakesCount = 
            (["rumah sakit","rumah sakit bersalin","klinik","bidan praktik mandiri","puskesmas","poskesdes","polindes"].includes(tempat) ? 1 : 0) +
            (tempat === "rumah" && ["dokter","bidan","perawat"].includes(penolong) ? 1 : 0) +
            (tempat === "jalan" && ["dokter","bidan","perawat"].includes(penolong) ? 1 : 0);

          if (persalinanNakesCount > 0) {
            safeIncrement(statsByBidan[idBidan].by_month[monthKey].persalinan, "persalinan_nakes", persalinanNakesCount);
          }

          // hitung tempat_rumah_dk_klg -> dukun / keluarga
          if (
            typeof p.tempat === "string" &&
            p.tempat.trim().toLowerCase() === "rumah" &&
            typeof p.penolong === "string" &&
            !["dokter", "bidan", "perawat"].includes(p.penolong.trim().toLowerCase())
          ) {
            safeIncrement(statsByBidan[idBidan].by_month[monthKey].persalinan, "tempat_rumah_dk_klg");
          }

          // hitung cara_normal (p.cara === "Spontan Belakang Kepala")
          if (typeof p.cara === "string" && p.cara.trim().toLowerCase() === "spontan belakang kepala") {
            safeIncrement(statsByBidan[idBidan].by_month[monthKey].persalinan, "cara_normal");
          }

          // hitung cara_vacuum (p.cara === "Vacuum Extraction")
          if (typeof p.cara === "string" && p.cara.trim().toLowerCase() === "vacuum extraction") {
            safeIncrement(statsByBidan[idBidan].by_month[monthKey].persalinan, "cara_vacuum");
          }

          // hitung cara_forceps (p.cara === "Forceps Delivery")
          if (typeof p.cara === "string" && p.cara.trim().toLowerCase() === "forceps delivery") {
            safeIncrement(statsByBidan[idBidan].by_month[monthKey].persalinan, "cara_forceps");
          }

          // hitung cara_sc (p.cara === "Section Caesarea (SC)")
          if (typeof p.cara === "string" && p.cara.trim().toLowerCase() === "section caesarea (sc)") {
            safeIncrement(statsByBidan[idBidan].by_month[monthKey].persalinan, "cara_sc");
          }

          // --- logika abortus (umur_kehamilan <= 20 minggu TANPA tambahan hari) ---
          if (p.status_bayi === "Abortus") {
            let umurMinggu = null;
            let lebihDariMinggu = false;

            if (typeof p.umur_kehamilan === "string") {
              // contoh: "20 minggu" atau "20 minggu 5 hari"
              const match = p.umur_kehamilan.match(/(\d+)\s*minggu(?:\s+(\d+)\s*hari)?/i);
              if (match) {
                umurMinggu = parseInt(match[1], 10);
                if (match[2]) {
                  const umurHari = parseInt(match[2], 10);
                  if (umurHari > 0) lebihDariMinggu = true;
                }
              }
            } else if (typeof p.umur_kehamilan === "number") {
              // kalau langsung angka (anggap minggu)
              umurMinggu = p.umur_kehamilan;
            }

            if (
              umurMinggu !== null &&
              umurMinggu >= 0 &&
              umurMinggu <= 20 &&
              !lebihDariMinggu
            ) {
              safeIncrement(statsByBidan[idBidan].by_month[monthKey].kunjungan, "abortus");
              safeIncrement(statsByBidan[idBidan].by_month[monthKey].resti, "abortus");
            }
          }
        }
      });

      const batch = db.batch();
      const now = new Date();
      const startMonthDate = new Date(now.getFullYear(), now.getMonth() - 12, 1); // 13 bulan terakhir
      const startMonthKey = getMonthString(startMonthDate);

      for (const [idBidan, stats] of Object.entries(statsByBidan)) {
        const ref = db.collection("statistics").doc(idBidan);
        const doc = await ref.get();
        const existing = doc.exists ? doc.data() : {};
        const byMonth = {};

        // gabungkan existing.by_month yang masih dalam 13 bulan terakhir
        if (existing.by_month) {
          for (const [month, counts] of Object.entries(existing.by_month)) {
            if (month >= startMonthKey) {
              byMonth[month] = counts;
              if (!byMonth[month].kunjungan) byMonth[month].kunjungan = { abortus: 0 };
              if (!byMonth[month].resti) byMonth[month].resti = { abortus: 0 };
              if (typeof byMonth[month].kunjungan.abortus !== "number") {
                byMonth[month].kunjungan.abortus = 0;
              }
              if (typeof byMonth[month].resti.abortus !== "number") {
                byMonth[month].resti.abortus = 0;
              }
              if (!byMonth[month].persalinan) byMonth[month].persalinan = { 
                total: 0, tempat_rs: 0, tempat_rsb: 0, 
                tempat_klinik: 0, tempat_bpm: 0, tempat_pkm: 0, 
                tempat_poskesdes: 0, tempat_polindes: 0, persalinan_faskes: 0,
                tempat_rumah_nakes: 0, tempat_jalan_nakes: 0, persalinan_nakes: 0,
                tempat_rumah_dk_klg: 0, cara_normal: 0, cara_vacuum: 0, 
                cara_forceps: 0, cara_sc: 0
              };
            }
          }
        }

        // tambahkan data baru dari stats
        for (const [month, counts] of Object.entries(stats.by_month)) {
          if (month < startMonthKey) continue; // skip bulan lama
          if (!byMonth[month]) {
            byMonth[month] = { 
              persalinan: { 
                total: 0, tempat_rs: 0, tempat_rsb: 0, 
                tempat_klinik: 0, tempat_bpm: 0, tempat_pkm: 0, 
                tempat_poskesdes: 0, tempat_polindes: 0, persalinan_faskes: 0,
                tempat_rumah_nakes: 0, tempat_jalan_nakes: 0, persalinan_nakes: 0,
                tempat_rumah_dk_klg: 0, cara_normal: 0, cara_vacuum: 0, 
                cara_forceps: 0, cara_sc: 0
              }, 
              kunjungan: { abortus: 0 }, 
              resti: { abortus: 0 } 
            };
          }

          byMonth[month].persalinan.total = counts.persalinan.total;
          byMonth[month].persalinan.tempat_rs = counts.persalinan.tempat_rs;
          byMonth[month].persalinan.tempat_rsb = counts.persalinan.tempat_rsb;
          byMonth[month].persalinan.tempat_klinik = counts.persalinan.tempat_klinik;
          byMonth[month].persalinan.tempat_bpm = counts.persalinan.tempat_bpm;
          byMonth[month].persalinan.tempat_pkm = counts.persalinan.tempat_pkm;
          byMonth[month].persalinan.tempat_poskesdes = counts.persalinan.tempat_poskesdes;
          byMonth[month].persalinan.tempat_polindes = counts.persalinan.tempat_polindes;
          byMonth[month].persalinan.persalinan_faskes = counts.persalinan.persalinan_faskes;
          byMonth[month].persalinan.tempat_rumah_nakes = counts.persalinan.tempat_rumah_nakes;
          byMonth[month].persalinan.tempat_jalan_nakes = counts.persalinan.tempat_jalan_nakes;
          byMonth[month].persalinan.persalinan_nakes = counts.persalinan.persalinan_nakes;
          byMonth[month].persalinan.tempat_rumah_dk_klg = counts.persalinan.tempat_rumah_dk_klg;
          byMonth[month].persalinan.cara_normal = counts.persalinan.cara_normal;
          byMonth[month].persalinan.cara_vacuum = counts.persalinan.cara_vacuum;
          byMonth[month].persalinan.cara_forceps = counts.persalinan.cara_forceps;
          byMonth[month].persalinan.cara_sc = counts.persalinan.cara_sc;
          byMonth[month].kunjungan.abortus = counts.kunjungan.abortus;
          byMonth[month].resti.abortus = counts.resti.abortus;
        }

        // set last_updated_month sesuai bulan terbaru
        const lastUpdatedMonth = latestMonthByBidan[idBidan] || getMonthString(new Date());

        batch.set(
          ref,
          { ...existing, by_month: byMonth, last_updated_month: lastUpdatedMonth },
          { merge: true }
        );

        console.log(`Recalculated persalinan stats for bidan: ${idBidan}, last month: ${lastUpdatedMonth}`);
      }

      await batch.commit();

      res.status(200).json({
        success: true,
        message: "Recalculated persalinan stats",
        statsByBidan,
      });
    } catch (error) {
      console.error("Error recalculating persalinan stats:", error);
      res.status(500).json({ success: false, error: error.message });
    }
  }
);
