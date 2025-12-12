// ignore_for_file: public_member_api_docs, sort_constructors_first
class Statistic {
  final KehamilanStats kehamilan;
  final PasienStats pasien;
  final String lastUpdatedMonth;
  final Map<String, ByMonthStats> byMonth;

  Statistic({
    required this.kehamilan,
    required this.pasien,
    required this.lastUpdatedMonth,
    required this.byMonth,
  });

  factory Statistic.fromMap(Map<String, dynamic> map) {
    final byMonthData = <String, ByMonthStats>{};
    if (map['by_month'] != null) {
      (map['by_month'] as Map<String, dynamic>).forEach((key, value) {
        byMonthData[key] = ByMonthStats.fromMap(value);
      });
    }

    return Statistic(
      kehamilan: KehamilanStats.fromMap(map['kehamilan'] ?? {}),
      pasien: PasienStats.fromMap(map['pasien'] ?? {}),
      lastUpdatedMonth: map['last_updated_month'] ?? '',
      byMonth: byMonthData,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'kehamilan': kehamilan.toMap(),
      'pasien': pasien.toMap(),
      'last_updated_month': lastUpdatedMonth,
      'by_month': byMonth.map((key, value) => MapEntry(key, value.toMap())),
    };
  }

  /// ✅ Ambil data `ByMonthStats` sesuai `lastUpdatedMonth`
  ByMonthStats? get lastMonthData {
    return byMonth[lastUpdatedMonth];
  }

  Statistic copyWith({
    KehamilanStats? kehamilan,
    PasienStats? pasien,
    String? lastUpdatedMonth,
    Map<String, ByMonthStats>? byMonth,
  }) {
    return Statistic(
      kehamilan: kehamilan ?? this.kehamilan,
      pasien: pasien ?? this.pasien,
      lastUpdatedMonth: lastUpdatedMonth ?? this.lastUpdatedMonth,
      byMonth: byMonth ?? this.byMonth,
    );
  }
}

class KehamilanStats {
  final int allBumilCount;

  KehamilanStats({required this.allBumilCount});

  factory KehamilanStats.fromMap(Map<String, dynamic> map) {
    return KehamilanStats(allBumilCount: map['all_bumil_count'] ?? 0);
  }

  Map<String, dynamic> toMap() {
    return {'all_bumil_count': allBumilCount};
  }

  KehamilanStats copyWith({int? allBumilCount}) {
    return KehamilanStats(allBumilCount: allBumilCount ?? this.allBumilCount);
  }
}

class PasienStats {
  final int allPasienCount;

  PasienStats({required this.allPasienCount});

  factory PasienStats.fromMap(Map<String, dynamic> map) {
    return PasienStats(allPasienCount: map['all_pasien_count'] ?? 0);
  }

  Map<String, dynamic> toMap() {
    return {'all_pasien_count': allPasienCount};
  }

  PasienStats copyWith({int? allPasienCount}) {
    return PasienStats(allPasienCount: allPasienCount ?? this.allPasienCount);
  }
}

class ByMonthStats {
  final KehamilanByMonth kehamilan;
  final PasienByMonth pasien;
  final KunjunganByMonth kunjungan;
  final PersalinanByMonth persalinan;
  final RestiByMonth resti;
  final SfByMonth sf;

  ByMonthStats({
    required this.kehamilan,
    required this.pasien,
    required this.kunjungan,
    required this.persalinan,
    required this.resti,
    required this.sf,
  });

  factory ByMonthStats.fromMap(Map<String, dynamic> map) {
    return ByMonthStats(
      kehamilan: KehamilanByMonth.fromMap(map['kehamilan']),
      pasien: PasienByMonth.fromMap(map['pasien']),
      kunjungan: KunjunganByMonth.fromMap(map['kunjungan']),
      persalinan: PersalinanByMonth.fromMap(map['persalinan']),
      resti: RestiByMonth.fromMap(map['resti']),
      sf: SfByMonth.fromMap(map['sf']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'kehamilan': kehamilan.toMap(),
      'pasien': pasien.toMap(),
      'kunjungan': kunjungan.toMap(),
      'resti': resti.toMap(),
      'sf': sf.toMap(),
    };
  }

  ByMonthStats copyWith({
    KehamilanByMonth? kehamilan,
    PasienByMonth? pasien,
    KunjunganByMonth? kunjungan,
    PersalinanByMonth? persalinan,
    RestiByMonth? resti,
    SfByMonth? sf,
  }) {
    return ByMonthStats(
      kehamilan: kehamilan ?? this.kehamilan,
      pasien: pasien ?? this.pasien,
      kunjungan: kunjungan ?? this.kunjungan,
      persalinan: persalinan ?? this.persalinan,
      resti: resti ?? this.resti,
      sf: sf ?? this.sf,
    );
  }
}

class SfByMonth {
  final int sf30;
  final int sf60;
  final int sf90;
  final int sf120;
  final int sf150;
  final int sf180;
  final int sf210;
  final int sf240;
  final int sf270;

  SfByMonth({
    this.sf30 = 0,
    this.sf60 = 0,
    this.sf90 = 0,
    this.sf120 = 0,
    this.sf150 = 0,
    this.sf180 = 0,
    this.sf210 = 0,
    this.sf240 = 0,
    this.sf270 = 0,
  });

  factory SfByMonth.fromMap(Map<String, dynamic>? map) {
    if (map == null) return SfByMonth();
    return SfByMonth(
      sf30: map['30'] ?? 0,
      sf60: map['60'] ?? 0,
      sf90: map['90'] ?? 0,
      sf120: map['120'] ?? 0,
      sf150: map['150'] ?? 0,
      sf180: map['180'] ?? 0,
      sf210: map['210'] ?? 0,
      sf240: map['240'] ?? 0,
      sf270: map['270'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '30': sf30,
      '60': sf60,
      '90': sf90,
      '120': sf120,
      '150': sf150,
      '180': sf180,
      '210': sf210,
      '240': sf240,
      '270': sf270,
    };
  }
}

class RestiByMonth {
  final int anemia;
  final int bbBayiUnder2500;
  final int hipertensi;
  final int jarakHamil;
  final int kek;
  final int obesitas;
  final int paritasTinggi;
  final int pernahAbortus;
  final int restiMasyarakat;
  final int restiNakes;
  final int tbUnder145;
  final int tooOld;
  final int tooYoung;

  RestiByMonth({
    required this.anemia,
    required this.bbBayiUnder2500,
    required this.hipertensi,
    required this.jarakHamil,
    required this.kek,
    required this.obesitas,
    required this.paritasTinggi,
    required this.pernahAbortus,
    required this.restiMasyarakat,
    required this.restiNakes,
    required this.tbUnder145,
    required this.tooOld,
    required this.tooYoung,
  });

  // masih salah. total resti harus berasal dari jumlah pasien yang memiliki resiko tinggi
  int get totalResti {
    var total =
        anemia +
        bbBayiUnder2500 +
        hipertensi +
        jarakHamil +
        kek +
        obesitas +
        paritasTinggi +
        pernahAbortus +
        restiMasyarakat +
        restiNakes +
        tbUnder145 +
        tooOld +
        tooYoung;
    return total;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'anemia': anemia,
      'bb_bayi_under_2500': bbBayiUnder2500,
      'hipertensi': hipertensi,
      'jarak_hamil': jarakHamil,
      'kek': kek,
      'obesitas': obesitas,
      'paritas_tinggi': paritasTinggi,
      'pernah_abortus': pernahAbortus,
      'resti_masyarakat': restiMasyarakat,
      'resti_nakes': restiNakes,
      'tb_under_145': tbUnder145,
      'too_old': tooOld,
      'too_young': tooYoung,
    };
  }

  factory RestiByMonth.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return RestiByMonth(
        anemia: 0,
        bbBayiUnder2500: 0,
        hipertensi: 0,
        jarakHamil: 0,
        kek: 0,
        obesitas: 0,
        paritasTinggi: 0,
        pernahAbortus: 0,
        restiMasyarakat: 0,
        restiNakes: 0,
        tbUnder145: 0,
        tooOld: 0,
        tooYoung: 0,
      );
    }
    return RestiByMonth(
      anemia: map['anemia'] ?? 0,
      bbBayiUnder2500: map['bb_bayi_under_2500'] ?? 0,
      hipertensi: map['hipertensi'] ?? 0,
      jarakHamil: map['jarak_hamil'] ?? 0,
      kek: map['kek'] ?? 0,
      obesitas: map['obesitas'] ?? 0,
      paritasTinggi: map['paritas_tinggi'] ?? 0,
      pernahAbortus: map['pernah_abortus'] ?? 0,
      restiMasyarakat: map['resti_masyarakat'] ?? 0,
      restiNakes: map['resti_nakes'] ?? 0,
      tbUnder145: map['tb_under_145'] ?? 0,
      tooOld: map['too_old'] ?? 0,
      tooYoung: map['too_young'] ?? 0,
    );
  }
}

class KehamilanByMonth {
  final int total;
  final int abortus;
  final int restiMasyarakat;
  final int restiNakes;

  KehamilanByMonth({
    required this.total,
    required this.abortus,
    required this.restiMasyarakat,
    required this.restiNakes,
  });

  factory KehamilanByMonth.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return KehamilanByMonth(
        total: 0,
        abortus: 0,
        restiMasyarakat: 0,
        restiNakes: 0,
      );
    }
    return KehamilanByMonth(
      total: map['total'] ?? 0,
      abortus: map['abortus'] ?? 0,
      restiMasyarakat: map['resti_masyarakat'] ?? 0,
      restiNakes: map['resti_nakes'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'total': total,
      'abortus': abortus,
      'resti_masyarakat': restiMasyarakat,
      'resti_nakes': restiNakes,
    };
  }
}

class PersalinanByMonth {
  final int total;
  final int tempatRs;
  final int tempatRsb;
  final int tempatKlinik;
  final int tempatBpm;
  final int tempatPkm;
  final int tempatPoskesdes;
  final int tempatPolindes;
  final int persalinanFaskes;
  final int tempatRumahNakes;
  final int tempatJalanNakes;
  final int persalinanNakes;
  final int tempatRumahDkKlg;
  final int caraNormal;
  final int caraVacuum;
  final int caraForceps;
  final int caraSc;
  final int bayiLahirHidup;
  final int bayiLahirMati;
  final int bayiIufd;

  PersalinanByMonth({
    required this.total,
    required this.tempatRs,
    required this.tempatRsb,
    required this.tempatKlinik,
    required this.tempatBpm,
    required this.tempatPkm,
    required this.tempatPoskesdes,
    required this.tempatPolindes,
    required this.persalinanFaskes,
    required this.tempatRumahNakes,
    required this.tempatJalanNakes,
    required this.persalinanNakes,
    required this.tempatRumahDkKlg,
    required this.caraNormal,
    required this.caraVacuum,
    required this.caraForceps,
    required this.caraSc,
    required this.bayiLahirHidup,
    required this.bayiLahirMati,
    required this.bayiIufd,
  });

  factory PersalinanByMonth.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return PersalinanByMonth(
        total: 0,
        tempatRs: 0,
        tempatRsb: 0,
        tempatKlinik: 0,
        tempatBpm: 0,
        tempatPkm: 0,
        tempatPoskesdes: 0,
        tempatPolindes: 0,
        persalinanFaskes: 0,
        tempatRumahNakes: 0,
        tempatJalanNakes: 0,
        persalinanNakes: 0,
        tempatRumahDkKlg: 0,
        caraNormal: 0,
        caraVacuum: 0,
        caraForceps: 0,
        caraSc: 0,
        bayiLahirHidup: 0,
        bayiLahirMati: 0,
        bayiIufd: 0,
      );
    }
    return PersalinanByMonth(
      total: map['total'] ?? 0,
      tempatRs: map['tempat_rs'] ?? 0,
      tempatRsb: map['tempat_rsb'] ?? 0,
      tempatKlinik: map['tempat_klinik'] ?? 0,
      tempatBpm: map['tempat_bpm'] ?? 0,
      tempatPkm: map['tempat_pkm'] ?? 0,
      tempatPoskesdes: map['tempat_poskesdes'] ?? 0,
      tempatPolindes: map['tempat_polindes'] ?? 0,
      persalinanFaskes: map['persalinan_faskes'] ?? 0,
      tempatRumahNakes: map['tempat_rumah_nakes'] ?? 0,
      tempatJalanNakes: map['tempat_jalan_nakes'] ?? 0,
      persalinanNakes: map['persalinan_nakes'] ?? 0,
      tempatRumahDkKlg: map['tempat_rumah_dk_klg'] ?? 0,
      caraNormal: map['cara_normal'] ?? 0,
      caraVacuum: map['cara_vacuum'] ?? 0,
      caraForceps: map['cara_forceps'] ?? 0,
      caraSc: map['cara_sc'] ?? 0,
      bayiLahirHidup: map['bayi_lahir_hidup'] ?? 0,
      bayiLahirMati: map['bayi_lahir_mati'] ?? 0,
      bayiIufd: map['bayi_iufd'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'total': total,
      'tempat_rs': tempatRs,
      'tempat_rsb': tempatRsb,
      'tempat_klinik': tempatKlinik,
      'tempat_bpm': tempatBpm,
      'tempat_pkm': tempatPkm,
      'tempat_poskesdes': tempatPoskesdes,
      'tempat_polindes': tempatPolindes,
      'persalinan_faskes': persalinanFaskes,
      'tempat_rumah_nakes': tempatRumahNakes,
      'tempat_jalan_nakes': tempatJalanNakes,
      'persalinan_nakes': persalinanNakes,
      'tempat_rumah_dk_klg': tempatRumahDkKlg,
      'cara_normal': caraNormal,
      'cara_vacuum': caraVacuum,
      'cara_forceps': caraForceps,
      'cara_sc': caraSc,
      'bayi_lahir_hidup': bayiLahirHidup,
      'bayi_lahir_mati': bayiLahirMati,
      'bayi_iufd': bayiIufd,
    };
  }
}

class PasienByMonth {
  final int total;

  PasienByMonth({required this.total});

  factory PasienByMonth.fromMap(Map<String, dynamic>? map) {
    if (map == null) return PasienByMonth(total: 0);
    return PasienByMonth(total: map['total'] ?? 0);
  }

  Map<String, dynamic> toMap() {
    return {'total': total};
  }
}

class KunjunganByMonth {
  final int abortus;
  final int total;
  final int k1;
  final int k14t;
  final int k1Akses;
  final int k1AksesUsg;
  final int k1AksesDokter;
  final int k1Murni;
  final int k1MurniUsg;
  final int k1MurniDokter;
  final int k1Usg;
  final int k1Dokter;
  final int k2;
  final int k3;
  final int k4;
  final int k5;
  final int k5Usg;
  final int k6;
  final int k6Usg;

  KunjunganByMonth({
    required this.total,
    required this.k1,
    required this.k1Akses,
    required this.k1Murni,
    required this.k1Usg,
    required this.k1Dokter,
    required this.k2,
    required this.k3,
    required this.k4,
    required this.k5,
    required this.k6,
    required this.abortus,
    required this.k14t,
    required this.k1AksesDokter,
    required this.k1AksesUsg,
    required this.k1MurniDokter,
    required this.k1MurniUsg,
    required this.k5Usg,
    required this.k6Usg,
  });

  factory KunjunganByMonth.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return KunjunganByMonth(
        total: 0,
        k1: 0,
        k1Akses: 0,
        k1Murni: 0,
        k1Usg: 0,
        k1Dokter: 0,
        k2: 0,
        k3: 0,
        k4: 0,
        k5: 0,
        k6: 0,
        abortus: 0,
        k14t: 0,
        k1AksesDokter: 0,
        k1AksesUsg: 0,
        k1MurniDokter: 0,
        k1MurniUsg: 0,
        k5Usg: 0,
        k6Usg: 0,
      );
    }
    return KunjunganByMonth(
      total: map['total'] ?? 0,
      abortus: map['abortus'] ?? 0,
      k1: map['k1'] ?? 0,
      k14t: map['k1_4t'] ?? 0,
      k1Akses: map['k1_akses'] ?? 0,
      k1AksesDokter: map['k1_akses_dokter'] ?? 0,
      k1AksesUsg: map['k1_akses_usg'] ?? 0,
      k1Murni: map['k1_murni'] ?? 0,
      k1MurniDokter: map['k1_murni_dokter'] ?? 0,
      k1MurniUsg: map['k1_murni_usg'] ?? 0,
      k1Usg: map['k1_usg'] ?? 0,
      k1Dokter: map['k1_dokter'] ?? 0,
      k2: map['k2'] ?? 0,
      k3: map['k3'] ?? 0,
      k4: map['k4'] ?? 0,
      k5: map['k5'] ?? 0,
      k5Usg: map['k5_usg'] ?? 0,
      k6: map['k6'] ?? 0,
      k6Usg: map['k6_usg'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'total': total,
      'abortus': abortus,
      'k1': k1,
      'k1_4t': k14t,
      'k1_akses': k1Akses,
      'k1_akses_dokter': k1AksesDokter,
      'k1_akses_usg': k1AksesUsg,
      'k1_murni': k1Murni,
      'k1_murni_dokter': k1MurniDokter,
      'k1_murni_usg': k1MurniUsg,
      'k1_usg': k1Usg,
      'k1_dokter': k1Dokter,
      'k2': k2,
      'k3': k3,
      'k4': k4,
      'k5': k5,
      'k5_usg': k5Usg,
      'k6': k6,
      'k6_usg': k6Usg,
    };
  }
}
