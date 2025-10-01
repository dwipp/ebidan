import { onDocumentDeleted } from "firebase-functions/v2/firestore";
import { db } from "../firebase.js";
import { getMonthString, safeDecrement } from "../helpers.js";

const REGION = "asia-southeast2";

export const decrementKehamilanCount = onDocumentDeleted(
  { document: "kehamilan/{kehamilanId}", region: REGION },
  async (event) => {
    const kehamilanData = event.data?.data();
    if (!kehamilanData || !kehamilanData.id_bidan) return;

    const idBidan = kehamilanData.id_bidan;
    const statsRef = db.doc(`statistics/${idBidan}`);

    // ambil bulan dari created_at kehamilan
    let currentMonth;
    if (kehamilanData.created_at?.toDate) {
      currentMonth = getMonthString(kehamilanData.created_at.toDate());
    } else if (kehamilanData.created_at) {
      currentMonth = getMonthString(new Date(kehamilanData.created_at));
    } else {
      currentMonth = getMonthString(new Date()); // fallback
    }

    await db.runTransaction(async (t) => {
      const doc = await t.get(statsRef);
      if (!doc.exists) return;

      const data = doc.data();
      const byMonth = data.by_month || {};

      // pastikan struktur by_month ada
      if (!byMonth[currentMonth]) byMonth[currentMonth] = {};
      if (!byMonth[currentMonth].kehamilan) {
        byMonth[currentMonth].kehamilan = { total: 0 };
      }
      if (!byMonth[currentMonth].resti) {
        byMonth[currentMonth].resti = {
          resti_nakes: 0,
          resti_masyarakat: 0,
          anemia: 0,
          too_young: 0,
          too_old: 0,
          paritas_tinggi: 0,
        };
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
      }

      // decrement total
      safeDecrement(byMonth[currentMonth].kehamilan, "total");

      // decrement sesuai status_resti
      if (kehamilanData.status_resti === "Nakes") {
        safeDecrement(byMonth[currentMonth].resti, "resti_nakes");
      } else if (kehamilanData.status_resti === "Masyarakat") {
        safeDecrement(byMonth[currentMonth].resti, "resti_masyarakat");
      }

      // decrement anemia (Hb < 11)
      if (
        kehamilanData.hemoglobin !== undefined &&
        Number(kehamilanData.hemoglobin) < 11
      ) {
        safeDecrement(byMonth[currentMonth].resti, "anemia");
      }
      
      // resti usia
      if (kehamilanData.usia !== undefined) {
        const usia = Number(kehamilanData.usia);
        if (!isNaN(usia)) {
          if (usia < 20) {
            safeDecrement(byMonth[currentMonth].resti, 'too_young');
          } else if (usia > 35) {
            safeDecrement(byMonth[currentMonth].resti, 'too_old');
          }
        }
      }

      // resti paritas_tinggi (G >= 4)
      if (typeof kehamilanData.gpa === "string") {
        const match = kehamilanData.gpa.match(/G(\d+)/i);
        if (match) {
          const gravida = Number(match[1]);
          if (!isNaN(gravida) && gravida >= 4) {
            safeDecrement(byMonth[currentMonth].resti, "paritas_tinggi");
          }
        }
      }

      t.set(
        statsRef,
        {
          ...data,
          kehamilan: {
            all_bumil_count: safeDecrement(data.kehamilan || { all_bumil_count: 0 }, "all_bumil_count"),
          },
          last_updated_month: currentMonth,
          by_month: byMonth,
        },
        { merge: true }
      );

      console.log(
        `Decremented kehamilan count for month: ${currentMonth}, bidan: ${idBidan}, status_resti: ${kehamilanData.status_resti || "-"}, anemia: ${
          kehamilanData.hemoglobin !== undefined && Number(kehamilanData.hemoglobin) < 11 ? "yes" : "no"
        }, paritas_tinggi: ${
          typeof kehamilanData.gpa === "string" && /G(\d+)/i.test(kehamilanData.gpa) && Number(kehamilanData.gpa.match(/G(\d+)/i)[1]) >= 4 ? "yes" : "no"
        }`
      );
    });
  }
);
