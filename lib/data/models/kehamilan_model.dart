import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebidan/data/models/kunjungan_model.dart';
import 'package:ebidan/data/models/persalinan_model.dart';

class Kehamilan {
  final String id;
  final String? bpjs;
  final DateTime? createdAt;
  final String? gpa;
  final String? hasilLab;
  final String? hemoglobin;
  final DateTime? hpht;
  final DateTime? htp;
  final String? idBidan;
  final String? idBumil;
  final String? kontrasepsiSebelumHamil;
  final String? noKohortIbu;
  final String? noRekaMedis;
  final List<String>? resti;
  final String? riwayatAlergi;
  final String? riwayatPenyakit;
  final String? statusIbu;
  final String? statusTt;
  final String? tb;
  final DateTime? tglPeriksaUsg;
  final String? statusPersalinan; // sudah | belum
  final List<Kunjungan>? kunjungan;
  final Persalinan? persalinan;

  Kehamilan({
    required this.id,
    this.bpjs,
    this.createdAt,
    this.gpa,
    this.hasilLab,
    this.hemoglobin,
    this.hpht,
    this.htp,
    this.idBidan,
    this.idBumil,
    this.kontrasepsiSebelumHamil,
    this.noKohortIbu,
    this.noRekaMedis,
    this.resti,
    this.riwayatAlergi,
    this.riwayatPenyakit,
    this.statusIbu,
    this.statusTt,
    this.tb,
    this.tglPeriksaUsg,
    this.statusPersalinan,
    this.kunjungan,
    this.persalinan,
  });

  factory Kehamilan.fromFirestore(
    String id,
    Map<String, dynamic> json,
    List<Kunjungan> kunjungan,
  ) {
    return Kehamilan(
      id: id,
      bpjs: json['bpjs'],
      createdAt: (json['created_at'] as Timestamp?)?.toDate(),
      gpa: json['gpa'],
      hasilLab: json['hasil_lab'],
      hemoglobin: json['hemoglobin'],
      hpht: (json['hpht'] as Timestamp?)?.toDate(),
      htp: (json['htp'] as Timestamp?)?.toDate(),
      idBidan: json['id_bidan'],
      idBumil: json['id_bumil'],
      kontrasepsiSebelumHamil: json['kontrasepsi_sebelum_hamil'],
      noKohortIbu: json['no_kohort_ibu'],
      noRekaMedis: json['no_reka_medis'],
      resti: (json['resti'] as List?)?.map((e) => e.toString()).toList(),
      riwayatAlergi: json['riwayat_alergi'],
      riwayatPenyakit: json['riwayat_penyakit'],
      statusIbu: json['status_ibu'],
      statusTt: json['status_tt'],
      tb: json['tb'],
      tglPeriksaUsg: (json['tgl_periksa_usg'] as Timestamp?)?.toDate(),
      statusPersalinan: json['status_persalinan'],
      kunjungan: kunjungan,
      persalinan: Persalinan.fromMap(json['persalinan']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bpjs': bpjs,
      'created_at': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'gpa': gpa,
      'hasil_lab': hasilLab,
      'hemoglobin': hemoglobin,
      'hpht': hpht != null ? Timestamp.fromDate(hpht!) : null,
      'htp': htp != null ? Timestamp.fromDate(htp!) : null,
      'id_bidan': idBidan,
      'id_bumil': idBumil,
      'kontrasepsi_sebelum_hamil': kontrasepsiSebelumHamil,
      'no_kohort_ibu': noKohortIbu,
      'no_reka_medis': noRekaMedis,
      'resti': resti,
      'riwayat_alergi': riwayatAlergi,
      'riwayat_penyakit': riwayatPenyakit,
      'status_ibu': statusIbu,
      'status_tt': statusTt,
      'tb': tb,
      'tgl_periksa_usg': tglPeriksaUsg != null
          ? Timestamp.fromDate(tglPeriksaUsg!)
          : null,
      'status_persalinan': statusPersalinan,
      'persalinan': persalinan?.toMap(),
      // ⚠️ kunjungan tidak disimpan langsung karena biasanya koleksi terpisah
    }..removeWhere((key, value) => value == null);
  }
}
