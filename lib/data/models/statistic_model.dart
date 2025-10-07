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
}

class ByMonthStats {
  final KehamilanByMonth kehamilan;
  final PasienByMonth pasien;
  final KunjunganByMonth kunjungan;
  final PersalinanByMonth persalinan;
  final RestiByMonth resti;

  ByMonthStats({
    required this.kehamilan,
    required this.pasien,
    required this.kunjungan,
    required this.persalinan,
    required this.resti,
  });

  factory ByMonthStats.fromMap(Map<String, dynamic> map) {
    return ByMonthStats(
      kehamilan: KehamilanByMonth.fromMap(map['kehamilan']),
      pasien: PasienByMonth.fromMap(map['pasien']),
      kunjungan: KunjunganByMonth.fromMap(map['kunjungan']),
      persalinan: PersalinanByMonth.fromMap(map['persalinan']),
      resti: RestiByMonth.fromMap(map['resti']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'kehamilan': kehamilan.toMap(),
      'pasien': pasien.toMap(),
      'kunjungan': kunjungan.toMap(),
      'resti': resti.toMap(),
    };
  }
}

class RestiByMonth {
  final int abortus;
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
    required this.abortus,
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

  int get totalResti {
    var total =
        abortus +
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
      'abortus': abortus,
      'anemia': anemia,
      'bbBayiUnder2500': bbBayiUnder2500,
      'hipertensi': hipertensi,
      'jarakHamil': jarakHamil,
      'kek': kek,
      'obesitas': obesitas,
      'paritasTinggi': paritasTinggi,
      'pernahAbortus': pernahAbortus,
      'restiMasyarakat': restiMasyarakat,
      'restiNakes': restiNakes,
      'tbUnder145': tbUnder145,
      'tooOld': tooOld,
      'tooYoung': tooYoung,
    };
  }

  factory RestiByMonth.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return RestiByMonth(
        abortus: 0,
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
      abortus: map['abortus'] ?? 0,
      anemia: map['anemia'] ?? 0,
      bbBayiUnder2500: map['bbBayiUnder2500'] ?? 0,
      hipertensi: map['hipertensi'] ?? 0,
      jarakHamil: map['jarakHamil'] ?? 0,
      kek: map['kek'] ?? 0,
      obesitas: map['obesitas'] ?? 0,
      paritasTinggi: map['paritasTinggi'] ?? 0,
      pernahAbortus: map['pernahAbortus'] ?? 0,
      restiMasyarakat: map['restiMasyarakat'] ?? 0,
      restiNakes: map['restiNakes'] ?? 0,
      tbUnder145: map['tbUnder145'] ?? 0,
      tooOld: map['tooOld'] ?? 0,
      tooYoung: map['tooYoung'] ?? 0,
    );
  }
}

class KehamilanByMonth {
  final int total;

  KehamilanByMonth({required this.total});

  factory KehamilanByMonth.fromMap(Map<String, dynamic>? map) {
    if (map == null) return KehamilanByMonth(total: 0);
    return KehamilanByMonth(total: map['total'] ?? 0);
  }

  Map<String, dynamic> toMap() {
    return {'total': total};
  }
}

class PersalinanByMonth {
  final int total;

  PersalinanByMonth({required this.total});

  factory PersalinanByMonth.fromMap(Map<String, dynamic>? map) {
    if (map == null) return PersalinanByMonth(total: 0);
    return PersalinanByMonth(total: map['total'] ?? 0);
  }

  Map<String, dynamic> toMap() {
    return {'total': total};
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
      abortus: map['abortus'] ?? 0,
      total: map['total'] ?? 0,
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
      'abortus': abortus,
      'total': total,
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
