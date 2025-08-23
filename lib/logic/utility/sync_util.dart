import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebidan/data/hive/bumil_hive.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';

class SyncUtil {
  static Future<void> syncAll() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final addBumil = await Hive.openBox<BumilHive>('offline_bumil');
    if (addBumil.isNotEmpty) {
      syncAddBumil(addBumil);
    }

    // final addRiwayat = await Hive.openBox<RiwayatHive>('offline_riwayat');
    // if (addRiwayat.isNotEmpty) {
    //   syncAddRiwayat(addRiwayat);
    // }
  }

  static Future<void> syncAddBumil(Box<BumilHive> box) async {
    final batch = FirebaseFirestore.instance.batch();

    for (var bumil in box.values) {
      final docRef = FirebaseFirestore.instance.collection('bumil').doc();
      batch.set(docRef, {
        "nama_ibu": bumil.namaIbu,
        "nama_suami": bumil.namaSuami,
        "alamat": bumil.alamat,
        "no_hp": bumil.noHp,
        "agama_ibu": bumil.agamaIbu,
        "agama_suami": bumil.agamaSuami,
        "blood_ibu": bumil.bloodIbu,
        "blood_suami": bumil.bloodSuami,
        "job_ibu": bumil.jobIbu,
        "job_suami": bumil.jobSuami,
        "nik_ibu": bumil.nikIbu,
        "nik_suami": bumil.nikSuami,
        "kk_ibu": bumil.kkIbu,
        "kk_suami": bumil.kkSuami,
        "pendidikan_ibu": bumil.pendidikanIbu,
        "pendidikan_suami": bumil.pendidikanSuami,
        "id_bidan": bumil.idBidan,
        "birthdate_ibu": bumil.birthdateIbu,
        "birthdate_suami": bumil.birthdateSuami,
        "created_at": bumil.createdAt,
      });
    }

    await batch.commit();
    await box.clear(); // hapus data offline setelah sukses
  }

  static Future<void> syncAddRiwayat() async {}
  static Future<void> syncAddKehamilan() async {}
  static Future<void> syncAddKunjungan() async {}
  static Future<void> syncAddPersalinan() async {}
}
