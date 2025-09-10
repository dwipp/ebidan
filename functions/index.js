// index.js
import { incrementBumilCount } from "./modules/bumil/increment_bumil.js";
import { decrementBumilCount } from "./modules/bumil/decrement_bumil.js";
import { recalculateBumilStats } from "./modules/bumil/recalculate_bumil.js";
import { recalculateKunjunganStats } from "./modules/kunjungan/recalculate_kunjungan.js";
import { decrementKunjunganCount } from "./modules/kunjungan/decrement_kunjungan.js";
import { incrementKunjunganCount } from "./modules/kunjungan/increment_kunjungan.js";
import { decrementKehamilanCount } from "./modules/kehamilan/decrement_kehamilan.js";
import { incrementKehamilanCount } from "./modules/kehamilan/increment_kehamilan.js";

export { 
    incrementBumilCount, 
    decrementBumilCount, 
    recalculateBumilStats, 
    recalculateKunjunganStats, 
    decrementKunjunganCount, 
    incrementKunjunganCount, 
    decrementKehamilanCount,
    incrementKehamilanCount
};
