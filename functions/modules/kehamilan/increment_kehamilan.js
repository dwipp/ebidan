import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { db } from "../firebase.js";
import { getMonthString, safeIncrement } from "../helpers.js";

const REGION = "asia-southeast2";

export const incrementKehamilanCount = onDocumentCreated(
  { document: "kehamilan/{kehamilanId}", region: REGION },
  async (event) => {
    const kehamilanData = event.data?.data();
    if (!kehamilanData || !kehamilanData.id_bidan) return;

    const idBidan = kehamilanData.id_bidan;
    const statsRef = db.doc(`statistics/${idBidan}`);

    // ambil tanggal dari field created_at di dokumen kehamilan
    let currentMonth = null;
    if (kehamilanData.created_at?.toDate) {
      currentMonth = getMonthString(kehamilanData.created_at.toDate());
    } else if (kehamilanData.created_at) {
      currentMonth = getMonthString(new Date(kehamilanData.created_at));
    } else {
      currentMonth = getMonthString(new Date()); // fallback
    }

    await db.runTransaction(async (t) => {
      const doc = await t.get(statsRef);

      if (!doc.exists) {
        t.set(statsRef, {
          kehamilan: { all_bumil_count: 1 },
          last_updated_month: currentMonth,
          by_month: {
            [currentMonth]: {
              kehamilan: { total: 1 },
              resti: {
                resti_nakes: kehamilanData.status_resti === "Nakes" ? 1 : 0,
                resti_masyarakat: kehamilanData.status_resti === "Masyarakat" ? 1 : 0,
                anemia:
                  kehamilanData.hemoglobin !== undefined 
                  ? Number(kehamilanData.hemoglobin) < 11 ? 1 : 0
                  : 0,
                too_young: 
                  kehamilanData.usia !== undefined 
                  ? Number(kehamilanData.usia) < 20 ? 1 : 0 
                  : 0,
                too_old: 
                  kehamilanData.usia !== undefined 
                  ? Number(kehamilanData.usia) > 35 ? 1 : 0 
                  : 0,
                paritas_tinggi: (() => {
                  if (typeof kehamilanData.gpa === "string") {
                    const match = kehamilanData.gpa.match(/G(\d+)/i);
                    if (match) {
                      const gravida = Number(match[1]);
                      return !isNaN(gravida) && gravida >= 4 ? 1 : 0;
                    }
                  }
                  return 0;
                })(),
                tb_under_145:
                  kehamilanData.tb !== undefined 
                    ? Number(kehamilanData.tb) < 145 ? 1 : 0 
                    : 0,
              }
            }
          }
        });
        console.log(`Created new statistics for bidan: ${idBidan}, month: ${currentMonth}`);
        return;
      }

      const data = doc.data();
      const kehamilan = data.kehamilan || { all_bumil_count: 0 };
      const byMonth = data.by_month || {};

      // pastikan struktur by_month ada
      if (!byMonth[currentMonth]) byMonth[currentMonth] = {};
      if (!byMonth[currentMonth].kehamilan) {
        byMonth[currentMonth].kehamilan = { total: 0 };
      }
      if (!byMonth[currentMonth].resti) {
        byMonth[currentMonth].resti = { 
          resti_nakes: 0, resti_masyarakat: 0, anemia: 0, 
          too_young: 0, too_old: 0, paritas_tinggi: 0, tb_under_145: 0 };
      } else {
        if (byMonth[currentMonth].resti.anemia === undefined) {
          byMonth[currentMonth].resti.anemia = 0;
        }
        if (byMonth[currentMonth].resti.resti_nakes === undefined) {
          byMonth[currentMonth].resti.resti_nakes = 0;
        }
        if (byMonth[currentMonth].resti.resti_masyarakat === undefined) {
          byMonth[currentMonth].resti.resti_masyarakat = 0;
        }
        if (byMonth[currentMonth].resti.too_young === undefined) {
          byMonth[currentMonth].resti.too_young = 0;
        }
        if (byMonth[currentMonth].resti.too_old === undefined) {
          byMonth[currentMonth].resti.too_old = 0;
        }
        if (byMonth[currentMonth].resti.paritas_tinggi === undefined) {
          byMonth[currentMonth].resti.paritas_tinggi = 0;
        }
        if (byMonth[currentMonth].resti.tb_under_145 === undefined) {
          byMonth[currentMonth].resti.tb_under_145 = 0;
        }
      }

      // increment total
      safeIncrement(byMonth[currentMonth].kehamilan, "total");

      // increment resti sesuai status
      if (kehamilanData.status_resti === "Nakes") {
        safeIncrement(byMonth[currentMonth].resti, "resti_nakes");
      } else if (kehamilanData.status_resti === "Masyarakat") {
        safeIncrement(byMonth[currentMonth].resti, "resti_masyarakat");
      }

      // increment anemia (Hb < 11)
      if (
        kehamilanData.hemoglobin !== undefined &&
        Number(kehamilanData.hemoglobin) < 11
      ) {
        safeIncrement(byMonth[currentMonth].resti, "anemia");
      }

      // resti usia
      if (kehamilanData.usia !== undefined) {
        const usia = Number(kehamilanData.usia);
        if (!isNaN(usia)) {
          if (usia < 20) {
            safeIncrement(byMonth[currentMonth].resti, 'too_young');
          } else if (usia > 35) {
            safeIncrement(byMonth[currentMonth].resti, 'too_old');
          }
        }
      }

      // resti paritas_tinggi (G >= 4)
      if (typeof kehamilanData.gpa === "string") {
        const match = kehamilanData.gpa.match(/G(\d+)/i);
        if (match) {
          const gravida = Number(match[1]);
          if (!isNaN(gravida) && gravida >= 4) {
            safeIncrement(byMonth[currentMonth].resti, "paritas_tinggi");
          }
        }
      }

      // resti panggul sempit (tb<145)
      if (kehamilanData.tb !== undefined) {
        const tb = Number(kehamilanData.tb);
        if (tb < 145) {
          safeIncrement(byMonth[currentMonth].resti, "tb_under_145");
        }
      }

      // --- LOGIC BATAS 13 BULAN ---
      const months = Object.keys(byMonth).sort(); // YYYY-MM format -> urut ascending
      if (months.length > 13) {
        const oldestMonth = months[0];
        delete byMonth[oldestMonth];
        console.log(`Month limit exceeded. Deleted oldest month: ${oldestMonth} for bidan: ${idBidan}`);
      }

      t.set(
        statsRef,
        {
          ...data,
          kehamilan: {
            all_bumil_count: safeIncrement(kehamilan, "all_bumil_count"),
          },
          last_updated_month: currentMonth,
          by_month: byMonth,
        },
        { merge: true }
      );

      console.log(
        `Incremented kehamilan count for month: ${currentMonth}, bidan: ${idBidan}, status_resti: ${kehamilanData.status_resti || "-"}, anemia: ${
          kehamilanData.hemoglobin !== undefined && Number(kehamilanData.hemoglobin) < 11 ? "yes" : "no"
        }, paritas_tinggi: ${
          typeof kehamilanData.gpa === "string" && /G(\d+)/i.test(kehamilanData.gpa) && Number(kehamilanData.gpa.match(/G(\d+)/i)[1]) >= 4 ? "yes" : "no"
        }`
      );
    });
  }
);
