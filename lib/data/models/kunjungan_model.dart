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
  });

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
    );
  }
}
