import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebidan/data/models/persalinan_model.dart';

class Kehamilan {
  final String? id;
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
  final String? statusResti;
  final String? statusTt;
  final String? tb;
  final DateTime? tglPeriksaUsg;
  final bool kontrolDokter;
  final bool kunjungan;
  List<Persalinan>? persalinan;

  Kehamilan({
    this.id,
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
    this.statusResti,
    this.statusTt,
    this.tb,
    this.tglPeriksaUsg,
    this.kontrolDokter = false,
    this.kunjungan = false,
    this.persalinan,
  });

  /// ✅ Dari Firestore (pakai Timestamp)
  factory Kehamilan.fromFirestore(String id, Map<String, dynamic> json) {
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
      statusResti: json['status_resti'],
      statusTt: json['status_tt'],
      tb: json['tb'],
      tglPeriksaUsg: (json['tgl_periksa_usg'] as Timestamp?)?.toDate(),
      kontrolDokter: json['kontrol_dokter'] ?? false,
      kunjungan: json['kunjungan'] ?? false,
      persalinan: (json['persalinan'] as List?)
          ?.map((e) => Persalinan.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// ✅ Dari JSON biasa (pakai string date)
  factory Kehamilan.fromJson(Map<String, dynamic> json) {
    return Kehamilan(
      id: json['id'],
      bpjs: json['bpjs'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      gpa: json['gpa'],
      hasilLab: json['hasil_lab'],
      hemoglobin: json['hemoglobin'],
      hpht: json['hpht'] != null ? DateTime.parse(json['hpht']) : null,
      htp: json['htp'] != null ? DateTime.parse(json['htp']) : null,
      idBidan: json['id_bidan'],
      idBumil: json['id_bumil'],
      kontrasepsiSebelumHamil: json['kontrasepsi_sebelum_hamil'],
      noKohortIbu: json['no_kohort_ibu'],
      noRekaMedis: json['no_reka_medis'],
      resti: (json['resti'] as List?)?.map((e) => e.toString()).toList(),
      riwayatAlergi: json['riwayat_alergi'],
      riwayatPenyakit: json['riwayat_penyakit'],
      statusResti: json['status_resti'],
      statusTt: json['status_tt'],
      tb: json['tb'],
      tglPeriksaUsg: json['tgl_periksa_usg'] != null
          ? DateTime.parse(json['tgl_periksa_usg'])
          : null,
      kontrolDokter: json['kontrol_dokter'] ?? false,
      kunjungan: json['kunjungan'] ?? false,
      persalinan: (json['persalinan'] as List?)
          ?.map((e) => Persalinan.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// ✅ Untuk Firestore
  Map<String, dynamic> toMap() {
    return {
      'bpjs': bpjs,
      'created_at': createdAt?.toIso8601String(),
      'gpa': gpa,
      'hasil_lab': hasilLab,
      'hemoglobin': hemoglobin,
      'hpht': hpht?.toIso8601String(),
      'htp': htp?.toIso8601String(),
      'id_bidan': idBidan,
      'id_bumil': idBumil,
      'kontrasepsi_sebelum_hamil': kontrasepsiSebelumHamil,
      'no_kohort_ibu': noKohortIbu,
      'no_reka_medis': noRekaMedis,
      'resti': resti,
      'riwayat_alergi': riwayatAlergi,
      'riwayat_penyakit': riwayatPenyakit,
      'status_resti': statusResti,
      'status_tt': statusTt,
      'tb': tb,
      'tgl_periksa_usg': tglPeriksaUsg?.toIso8601String(),
      'kontrol_dokter': kontrolDokter,
      'kunjungan': kunjungan,
      'persalinan': persalinan?.map((e) => e.toMap()).toList(),
    }..removeWhere((key, value) => value == null);
  }

  /// ✅ Untuk JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bpjs': bpjs,
      'created_at': createdAt?.toIso8601String(),
      'gpa': gpa,
      'hasil_lab': hasilLab,
      'hemoglobin': hemoglobin,
      'hpht': hpht?.toIso8601String(),
      'htp': htp?.toIso8601String(),
      'id_bidan': idBidan,
      'id_bumil': idBumil,
      'kontrasepsi_sebelum_hamil': kontrasepsiSebelumHamil,
      'no_kohort_ibu': noKohortIbu,
      'no_reka_medis': noRekaMedis,
      'resti': resti,
      'riwayat_alergi': riwayatAlergi,
      'riwayat_penyakit': riwayatPenyakit,
      'status_resti': statusResti,
      'status_tt': statusTt,
      'tb': tb,
      'tgl_periksa_usg': tglPeriksaUsg?.toIso8601String(),
      'kontrol_dokter': kontrolDokter,
      'kunjungan': kunjungan,
      'persalinan': persalinan?.map((e) => e.toMap()).toList(),
    }..removeWhere((key, value) => value == null);
  }

  Map<String, dynamic> toFirestore() {
    return {
      'bpjs': bpjs,
      'created_at': createdAt,
      'gpa': gpa,
      'hasil_lab': hasilLab,
      'hemoglobin': hemoglobin,
      'hpht': hpht,
      'htp': htp,
      'id_bidan': idBidan,
      'id_bumil': idBumil,
      'kontrasepsi_sebelum_hamil': kontrasepsiSebelumHamil,
      'no_kohort_ibu': noKohortIbu,
      'no_reka_medis': noRekaMedis,
      'resti': resti,
      'riwayat_alergi': riwayatAlergi,
      'riwayat_penyakit': riwayatPenyakit,
      'status_resti': statusResti,
      'status_tt': statusTt,
      'tb': tb,
      'tgl_periksa_usg': tglPeriksaUsg,
      'kontrol_dokter': kontrolDokter,
      'kunjungan': kunjungan,
      'persalinan': persalinan?.map((e) => e.toFirestore()).toList(),
    }..removeWhere((key, value) => value == null);
  }
}
