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

  ByMonthStats({
    required this.kehamilan,
    required this.pasien,
    required this.kunjungan,
  });

  factory ByMonthStats.fromMap(Map<String, dynamic> map) {
    return ByMonthStats(
      kehamilan: KehamilanByMonth.fromMap(map['kehamilan']),
      pasien: PasienByMonth.fromMap(map['pasien']),
      kunjungan: KunjunganByMonth.fromMap(map['kunjungan']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'kehamilan': kehamilan.toMap(),
      'pasien': pasien.toMap(),
      'kunjungan': kunjungan.toMap(),
    };
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
  final int total;
  final int k1;
  final int k1Akses;
  final int k1Murni;
  final int k2;
  final int k3;
  final int k4;
  final int k5;
  final int k6;

  KunjunganByMonth({
    required this.total,
    required this.k1,
    required this.k1Akses,
    required this.k1Murni,
    required this.k2,
    required this.k3,
    required this.k4,
    required this.k5,
    required this.k6,
  });

  factory KunjunganByMonth.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return KunjunganByMonth(
        total: 0,
        k1: 0,
        k1Akses: 0,
        k1Murni: 0,
        k2: 0,
        k3: 0,
        k4: 0,
        k5: 0,
        k6: 0,
      );
    }
    return KunjunganByMonth(
      total: map['total'] ?? 0,
      k1: map['k1'] ?? 0,
      k1Akses: map['k1_akses'] ?? 0,
      k1Murni: map['k1_murni'] ?? 0,
      k2: map['k2'] ?? 0,
      k3: map['k3'] ?? 0,
      k4: map['k4'] ?? 0,
      k5: map['k5'] ?? 0,
      k6: map['k6'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'total': total,
      'k1': k1,
      'k1_akses': k1Akses,
      'k1_murni': k1Murni,
      'k2': k2,
      'k3': k3,
      'k4': k4,
      'k5': k5,
      'k6': k6,
    };
  }
}
