// index.js
import admin from "firebase-admin";
import { incrementBumilCount } from "./modules/incrementBumil.js";
import { decrementBumilCount } from "./modules/decrementBumil.js";
import { recalculateBumilStats } from "./modules/recalculateBumil.js";

if (!admin.apps.length) {
  admin.initializeApp();
}

export { incrementBumilCount, decrementBumilCount, recalculateBumilStats };
