import 'package:cloud_firestore/cloud_firestore.dart';

class Persalinan {
  final String? beratLahir;
  final String? cara;
  final DateTime? createdAt;
  final String? lingkarKepala;
  final String? panjangBadan;
  final String? penolong;
  final String? sex;
  final String? tempat;
  final DateTime? tglPersalinan;
  final String? umurKehamilan;

  Persalinan({
    this.beratLahir,
    this.cara,
    this.createdAt,
    this.lingkarKepala,
    this.panjangBadan,
    this.penolong,
    this.sex,
    this.tempat,
    this.tglPersalinan,
    this.umurKehamilan,
  });

  factory Persalinan.fromMap(Map<String, dynamic>? json) {
    if (json == null) return Persalinan();
    return Persalinan(
      beratLahir: json['berat_lahir'],
      cara: json['cara'],
      createdAt: (json['created_at'] as Timestamp?)?.toDate(),
      lingkarKepala: json['lingkar_kepala'],
      panjangBadan: json['panjang_badan'],
      penolong: json['penolong'],
      sex: json['sex'],
      tempat: json['tempat'],
      tglPersalinan: (json['tgl_persalinan'] as Timestamp?)?.toDate(),
      umurKehamilan: json['umur_kehamilan']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'berat_lahir': beratLahir,
      'cara': cara,
      'created_at': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'lingkar_kepala': lingkarKepala,
      'panjang_badan': panjangBadan,
      'penolong': penolong,
      'sex': sex,
      'tempat': tempat,
      'tgl_persalinan': tglPersalinan != null
          ? Timestamp.fromDate(tglPersalinan!)
          : null,
      'umur_kehamilan': umurKehamilan,
    }..removeWhere((key, value) => value == null);
  }
}
