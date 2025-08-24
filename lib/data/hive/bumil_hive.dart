import 'package:ebidan/data/models/bumil_model.dart';
import 'package:hive/hive.dart';

part 'bumil_hive.g.dart';

@HiveType(typeId: 0)
class BumilHive {
  @HiveField(0)
  final String namaIbu;
  @HiveField(1)
  final String namaSuami;
  @HiveField(2)
  final String alamat;
  @HiveField(3)
  final String noHp;
  @HiveField(4)
  final String agamaIbu;
  @HiveField(5)
  final String agamaSuami;
  @HiveField(6)
  final String bloodIbu;
  @HiveField(7)
  final String bloodSuami;
  @HiveField(8)
  final String jobIbu;
  @HiveField(9)
  final String jobSuami;
  @HiveField(10)
  final String nikIbu;
  @HiveField(11)
  final String nikSuami;
  @HiveField(12)
  final String kkIbu;
  @HiveField(13)
  final String kkSuami;
  @HiveField(14)
  final String pendidikanIbu;
  @HiveField(15)
  final String pendidikanSuami;
  @HiveField(16)
  final DateTime? birthdateIbu;
  @HiveField(17)
  final DateTime? birthdateSuami;
  @HiveField(18)
  final String idBidan;
  @HiveField(19)
  final DateTime? createdAt;

  BumilHive({
    required this.namaIbu,
    required this.namaSuami,
    required this.alamat,
    required this.noHp,
    required this.agamaIbu,
    required this.agamaSuami,
    required this.bloodIbu,
    required this.bloodSuami,
    required this.jobIbu,
    required this.jobSuami,
    required this.nikIbu,
    required this.nikSuami,
    required this.kkIbu,
    required this.kkSuami,
    required this.pendidikanIbu,
    required this.pendidikanSuami,
    required this.birthdateIbu,
    required this.birthdateSuami,
    required this.idBidan,
    required this.createdAt,
  });

  static BumilHive fromModel(Bumil bumil) {
    return BumilHive(
      namaIbu: bumil.namaIbu,
      namaSuami: bumil.namaSuami,
      alamat: bumil.alamat,
      noHp: bumil.noHp,
      agamaIbu: bumil.agamaIbu,
      agamaSuami: bumil.agamaSuami,
      bloodIbu: bumil.bloodIbu,
      bloodSuami: bumil.bloodSuami,
      jobIbu: bumil.jobIbu,
      jobSuami: bumil.jobSuami,
      nikIbu: bumil.nikIbu,
      nikSuami: bumil.nikSuami,
      kkIbu: bumil.kkIbu,
      kkSuami: bumil.kkSuami,
      pendidikanIbu: bumil.pendidikanIbu,
      pendidikanSuami: bumil.pendidikanSuami,
      birthdateIbu: bumil.birthdateIbu,
      birthdateSuami: bumil.birthdateSuami,
      idBidan: bumil.idBidan,
      createdAt: bumil.createdAt,
    );
  }

  Bumil toModel({String idBumil = ''}) {
    return Bumil(
      namaIbu: namaIbu,
      namaSuami: namaSuami,
      alamat: alamat,
      noHp: noHp,
      agamaIbu: agamaIbu,
      agamaSuami: agamaSuami,
      bloodIbu: bloodIbu,
      bloodSuami: bloodSuami,
      jobIbu: jobIbu,
      jobSuami: jobSuami,
      nikIbu: nikIbu,
      nikSuami: nikSuami,
      kkIbu: kkIbu,
      kkSuami: kkSuami,
      pendidikanIbu: pendidikanIbu,
      pendidikanSuami: pendidikanSuami,
      birthdateIbu: birthdateIbu,
      birthdateSuami: birthdateSuami,
      idBidan: idBidan,
      createdAt: createdAt,
      idBumil: idBumil,
    );
  }
}
