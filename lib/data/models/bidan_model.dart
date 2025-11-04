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
  final String? photoUrl;
  final bool active;
  final DateTime createdAt;
  final String desa;
  final String email;
  final String idPuskesmas; // simpan path
  final String nama;
  final String nip;
  final String noHp;
  final String puskesmas;
  final String role;
  final Subscription? subscription;
  final Trial trial;

  Bidan({
    required this.photoUrl,
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

  /// ---------------- FROM FIRESTORE ----------------
  factory Bidan.fromFirestore(
    Map<String, dynamic> json, {
    required String? avatar,
  }) {
    return Bidan(
      photoUrl: avatar,
      active: json['active'] ?? false,
      createdAt: (json['created_at'] as Timestamp).toDate(),
      desa: json['desa'] ?? '',
      email: json['email'] ?? '',
      idPuskesmas: (json['id_puskesmas'] as DocumentReference).path,
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

  Map<String, dynamic> toFirestore() {
    return {
      'photo_url': photoUrl,
      'active': active,
      'created_at': createdAt,
      'desa': desa,
      'email': email,
      'id_puskesmas': FirebaseFirestore.instance.doc(idPuskesmas),
      'nama': nama,
      'nip': nip,
      'no_hp': noHp,
      'puskesmas': puskesmas,
      'role': role,
      if (subscription != null) 'subscription': subscription!.toFirestore(),
      'trial': trial.toFirestore(),
    };
  }

  /// ---------------- FOR HYDRATED BLOC ----------------
  factory Bidan.fromJson(Map<String, dynamic> json) {
    return Bidan(
      photoUrl: json['photo_url'],
      active: json['active'] ?? false,
      createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
      desa: json['desa'] ?? '',
      email: json['email'] ?? '',
      idPuskesmas: json['id_puskesmas'] ?? '',
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
      'photo_url': photoUrl,
      'active': active,
      'created_at': createdAt.toIso8601String(),
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

  /// ---------------- PREMIUM STATUS ----------------
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

  PremiumType get premiumType => premiumStatus.premiumType;
  DateTime? get expiryDate => premiumStatus.expiryDate;
}

/// ---------------- SUBSCRIPTION ----------------
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
      expiryDate: _parseDate(json['expiry_date']),
      startDate: _parseDate(json['start_date']),
      status: json['status'] ?? '',
      type: json['type'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'auto_renew': autoRenew,
      if (expiryDate != null) 'expiry_date': expiryDate,
      if (startDate != null) 'start_date': startDate,
      'status': status,
      'type': type,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'auto_renew': autoRenew,
      if (expiryDate != null) 'expiry_date': expiryDate!.toIso8601String(),
      if (startDate != null) 'start_date': startDate!.toIso8601String(),
      'status': status,
      'type': type,
    };
  }
}

/// ---------------- TRIAL ----------------
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
      expiryDate: _parseDate(json['expiry_date']) ?? DateTime.now(),
      startDate: _parseDate(json['start_date']) ?? DateTime.now(),
      used: json['used'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {'expiry_date': expiryDate, 'start_date': startDate, 'used': used};
  }

  Map<String, dynamic> toJson() {
    return {
      'expiry_date': expiryDate.toIso8601String(),
      'start_date': startDate.toIso8601String(),
      'used': used,
    };
  }
}

/// ---------------- HELPER ----------------
DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is Timestamp) return value.toDate();
  if (value is String) return DateTime.tryParse(value);
  if (value is DateTime) return value;
  return null;
}

class MinimumBidan {
  final String desa;
  final String email;
  final String nama;
  final String nip;
  final String noHp;
  final String puskesmas;
  final DocumentReference idPuskesmas;

  MinimumBidan({
    required this.desa,
    required this.email,
    required this.nama,
    required this.nip,
    required this.noHp,
    required this.puskesmas,
    required this.idPuskesmas,
  });
}
