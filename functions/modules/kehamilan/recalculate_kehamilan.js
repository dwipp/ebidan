import { onRequest } from "firebase-functions/v2/https";
import { getMonthString } from "../helpers.js";
import { db } from "../firebase.js";

const REGION = "asia-southeast2";

export const recalculateKehamilanStats = onRequest({ region: REGION }, async (req, res) => {
  try {
    const snapshot = await db.collection("kehamilan").get();
    const statsByBidan = {};

    snapshot.forEach(doc => {
      const data = doc.data();
      if (!data.id_bidan) return;

      const idBidan = data.id_bidan;
      if (!statsByBidan[idBidan]) {
        statsByBidan[idBidan] = {
          by_month: {},
          latestMonth: null
        };
      }

      // --- Tentukan bulan kehamilan ---
      let monthKey;
      if (data.created_at?.toDate) {
        monthKey = getMonthString(data.created_at.toDate());
      } else if (data.created_at) {
        monthKey = getMonthString(new Date(data.created_at));
      } else {
        monthKey = getMonthString(new Date()); // fallback
      }

      // update latestMonth
      if (!statsByBidan[idBidan].latestMonth || monthKey > statsByBidan[idBidan].latestMonth) {
        statsByBidan[idBidan].latestMonth = monthKey;
      }

      // inisialisasi by_month
      if (!statsByBidan[idBidan].by_month[monthKey]) {
        statsByBidan[idBidan].by_month[monthKey] = {
          kehamilan: { total: 0 },
          resti: { 
            resti_nakes: 0, resti_masyarakat: 0, anemia: 0, 
            too_young: 0, too_old: 0, paritas_tinggi: 0, tb_under_145: 0, pernah_abortus: 0 }
        };
      }

      // increment total
      statsByBidan[idBidan].by_month[monthKey].kehamilan.total++;

      // increment sesuai status_resti
      if (data.status_resti === "Nakes") {
        statsByBidan[idBidan].by_month[monthKey].resti.resti_nakes++;
      } else if (data.status_resti === "Masyarakat") {
        statsByBidan[idBidan].by_month[monthKey].resti.resti_masyarakat++;
      }

      // cek hemoglobin untuk anemia
      if (typeof data.hemoglobin === "number" && data.hemoglobin < 11) {
        statsByBidan[idBidan].by_month[monthKey].resti.anemia++;
      }

      // resti usia
      const usia = Number(data.usia);
      if (usia < 20) {
        statsByBidan[idBidan].by_month[monthKey].resti.too_young++;
      }else if (usia > 35) {
        statsByBidan[idBidan].by_month[monthKey].resti.too_old++;
      }
      
      if (typeof data.gpa === "string") {
        // resti paritas tinggi (gravida >= 4)
        const matchGravida = data.gpa.match(/G(\d+)/i); // ambil angka setelah G
        if (matchGravida) {
          const gravida = Number(matchGravida[1]);
          if (!isNaN(gravida) && gravida >= 4) {
            statsByBidan[idBidan].by_month[monthKey].resti.paritas_tinggi++;
          }
        }

        // resti pernah abortus (abortus > 0)
        const matchAbortus = data.gpa.match(/A(\d+)/i); // ambil angka setelah A
        if (matchAbortus) {
          const abortus = Number(matchAbortus[1]);
          if (!isNaN(abortus) && abortus > 0) {
            statsByBidan[idBidan].by_month[monthKey].resti.pernah_abortus++;
          }
        }
      }

      // resti Risiko panggul sempit (tb < 145)
      const tb = Number(data.tb);
      if (tb < 145) {
        statsByBidan[idBidan].by_month[monthKey].resti.tb_under_145++;
      }

    });

    // --- Tentukan bulan awal 13 bulan terakhir ---
    const now = new Date();
    const startMonthDate = new Date(now.getFullYear(), now.getMonth() - 12, 1);
    const startMonthKey = getMonthString(startMonthDate);

    const batch = db.batch();

    for (const [idBidan, stats] of Object.entries(statsByBidan)) {
      const ref = db.doc(`statistics/${idBidan}`);
      const doc = await ref.get();
      const existing = doc.exists ? doc.data() : {};
      const byMonth = {};
      const skippedMonths = [];

      // gabungkan existing.by_month yang masih dalam 13 bulan terakhir
      if (existing.by_month) {
        for (const [month, counts] of Object.entries(existing.by_month)) {
          if (month >= startMonthKey) {
            byMonth[month] = counts;
            // pastikan field anemia tetap ada
            if (!byMonth[month].resti.anemia) {
              byMonth[month].resti.anemia = 0;
            }
            if (!byMonth[month].resti.resti_masyarakat) {
              byMonth[month].resti.resti_masyarakat = 0;
            }
            if (!byMonth[month].resti.resti_nakes) {
              byMonth[month].resti.resti_nakes = 0;
            }
            if (!byMonth[month].resti.too_young) {
              byMonth[month].resti.too_young = 0;
            }
            if (!byMonth[month].resti.too_old) {
              byMonth[month].resti.too_old = 0;
            }
            if (!byMonth[month].resti.paritas_tinggi) {
              byMonth[month].resti.paritas_tinggi = 0;
            }
            if (!byMonth[month].resti.tb_under_145) {
              byMonth[month].resti.tb_under_145 = 0;
            }
            if (!byMonth[month].resti.pernah_abortus) {
              byMonth[month].resti.pernah_abortus = 0;
            }

          } else {
            skippedMonths.push(month);
          }
        }
      }

      // tambahkan data baru dari stats
      for (const [month, counts] of Object.entries(stats.by_month)) {
        if (month < startMonthKey) {
          skippedMonths.push(month);
          continue;
        }

        if (!byMonth[month]) byMonth[month] = {};
        if (!byMonth[month].kehamilan) {
          byMonth[month].kehamilan = { total: 0 };
        }
        if (!byMonth[month].resti) {
          byMonth[month].resti = { 
            resti_nakes: 0, resti_masyarakat: 0, anemia: 0, 
            too_young: 0, too_old: 0, paritas_tinggi: 0, 
            tb_under_145: 0, pernah_abortus: 0 
          };
        }

        byMonth[month].kehamilan.total = counts.kehamilan.total ?? 0;
        byMonth[month].resti.resti_nakes = counts.resti?.resti_nakes ?? 0;
        byMonth[month].resti.resti_masyarakat = counts.resti?.resti_masyarakat ?? 0;
        byMonth[month].resti.anemia = counts.resti?.anemia ?? 0;
        byMonth[month].resti.too_young = counts.resti?.too_young ?? 0;
        byMonth[month].resti.too_old = counts.resti?.too_old ?? 0;
        byMonth[month].resti.paritas_tinggi = counts.resti?.paritas_tinggi ?? 0;
        byMonth[month].resti.tb_under_145 = counts.resti?.tb_under_145 ?? 0;
        byMonth[month].resti.pernah_abortus = counts.resti?.pernah_abortus ?? 0;
      }

      batch.set(ref, {
        ...existing,
        last_updated_month: stats.latestMonth ?? getMonthString(new Date()),
        by_month: byMonth
      }, { merge: true });

      console.log(`Bidan: ${idBidan} | Bulan terbaru: ${stats.latestMonth} | Bulan di-skip: ${skippedMonths.join(", ")}`);
    }

    await batch.commit();
    res.status(200).send({ message: "Recalculation complete", statsByBidan });

  } catch (error) {
    console.error("Recalculation error:", error);
    res.status(500).send({ error: error.message });
  }
});
