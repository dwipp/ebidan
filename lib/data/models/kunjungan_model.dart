import 'package:cloud_firestore/cloud_firestore.dart';

class Kunjungan {
  final String id;
  final num? bb;
  final num? tb;
  final DateTime? createdAt;
  final String? keluhan;
  final String? lila;
  final String? lp;
  final String? planning;
  final String? status;
  final String? td;
  final String? tfu;
  final String? uk;
  final String? terapi;
  final String? idKehamilan;
  final String? idBidan;
  final String? idBumil;
  final bool? periksaUsg;

  Kunjungan({
    required this.id,
    this.bb,
    this.tb,
    this.createdAt,
    this.keluhan,
    this.lila,
    this.lp,
    this.planning,
    this.status,
    this.td,
    this.tfu,
    this.uk,
    this.terapi,
    this.idBidan,
    this.idBumil,
    this.idKehamilan,
    this.periksaUsg,
  });

  /// ✅ Dari Firestore (pakai Timestamp)
  factory Kunjungan.fromFirestore(
    Map<String, dynamic> json, {
    required String id,
  }) {
    return Kunjungan(
      id: id,
      bb: json['bb'],
      tb: json['tb'],
      createdAt: (json['created_at'] as Timestamp?)?.toDate(),
      keluhan: json['keluhan'],
      lila: json['lila'],
      lp: json['lp'],
      planning: json['planning'],
      status: json['status'],
      td: json['td'],
      tfu: json['tfu'],
      uk: json['uk'],
      terapi: json['terapi'],
      idBidan: json['id_bidan'],
      idBumil: json['id_bumil'],
      idKehamilan: json['id_kehamilan'],
      periksaUsg: json['periksa_usg'],
    );
  }

  /// ✅ Dari Map/JSON biasa (pakai string date)
  factory Kunjungan.fromMap(String id, Map<String, dynamic> map) {
    return Kunjungan(
      id: id,
      bb: map['bb'],
      tb: map['tb'],
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
      keluhan: map['keluhan'],
      lila: map['lila'],
      lp: map['lp'],
      planning: map['planning'],
      status: map['status'],
      td: map['td'],
      tfu: map['tfu'],
      uk: map['uk'],
      terapi: map['terapi'],
      idBidan: map['id_bidan'],
      idBumil: map['id_bumil'],
      idKehamilan: map['id_kehamilan'],
      periksaUsg: map['periksa_usg'],
    );
  }

  /// ✅ Untuk simpan ke Firestore/JSON
  Map<String, dynamic> toMap() {
    return {
      'bb': bb,
      'tb': tb,
      'created_at': createdAt?.toIso8601String(),
      'keluhan': keluhan,
      'lila': lila,
      'lp': lp,
      'planning': planning,
      'status': status,
      'td': td,
      'tfu': tfu,
      'uk': uk,
      'terapi': terapi,
      'id_bidan': idBidan,
      'id_bumil': idBumil,
      'id_kehamilan': idKehamilan,
      'periksa_usg': periksaUsg,
    }..removeWhere((key, value) => value == null);
  }
}
