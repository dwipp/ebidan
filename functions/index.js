// index.js
import { incrementPasienCount } from "./modules/pasien/increment_pasien.js";
import { decrementPasienCount } from "./modules/pasien/decrement_pasien.js";
import { recalculateBumilStats } from "./modules/bumil/recalculate_bumil.js";
import { recalculateKunjunganStats } from "./modules/kunjungan/recalculate_kunjungan.js";
import { decrementKunjunganCount } from "./modules/kunjungan/decrement_kunjungan.js";
import { incrementKunjunganCount } from "./modules/kunjungan/increment_kunjungan.js";
import { decrementKehamilanCount } from "./modules/kehamilan/decrement_kehamilan.js";
import { incrementKehamilanCount } from "./modules/kehamilan/increment_kehamilan.js";

export { 
    incrementPasienCount, 
    decrementPasienCount, 
    recalculateBumilStats, 
    recalculateKunjunganStats, 
    decrementKunjunganCount, 
    incrementKunjunganCount, 
    decrementKehamilanCount,
    incrementKehamilanCount
};
