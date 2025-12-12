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

    // Tentukan bulan dari created_at
    let currentMonth;
    if (kehamilanData.created_at?.toDate) {
      currentMonth = getMonthString(kehamilanData.created_at.toDate());
    } else if (kehamilanData.created_at) {
      currentMonth = getMonthString(new Date(kehamilanData.created_at));
    } else {
      currentMonth = getMonthString(new Date());
    }

    await db.runTransaction(async (t) => {
      const doc = await t.get(statsRef);
      if (!doc.exists) return;

      const data = doc.data();
      const byMonth = data.by_month || {};

      // Pastikan struktur bulan & kategori selalu ada (identik dengan increment)
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
          tb_under_145: 0,
          pernah_abortus: 0,
        };
      }

      // Normalisasi agar tidak undefined
      const resti = byMonth[currentMonth].resti;
      const ensure = (field) => {
        if (resti[field] === undefined) resti[field] = 0;
      };

      [
        "resti_nakes",
        "resti_masyarakat",
        "anemia",
        "too_young",
        "too_old",
        "paritas_tinggi",
        "tb_under_145",
        "pernah_abortus",
      ].forEach((f) => ensure(f));

      // ========== DECREMENT LOGIC ==========
      safeDecrement(byMonth[currentMonth].kehamilan, "total");

      // status resti
      if (kehamilanData.status_resti === "Nakes") {
        safeDecrement(resti, "resti_nakes");
      } else if (kehamilanData.status_resti === "Masyarakat") {
        safeDecrement(resti, "resti_masyarakat");
      }

      // anemia
      if (
        kehamilanData.hemoglobin !== undefined &&
        Number(kehamilanData.hemoglobin) < 11
      ) {
        safeDecrement(resti, "anemia");
      }

      // usia
      if (kehamilanData.usia !== undefined) {
        const usia = Number(kehamilanData.usia);
        if (!isNaN(usia)) {
          if (usia < 20) safeDecrement(resti, "too_young");
          else if (usia > 35) safeDecrement(resti, "too_old");
        }
      }

      // gpa
      if (typeof kehamilanData.gpa === "string") {
        const matchG = kehamilanData.gpa.match(/G(\d+)/i);
        if (matchG) {
          const gravida = Number(matchG[1]);
          if (!isNaN(gravida) && gravida >= 4) {
            safeDecrement(resti, "paritas_tinggi");
          }
        }

        const matchA = kehamilanData.gpa.match(/A(\d+)/i);
        if (matchA) {
          const abortus = Number(matchA[1]);
          if (!isNaN(abortus) && abortus > 0) {
            safeDecrement(resti, "pernah_abortus");
          }
        }
      }

      // tb
      if (kehamilanData.tb !== undefined) {
        const tb = Number(kehamilanData.tb);
        if (!isNaN(tb) && tb < 145) {
          safeDecrement(resti, "tb_under_145");
        }
      }

      // update Firestore
      t.set(
        statsRef,
        {
          ...data,
          kehamilan: {
            all_bumil_count: safeDecrement(
              data.kehamilan || { all_bumil_count: 0 },
              "all_bumil_count"
            ),
          },
          last_updated_month: currentMonth,
          by_month: byMonth,
        },
        { merge: true }
      );

      console.log(
        `Decrement kehamilan - bidan: ${idBidan}, month: ${currentMonth}`
      );
    });
  }
);
