class Statistic {
  final BumilStats bumil;
  final String lastUpdatedMonth;
  final Map<String, ByMonthStats> byMonth;

  Statistic({
    required this.bumil,
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
      bumil: BumilStats.fromMap(map['bumil'] ?? {}),
      lastUpdatedMonth: map['last_updated_month'] ?? '',
      byMonth: byMonthData,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bumil': bumil.toMap(),
      'last_updated_month': lastUpdatedMonth,
      'by_month': byMonth.map((key, value) => MapEntry(key, value.toMap())),
    };
  }

  /// ✅ Ambil data `ByMonthStats` sesuai `lastUpdatedMonth`
  ByMonthStats? get lastMonthData {
    return byMonth[lastUpdatedMonth];
  }
}

class BumilStats {
  final int bumilThisMonth;
  final int bumilTotal;

  BumilStats({required this.bumilThisMonth, required this.bumilTotal});

  factory BumilStats.fromMap(Map<String, dynamic> map) {
    return BumilStats(
      bumilThisMonth: map['bumil_this_month'] ?? 0,
      bumilTotal: map['bumil_total'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {'bumil_this_month': bumilThisMonth, 'bumil_total': bumilTotal};
  }
}

class ByMonthStats {
  final int bumil;
  final int k1;
  final int k1Akses;
  final int k1Murni;
  final int k4;
  final int k5;
  final int k6;

  ByMonthStats({
    required this.bumil,
    required this.k1,
    required this.k1Akses,
    required this.k1Murni,
    required this.k4,
    required this.k5,
    required this.k6,
  });

  factory ByMonthStats.fromMap(Map<String, dynamic> map) {
    return ByMonthStats(
      bumil: map['bumil'] ?? 0,
      k1: map['k1'] ?? 0,
      k1Akses: map['k1_akses'] ?? 0,
      k1Murni: map['k1_murni'] ?? 0,
      k4: map['k4'] ?? 0,
      k5: map['k5'] ?? 0,
      k6: map['k6'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bumil': bumil,
      'k1': k1,
      'k1_akses': k1Akses,
      'k1_murni': k1Murni,
      'k4': k4,
      'k5': k5,
      'k6': k6,
    };
  }
}
