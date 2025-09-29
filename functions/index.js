// index.js
import { incrementPasienCount } from "./modules/pasien/increment_pasien.js";
import { decrementPasienCount } from "./modules/pasien/decrement_pasien.js";
import { recalculateBumilStats } from "./modules/bumil/recalculate_bumil.js";
import { recalculateKunjunganStats } from "./modules/kunjungan/recalculate_kunjungan.js";
import { decrementKunjunganCount } from "./modules/kunjungan/decrement_kunjungan.js";
import { incrementKunjunganCount } from "./modules/kunjungan/increment_kunjungan.js";
import { decrementKehamilanCount } from "./modules/kehamilan/decrement_kehamilan.js";
import { incrementKehamilanCount } from "./modules/kehamilan/increment_kehamilan.js";
import { updateKehamilanStats } from "./modules/kehamilan/update_kehamilan.js";
import { recalculateKehamilanStats } from "./modules/kehamilan/recalculate_kehamilan.js";
import { decrementPersalinanCount } from "./modules/persalinan/decrement_persalinan.js";
import { incrementPersalinanCount } from "./modules/persalinan/increment_persalinan.js";
import { recalculatePersalinanStats } from "./modules/persalinan/recalculate_persalinan.js";

export { 
    incrementPasienCount, 
    decrementPasienCount, 
    recalculateBumilStats, 
    recalculateKunjunganStats, 
    decrementKunjunganCount, 
    incrementKunjunganCount, 
    decrementKehamilanCount,
    incrementKehamilanCount,
    updateKehamilanStats,
    incrementPersalinanCount,
    recalculatePersalinanStats,
    decrementPersalinanCount,
    recalculateKehamilanStats
};
