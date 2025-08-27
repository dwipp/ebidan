import 'package:cloud_firestore/cloud_firestore.dart';

class Kunjungan {
  final String? bb;
  final DateTime? createdAt;
  final String? keluhan;
  final String? lila;
  final String? lp;
  final String? planning;
  final String? status;
  final String? td;
  final String? tfu;
  final String? uk;
  final String? idKehamilan;
  final String? idBidan;
  final String? idBumil;

  Kunjungan({
    this.bb,
    this.createdAt,
    this.keluhan,
    this.lila,
    this.lp,
    this.planning,
    this.status,
    this.td,
    this.tfu,
    this.uk,
    this.idBidan,
    this.idBumil,
    this.idKehamilan,
  });

  /// ✅ Dari Firestore (pakai Timestamp)
  factory Kunjungan.fromFirestore(Map<String, dynamic> json) {
    return Kunjungan(
      bb: json['bb'],
      createdAt: (json['created_at'] as Timestamp?)?.toDate(),
      keluhan: json['keluhan'],
      lila: json['lila'],
      lp: json['lp'],
      planning: json['planning'],
      status: json['status'],
      td: json['td'],
      tfu: json['tfu'],
      uk: json['uk'],
      idBidan: json['id_bidan'],
      idBumil: json['id_bumil'],
      idKehamilan: json['id_kehamilan'],
    );
  }

  /// ✅ Dari Map/JSON biasa (pakai string date)
  factory Kunjungan.fromMap(Map<String, dynamic> map) {
    return Kunjungan(
      bb: map['bb'],
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
      idBidan: map['id_bidan'],
      idBumil: map['id_bumil'],
      idKehamilan: map['id_kehamilan'],
    );
  }

  /// ✅ Untuk simpan ke Firestore/JSON
  Map<String, dynamic> toMap() {
    return {
      'bb': bb,
      'created_at': createdAt?.toIso8601String(),
      'keluhan': keluhan,
      'lila': lila,
      'lp': lp,
      'planning': planning,
      'status': status,
      'td': td,
      'tfu': tfu,
      'uk': uk,
      'id_bidan': idBidan,
      'id_bumil': idBumil,
      'id_kehamilan': idKehamilan,
    }..removeWhere((key, value) => value == null);
  }
}
