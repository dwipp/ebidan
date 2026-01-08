import 'package:ebidan/common/Utils.dart';
import 'package:ebidan/data/models/kehamilan_model.dart';
import 'package:ebidan/data/models/kunjungan_model.dart';
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
  List<Riwayat>? riwayat;

  bool isHamil;
  String? latestKehamilanId;
  DateTime? latestKehamilanHpht;
  List<String>? latestKehamilanResti;
  bool latestKehamilanPersalinan;
  bool latestKehamilanKunjungan;
  Kehamilan? latestKehamilan;
  String? latestKunjunganId;
  Kunjungan? latestKunjungan;

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
    this.isHamil = false,
    this.latestKehamilanHpht,
    this.latestKehamilanId,
    this.latestKehamilanResti,
    this.latestKehamilanKunjungan = false,
    this.latestKehamilanPersalinan = false,
    this.latestKehamilan,
    this.latestKunjunganId,
    this.latestKunjungan,
  });

  /// ====== Factory from Firestore ======
  factory Bumil.fromMap(String idBumil, Map<String, dynamic> map) {
    List<Riwayat>? riwayat;
    if (map['riwayat'] != null) {
      riwayat = (map['riwayat'] as List)
          .map((e) => Riwayat.fromMap(Map<String, dynamic>.from(e)))
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
      agamaIbu: map['agama_ibu'] ?? '',
      agamaSuami: map['agama_suami'] ?? '',
      bloodIbu: map['blood_ibu'] ?? '',
      bloodSuami: map['blood_suami'] ?? '',
      birthdateIbu: Utils.toDateTime(map['birthdate_ibu']),
      birthdateSuami: Utils.toDateTime(map['birthdate_suami']),
      jobIbu: map['job_ibu'] ?? '',
      jobSuami: map['job_suami'] ?? '',
      pendidikanIbu: map['pendidikan_ibu'] ?? '',
      pendidikanSuami: map['pendidikan_suami'] ?? '',
      createdAt: Utils.toDateTime(map['created_at']),
      riwayat: riwayat,
      isHamil: map['is_hamil'] ?? false,
      latestKehamilanId: map['latest_kehamilan_id'],
      latestKehamilanHpht: Utils.toDateTime(map['latest_kehamilan_hpht']),
      latestKehamilanKunjungan: map['latest_kehamilan_kunjungan'] ?? false,
      latestKehamilanPersalinan: map['latest_kehamilan_persalinan'] ?? false,
      latestKehamilanResti: map['latest_kehamilan_resti'] != null
          ? List<String>.from(map['latest_kehamilan_resti'])
          : null,
      latestKehamilan: map['latest_kehamilan'] != null
          ? Kehamilan.fromFirestore(
              map['latest_kehamilan_id'] ?? '',
              Map<String, dynamic>.from(map['latest_kehamilan']),
            )
          : null,
      latestKunjunganId: map['latest_kunjungan_id'],
      latestKunjungan: map['latest_kunjungan'] != null
          ? Kunjungan.fromFirestore(
              Map<String, dynamic>.from(map['latest_kunjungan']),
              id: map['latest_kunjungan_id'] ?? '',
            )
          : null,
    );
  }

  /// Convert ke Firestore
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
      'birthdate_ibu': birthdateIbu?.toIso8601String(),
      'birthdate_suami': birthdateSuami?.toIso8601String(),
      'job_ibu': jobIbu,
      'job_suami': jobSuami,
      'pendidikan_ibu': pendidikanIbu,
      'pendidikan_suami': pendidikanSuami,
      'created_at': createdAt?.toIso8601String(),
      'riwayat': riwayat?.map((r) => r.toMap()).toList(),
      'is_hamil': isHamil,
      'latest_kehamilan_id': latestKehamilanId,
      'latest_kehamilan_hpht': latestKehamilanHpht?.toIso8601String(),
      'latest_kehamilan_kunjungan': latestKehamilanKunjungan,
      'latest_kehamilan_persalinan': latestKehamilanPersalinan,
      'latest_kehamilan_resti': latestKehamilanResti,
      'latest_kehamilan': latestKehamilan?.toMap(),
      'latest_kunjungan_id': latestKunjunganId,
      'latest_kunjungan': latestKunjungan?.toMap(),
    }..removeWhere((key, value) => value == null);
  }

  /// Untuk HydratedBloc
  factory Bumil.fromJson(Map<String, dynamic> json) {
    return Bumil(
      idBumil: json['id_bumil'],
      idBidan: json['id_bidan'],
      namaIbu: json['nama_ibu'],
      namaSuami: json['nama_suami'],
      noHp: json['no_hp'],
      nikIbu: json['nik_ibu'],
      nikSuami: json['nik_suami'],
      kkIbu: json['kk_ibu'],
      kkSuami: json['kk_suami'],
      alamat: json['alamat'],
      agamaIbu: json['agama_ibu'],
      agamaSuami: json['agama_suami'],
      bloodIbu: json['blood_ibu'],
      bloodSuami: json['blood_suami'],
      birthdateIbu: json['birthdate_ibu'] != null
          ? DateTime.parse(json['birthdate_ibu'])
          : null,
      birthdateSuami: json['birthdate_suami'] != null
          ? DateTime.parse(json['birthdate_suami'])
          : null,
      jobIbu: json['job_ibu'],
      jobSuami: json['job_suami'],
      pendidikanIbu: json['pendidikan_ibu'],
      pendidikanSuami: json['pendidikan_suami'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      riwayat: json['riwayat'] != null
          ? (json['riwayat'] as List)
                .map((e) => Riwayat.fromMap(Map<String, dynamic>.from(e)))
                .toList()
          : null,
      isHamil: json['is_hamil'] ?? false,
      latestKehamilanId: json['latest_kehamilan_id'],
      latestKehamilanHpht: json['latest_kehamilan_hpht'] != null
          ? DateTime.parse(json['latest_kehamilan_hpht'])
          : null,
      latestKehamilanKunjungan: json['latest_kehamilan_kunjungan'] ?? false,
      latestKehamilanPersalinan: json['latest_kehamilan_persalinan'] ?? false,
      latestKehamilanResti: json['latest_kehamilan_resti'] != null
          ? List<String>.from(json['latest_kehamilan_resti'])
          : null,
      latestKehamilan: json['latest_kehamilan'] != null
          ? Kehamilan.fromJson(
              Map<String, dynamic>.from(json['latest_kehamilan']),
            )
          : null,
      latestKunjunganId: json['latest_kunjungan_id'],
      latestKunjungan: json['latest_kunjungan'] != null
          ? Kunjungan.fromMap(
              json['latest_kunjungan_id'],
              Map<String, dynamic>.from(json['latest_kunjungan']),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_bumil': idBumil,
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
      'birthdate_ibu': birthdateIbu?.toIso8601String(),
      'birthdate_suami': birthdateSuami?.toIso8601String(),
      'job_ibu': jobIbu,
      'job_suami': jobSuami,
      'pendidikan_ibu': pendidikanIbu,
      'pendidikan_suami': pendidikanSuami,
      'created_at': createdAt?.toIso8601String(),
      'riwayat': riwayat?.map((r) => r.toMap()).toList(),
      'is_hamil': isHamil,
      'latest_kehamilan_id': latestKehamilanId,
      'latest_kehamilan_hpht': latestKehamilanHpht?.toIso8601String(),
      'latest_kehamilan_kunjungan': latestKehamilanKunjungan,
      'latest_kehamilan_persalinan': latestKehamilanPersalinan,
      'latest_kehamilan_resti': latestKehamilanResti,
      'latest_kehamilan': latestKehamilan?.toJson(),
      'latest_kunjungan_id': latestKunjunganId,
      'latest_kunjungan': latestKunjungan?.toMap(),
    };
  }

  /// ====== Getter Utility ======
  Riwayat? get latestRiwayat {
    if (riwayat == null || riwayat!.isEmpty) return null;
    riwayat!.sort((a, b) => b.tglLahir.compareTo(a.tglLahir));
    return riwayat!.first;
  }

  int? get latestHistoryYear => latestRiwayat?.tglLahir.year;

  int get age => (DateTime.now().year - (birthdateIbu?.year ?? 0));

  Map<String, int> get statisticRiwayat {
    int para = 0;
    int abortus = 0;
    int beratRendah = 0;

    if (riwayat != null) {
      for (final r in riwayat!) {
        if (r.statusBayi.toLowerCase() == 'hidup' ||
            r.statusBayi.toLowerCase() == 'mati') {
          para++;
        } else if (r.statusBayi.toLowerCase() == 'abortus') {
          abortus++;
        }

        if (r.beratBayi > 0 && r.beratBayi < 2500) beratRendah++;
      }
    }
    return {
      'para': para,
      'abortus': abortus,
      'gravida': para + abortus,
      'beratRendah': beratRendah,
    };
  }
}
