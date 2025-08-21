import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebidan/data/models/riwayat_model.dart';

class Bumil {
  final String idBumil;
  final String idBidan;

  final String namaIbu;
  final String namaSuami;
  final String noHp;

  final String nikIbu;
  final String nikSuami;
  final String kkIbu;
  final String kkSuami;

  final String alamat;
  final String kabupaten;
  final String kecamatan;

  final String agamaIbu;
  final String agamaSuami;
  final String bloodIbu;
  final String bloodSuami;

  final DateTime? birthdateIbu;
  final DateTime? birthdateSuami;

  final String jobIbu;
  final String jobSuami;

  final String pendidikanIbu;
  final String pendidikanSuami;

  final DateTime? createdAt;

  final List<Riwayat>? riwayat; // key = tahun

  Bumil({
    required this.idBumil,
    required this.idBidan,
    required this.namaIbu,
    required this.namaSuami,
    required this.noHp,
    required this.nikIbu,
    required this.nikSuami,
    required this.kkIbu,
    required this.kkSuami,
    required this.alamat,
    required this.kabupaten,
    required this.kecamatan,
    required this.agamaIbu,
    required this.agamaSuami,
    required this.bloodIbu,
    required this.bloodSuami,
    required this.birthdateIbu,
    required this.birthdateSuami,
    required this.jobIbu,
    required this.jobSuami,
    required this.pendidikanIbu,
    required this.pendidikanSuami,
    required this.createdAt,
    this.riwayat,
  });

  factory Bumil.fromMap(String idBumil, Map<String, dynamic> map) {
    List<Riwayat>? riwayat;
    if (map['riwayat'] != null) {
      riwayat = (map['riwayat'] as Map<String, dynamic>).entries
          .map(
            (e) => Riwayat.fromMap(e.key, Map<String, dynamic>.from(e.value)),
          )
          .toList();
    }

    return Bumil(
      idBumil: idBumil,
      idBidan: map['id_bidan'] ?? '',
      namaIbu: map['nama_ibu'] ?? '',
      namaSuami: map['nama_suami'] ?? '',
      noHp: map['no_hp'] ?? '',
      nikIbu: map['nik_ibu'] ?? '',
      nikSuami: map['nik_suami'] ?? '',
      kkIbu: map['kk_ibu'] ?? '',
      kkSuami: map['kk_suami'] ?? '',
      alamat: map['alamat'] ?? '',
      kabupaten: map['kabupaten'] ?? '',
      kecamatan: map['kecamatan'] ?? '',
      agamaIbu: map['agama_ibu'] ?? '',
      agamaSuami: map['agama_suami'] ?? '',
      bloodIbu: map['blood_ibu'] ?? '',
      bloodSuami: map['blood_suami'] ?? '',
      birthdateIbu: map['birthdate_ibu'] != null
          ? (map['birthdate_ibu'] as Timestamp).toDate()
          : null,
      birthdateSuami: map['birthdate_suami'] != null
          ? (map['birthdate_suami'] as Timestamp).toDate()
          : null,
      jobIbu: map['job_ibu'] ?? '',
      jobSuami: map['job_suami'] ?? '',
      pendidikanIbu: map['pendidikan_ibu'] ?? '',
      pendidikanSuami: map['pendidikan_suami'] ?? '',
      createdAt: map['created_at'] != null
          ? (map['created_at'] as Timestamp).toDate()
          : null,
      riwayat: riwayat,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_bidan': idBidan,
      'nama_ibu': namaIbu,
      'nama_suami': namaSuami,
      'no_hp': noHp,
      'nik_ibu': nikIbu,
      'nik_suami': nikSuami,
      'kk_ibu': kkIbu,
      'kk_suami': kkSuami,
      'alamat': alamat,
      'agama_ibu': agamaIbu,
      'agama_suami': agamaSuami,
      'blood_ibu': bloodIbu,
      'blood_suami': bloodSuami,
      'birthdate_ibu': birthdateIbu,
      'birthdate_suami': birthdateSuami,
      'job_ibu': jobIbu,
      'job_suami': jobSuami,
      'pendidikan_ibu': pendidikanIbu,
      'pendidikan_suami': pendidikanSuami,
      'created_at': createdAt,
      'riwayat': riwayat?.map((r) => r.toMap()).toList(),
    };
  }

  Riwayat? get latestRiwayat {
    if (riwayat == null || riwayat!.isEmpty) return null;

    riwayat!.sort((a, b) => b.tahun.compareTo(a.tahun));
    return riwayat!.first;
  }

  int? get latestHistoryYear => latestRiwayat?.tahun;

  int get age {
    return (DateTime.now().year - (birthdateIbu?.year ?? 0));
  }
}
