import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Persalinan {
  String id;
  String? beratLahir;
  String? cara;
  String? lingkarKepala;
  String? panjangBadan;
  String? penolong;
  String? sex;
  String? statusBayi;
  String? statusIbu;
  String? tempat;
  String? umurKehamilan;
  DateTime? tglPersalinan;
  DateTime? createdAt;
  final TextEditingController umurKehamilanController = TextEditingController();

  Persalinan({
    required this.id,
    this.beratLahir,
    this.cara,
    this.lingkarKepala,
    this.panjangBadan,
    this.penolong,
    this.sex,
    this.statusBayi,
    this.statusIbu,
    this.tempat,
    this.umurKehamilan,
    this.tglPersalinan,
    this.createdAt,
  }) {
    if (umurKehamilan != null) {
      umurKehamilanController.text = umurKehamilan!;
    }
  }

  /// constructor kosong untuk form
  factory Persalinan.empty() {
    return Persalinan(createdAt: DateTime.now(), id: Uuid().v4());
  }

  /// convert ke map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      "berat_lahir": beratLahir,
      "cara": cara,
      "lingkar_kepala": lingkarKepala,
      "panjang_badan": panjangBadan,
      "penolong": penolong,
      "sex": sex,
      "status_bayi": statusBayi,
      "status_ibu": statusIbu,
      "tempat": tempat,
      "umur_kehamilan": umurKehamilanController.text,
      "tgl_persalinan": tglPersalinan?.toIso8601String(),
      "created_at": createdAt?.toIso8601String(),
    };
  }

  /// convert ke firestore
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      "berat_lahir": beratLahir,
      "cara": cara,
      "lingkar_kepala": lingkarKepala,
      "panjang_badan": panjangBadan,
      "penolong": penolong,
      "sex": sex,
      "status_bayi": statusBayi,
      "status_ibu": statusIbu,
      "tempat": tempat,
      "umur_kehamilan": umurKehamilanController.text,
      "tgl_persalinan": tglPersalinan,
      "created_at": createdAt,
    };
  }

  /// convert dari firestore ke model
  factory Persalinan.fromMap(Map<String, dynamic> map) {
    return Persalinan(
      id: map['id'],
      beratLahir: map['berat_lahir']?.toString(),
      cara: map['cara'],
      lingkarKepala: map['lingkar_kepala']?.toString(),
      panjangBadan: map['panjang_badan']?.toString(),
      penolong: map['penolong'],
      sex: map['sex'],
      statusBayi: map['status_bayi'],
      statusIbu: map['status_ibu'],
      tempat: map['tempat'],
      umurKehamilan: map['umur_kehamilan']?.toString(),
      tglPersalinan: map['tgl_persalinan'] is DateTime
          ? map['tgl_persalinan']
          : (map['tgl_persalinan']?.toDate()),
      createdAt: map['created_at'] is DateTime
          ? map['created_at']
          : (map['created_at']?.toDate()),
    );
  }
}
