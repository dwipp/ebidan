import 'package:cloud_firestore/cloud_firestore.dart';

enum PremiumType { none, trial, subscription }

class PremiumStatus {
  final bool isPremium;
  final PremiumType premiumType;
  final DateTime? expiryDate;

  PremiumStatus({
    required this.isPremium,
    required this.premiumType,
    this.expiryDate,
  });
}

class Bidan {
  final bool active;
  final DateTime createdAt;
  final String desa;
  final String email;
  final DocumentReference idPuskesmas;
  final String nama;
  final String nip;
  final String noHp;
  final String puskesmas;
  final String role;
  final Subscription? subscription;
  final Trial trial;

  Bidan({
    required this.active,
    required this.createdAt,
    required this.desa,
    required this.email,
    required this.idPuskesmas,
    required this.nama,
    required this.nip,
    required this.noHp,
    required this.puskesmas,
    required this.role,
    required this.subscription,
    required this.trial,
  });

  factory Bidan.fromJson(Map<String, dynamic> json) {
    return Bidan(
      active: json['active'] ?? false,
      createdAt: (json['created_at'] as Timestamp).toDate(),
      desa: json['desa'] ?? '',
      email: json['email'] ?? '',
      idPuskesmas: json['id_puskesmas'] as DocumentReference,
      nama: json['nama'] ?? '',
      nip: json['nip'] ?? '',
      noHp: json['no_hp'] ?? '',
      puskesmas: json['puskesmas'] ?? '',
      role: json['role'] ?? '',
      subscription: json['subscription'] != null
          ? Subscription.fromJson(json['subscription'])
          : null,
      trial: Trial.fromJson(json['trial'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'active': active,
      'created_at': createdAt,
      'desa': desa,
      'email': email,
      'id_puskesmas': idPuskesmas,
      'nama': nama,
      'nip': nip,
      'no_hp': noHp,
      'puskesmas': puskesmas,
      'role': role,
      if (subscription != null) 'subscription': subscription!.toJson(),
      'trial': trial.toJson(),
    };
  }

  /// Utility untuk status premium
  PremiumStatus get premiumStatus {
    final now = DateTime.now();

    if (trial.expiryDate.isAfter(now)) {
      return PremiumStatus(
        isPremium: true,
        premiumType: PremiumType.trial,
        expiryDate: trial.expiryDate,
      );
    }

    if (subscription != null &&
        subscription!.status == 'active' &&
        subscription!.expiryDate != null &&
        subscription!.expiryDate!.isAfter(now)) {
      return PremiumStatus(
        isPremium: true,
        premiumType: PremiumType.subscription,
        expiryDate: subscription!.expiryDate,
      );
    }

    return PremiumStatus(
      isPremium: false,
      premiumType: PremiumType.none,
      expiryDate: null,
    );
  }

  /// Shortcut agar bisa langsung akses
  PremiumType get premiumType => premiumStatus.premiumType;
  DateTime? get expiryDate => premiumStatus.expiryDate;
}

class Subscription {
  final bool autoRenew;
  final DateTime? expiryDate;
  final DateTime? startDate;
  final String status;
  final String type;

  Subscription({
    this.autoRenew = false,
    this.expiryDate,
    this.startDate,
    this.status = '',
    this.type = '',
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      autoRenew: json['auto_renew'] ?? false,
      expiryDate: json['expiry_date'] != null
          ? (json['expiry_date'] as Timestamp).toDate()
          : null,
      startDate: json['start_date'] != null
          ? (json['start_date'] as Timestamp).toDate()
          : null,
      status: json['status'] ?? '',
      type: json['type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'auto_renew': autoRenew,
      if (expiryDate != null) 'expiry_date': expiryDate,
      if (startDate != null) 'start_date': startDate,
      'status': status,
      'type': type,
    };
  }
}

class Trial {
  final DateTime expiryDate;
  final DateTime startDate;
  final bool used;

  Trial({
    required this.expiryDate,
    required this.startDate,
    required this.used,
  });

  factory Trial.fromJson(Map<String, dynamic> json) {
    return Trial(
      expiryDate: (json['expiry_date'] as Timestamp).toDate(),
      startDate: (json['start_date'] as Timestamp).toDate(),
      used: json['used'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'expiry_date': expiryDate, 'start_date': startDate, 'used': used};
  }
}
