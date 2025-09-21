import 'package:cloud_firestore/cloud_firestore.dart';

class Riwayat {
  final String id;
  final DateTime tglLahir;
  final int beratBayi;
  final String komplikasi;
  final String panjangBayi;
  final String penolong;
  final String statusBayi;
  final String statusLahir;
  final String statusTerm;
  final String tempat;

  Riwayat({
    required this.id,
    required this.tglLahir,
    required this.beratBayi,
    required this.komplikasi,
    required this.panjangBayi,
    required this.penolong,
    required this.statusBayi,
    required this.statusLahir,
    required this.statusTerm,
    required this.tempat,
  });

  factory Riwayat.fromMap(Map<String, dynamic> map) {
    return Riwayat(
      id: map['id'] ?? '',
      tglLahir: (map['tgl_lahir'] as Timestamp?)!.toDate(),
      beratBayi: map['berat_bayi'] ?? 0,
      komplikasi: map['komplikasi'] ?? '',
      panjangBayi: map['panjang_bayi'] ?? '',
      penolong: map['penolong'] ?? '',
      statusBayi: map['status_bayi'] ?? '',
      statusLahir: map['status_lahir'] ?? '',
      statusTerm: map['status_term'] ?? '',
      tempat: map['tempat'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tgl_lahir': tglLahir.toIso8601String(),
      'berat_bayi': beratBayi,
      'komplikasi': komplikasi,
      'panjang_bayi': panjangBayi,
      'penolong': penolong,
      'status_bayi': statusBayi,
      'status_lahir': statusLahir,
      'status_term': statusTerm,
      'tempat': tempat,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'tgl_lahir': tglLahir,
      'berat_bayi': beratBayi,
      'komplikasi': komplikasi,
      'panjang_bayi': panjangBayi,
      'penolong': penolong,
      'status_bayi': statusBayi,
      'status_lahir': statusLahir,
      'status_term': statusTerm,
      'tempat': tempat,
    };
  }
}
