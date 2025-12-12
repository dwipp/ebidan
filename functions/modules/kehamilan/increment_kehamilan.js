import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { db } from "../firebase.js";
import { getMonthString, safeIncrement } from "../helpers.js";

const REGION = "asia-southeast2";

const ensureMonthStructure = (byMonth, monthKey) => {
  if (!byMonth[monthKey] || typeof byMonth[monthKey] !== "object") {
    byMonth[monthKey] = {
      kehamilan: { total: 0 },
      resti: {
        resti_nakes: 0,
        resti_masyarakat: 0,
        anemia: 0,
        too_young: 0,
        too_old: 0,
        paritas_tinggi: 0,
        tb_under_145: 0,
        pernah_abortus: 0,
      },
      pasien: { total: 0 },
      sf: {},
    };
    return;
  }
  // ensure sub-objects exist
  const m = byMonth[monthKey];
  m.kehamilan = m.kehamilan || { total: 0 };
  m.resti = m.resti || {
    resti_nakes: 0,
    resti_masyarakat: 0,
    anemia: 0,
    too_young: 0,
    too_old: 0,
    paritas_tinggi: 0,
    tb_under_145: 0,
    pernah_abortus: 0,
  };
  // make sure each resti field exists
  const r = m.resti;
  r.resti_nakes = Number(r.resti_nakes || 0);
  r.resti_masyarakat = Number(r.resti_masyarakat || 0);
  r.anemia = Number(r.anemia || 0);
  r.too_young = Number(r.too_young || 0);
  r.too_old = Number(r.too_old || 0);
  r.paritas_tinggi = Number(r.paritas_tinggi || 0);
  r.tb_under_145 = Number(r.tb_under_145 || 0);
  r.pernah_abortus = Number(r.pernah_abortus || 0);

  m.pasien = m.pasien || { total: 0 };
  m.sf = m.sf || {};
};

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

      // Jika dokumen statistik belum ada: buat initial object (tidak ada undefined)
      if (!doc.exists) {
        const initialByMonth = {};
        initialByMonth[currentMonth] = {
          kehamilan: { total: 1 },
          resti: {
            resti_nakes: kehamilanData.status_resti === "Nakes" ? 1 : 0,
            resti_masyarakat: kehamilanData.status_resti === "Masyarakat" ? 1 : 0,
            anemia:
              kehamilanData.hemoglobin !== undefined
                ? Number(kehamilanData.hemoglobin) < 11
                  ? 1
                  : 0
                : 0,
            too_young:
              kehamilanData.usia !== undefined
                ? Number(kehamilanData.usia) < 20
                  ? 1
                  : 0
                : 0,
            too_old:
              kehamilanData.usia !== undefined
                ? Number(kehamilanData.usia) > 35
                  ? 1
                  : 0
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
                ? Number(kehamilanData.tb) < 145
                  ? 1
                  : 0
                : 0,
            pernah_abortus: (() => {
              if (typeof kehamilanData.gpa === "string") {
                const match = kehamilanData.gpa.match(/A(\d+)/i);
                if (match) {
                  const abortus = Number(match[1]);
                  return !isNaN(abortus) && abortus > 0 ? 1 : 0;
                }
              }
              return 0;
            })(),
          },
          pasien: { total: 0 },
          sf: {},
        };

        await t.set(
          statsRef,
          {
            kehamilan: { all_bumil_count: 1 },
            last_updated_month: currentMonth,
            by_month: initialByMonth,
          },
          { merge: true }
        );

        console.log(`Created new statistics for bidan: ${idBidan}, month: ${currentMonth}`);
        return;
      }

      // doc exists -> baca data lama
      const data = doc.data() || {};
      const kehamilan = data.kehamilan && typeof data.kehamilan === "object"
        ? { ...data.kehamilan }
        : { all_bumil_count: 0 };

      const byMonth = data.by_month && typeof data.by_month === "object"
        ? { ...data.by_month }
        : {};

      // pastikan struktur month current ada dan lengkap
      ensureMonthStructure(byMonth, currentMonth);

      // increment kehamilan total for the month
      // gunakan safeIncrement hanya untuk memudahkan mutasi, tapi jangan berharap return-nya
      // safeIncrement harus aman juga; jika tidak, kita fallback manual
      try {
        safeIncrement(byMonth[currentMonth].kehamilan, "total");
      } catch (e) {
        // fallback: manual increment
        byMonth[currentMonth].kehamilan.total =
          Number(byMonth[currentMonth].kehamilan.total || 0) + 1;
      }

      // increment resti sesuai status
      if (kehamilanData.status_resti === "Nakes") {
        try {
          safeIncrement(byMonth[currentMonth].resti, "resti_nakes");
        } catch {
          byMonth[currentMonth].resti.resti_nakes =
            Number(byMonth[currentMonth].resti.resti_nakes || 0) + 1;
        }
      } else if (kehamilanData.status_resti === "Masyarakat") {
        try {
          safeIncrement(byMonth[currentMonth].resti, "resti_masyarakat");
        } catch {
          byMonth[currentMonth].resti.resti_masyarakat =
            Number(byMonth[currentMonth].resti.resti_masyarakat || 0) + 1;
        }
      }

      // increment anemia (Hb < 11)
      if (
        kehamilanData.hemoglobin !== undefined &&
        Number(kehamilanData.hemoglobin) < 11
      ) {
        try {
          safeIncrement(byMonth[currentMonth].resti, "anemia");
        } catch {
          byMonth[currentMonth].resti.anemia =
            Number(byMonth[currentMonth].resti.anemia || 0) + 1;
        }
      }

      // resti usia
      if (kehamilanData.usia !== undefined) {
        const usia = Number(kehamilanData.usia);
        if (!isNaN(usia)) {
          if (usia < 20) {
            try {
              safeIncrement(byMonth[currentMonth].resti, "too_young");
            } catch {
              byMonth[currentMonth].resti.too_young =
                Number(byMonth[currentMonth].resti.too_young || 0) + 1;
            }
          } else if (usia > 35) {
            try {
              safeIncrement(byMonth[currentMonth].resti, "too_old");
            } catch {
              byMonth[currentMonth].resti.too_old =
                Number(byMonth[currentMonth].resti.too_old || 0) + 1;
            }
          }
        }
      }

      // gpa checks
      if (typeof kehamilanData.gpa === "string") {
        const matchGravida = kehamilanData.gpa.match(/G(\d+)/i);
        if (matchGravida) {
          const gravida = Number(matchGravida[1]);
          if (!isNaN(gravida) && gravida >= 4) {
            try {
              safeIncrement(byMonth[currentMonth].resti, "paritas_tinggi");
            } catch {
              byMonth[currentMonth].resti.paritas_tinggi =
                Number(byMonth[currentMonth].resti.paritas_tinggi || 0) + 1;
            }
          }
        }

        const matchAbortus = kehamilanData.gpa.match(/A(\d+)/i);
        if (matchAbortus) {
          const abortus = Number(matchAbortus[1]);
          if (!isNaN(abortus) && abortus > 0) {
            try {
              safeIncrement(byMonth[currentMonth].resti, "pernah_abortus");
            } catch {
              byMonth[currentMonth].resti.pernah_abortus =
                Number(byMonth[currentMonth].resti.pernah_abortus || 0) + 1;
            }
          }
        }
      }

      // tb under 145
      if (kehamilanData.tb !== undefined) {
        const tb = Number(kehamilanData.tb);
        if (!isNaN(tb) && tb < 145) {
          try {
            safeIncrement(byMonth[currentMonth].resti, "tb_under_145");
          } catch {
            byMonth[currentMonth].resti.tb_under_145 =
              Number(byMonth[currentMonth].resti.tb_under_145 || 0) + 1;
          }
        }
      }

      // --- LOGIC BATAS 13 BULAN ---
      const months = Object.keys(byMonth).sort(); // YYYY-MM asc
      if (months.length > 13) {
        const oldestMonth = months[0];
        delete byMonth[oldestMonth];
        console.log(
          `Month limit exceeded. Deleted oldest month: ${oldestMonth} for bidan: ${idBidan}`
        );
      }

      // --- pastikan kehamilan.all_bumil_count valid number sebelum increment ---
      if (
        kehamilan.all_bumil_count === undefined ||
        kehamilan.all_bumil_count === null ||
        isNaN(kehamilan.all_bumil_count)
      ) {
        kehamilan.all_bumil_count = 0;
      }
      kehamilan.all_bumil_count = Number(kehamilan.all_bumil_count) + 1;

      // --- tulis kembali ke Firestore (tidak ada undefined di object) ---
      const payload = {
        ...data,
        kehamilan: { all_bumil_count: kehamilan.all_bumil_count },
        last_updated_month: currentMonth,
        by_month: byMonth,
      };

      // Double safety: remove any undefined values recursively (very defensive)
      const removeUndefined = (obj) => {
        if (obj && typeof obj === "object") {
          Object.keys(obj).forEach((k) => {
            if (obj[k] === undefined) delete obj[k];
            else removeUndefined(obj[k]);
          });
        }
      };
      removeUndefined(payload);

      t.set(statsRef, payload, { merge: true });

      console.log(
        `Incremented kehamilan count for month: ${currentMonth}, bidan: ${idBidan}, status_resti: ${
          kehamilanData.status_resti || "-"
        }, anemia: ${
          kehamilanData.hemoglobin !== undefined &&
          Number(kehamilanData.hemoglobin) < 11
            ? "yes"
            : "no"
        }, paritas_tinggi: ${
          typeof kehamilanData.gpa === "string" &&
          /G(\d+)/i.test(kehamilanData.gpa) &&
          Number(kehamilanData.gpa.match(/G(\d+)/i)[1]) >= 4
            ? "yes"
            : "no"
        }`
      );
    });
  }
);
