import 'package:cloud_firestore/cloud_firestore.dart';

class AccessCode {
  final int accessDurationDays;
  final String accessName;
  final String code;
  final String desc;
  final DateTime expiryDate;
  final DateTime startDate;
  final int maxRedemptions;
  final int redeemedCount;

  AccessCode({
    required this.accessDurationDays,
    required this.accessName,
    required this.code,
    required this.desc,
    required this.expiryDate,
    required this.startDate,
    required this.maxRedemptions,
    required this.redeemedCount,
  });

  factory AccessCode.fromFirestore(Map<String, dynamic> json) {
    return AccessCode(
      accessDurationDays: json['access_duration_days'] ?? 0,
      accessName: json['access_name'] ?? '',
      code: json['code'] ?? '',
      desc: json['desc'] ?? '',
      expiryDate: (json['expiry_date'] as Timestamp).toDate(),
      startDate: (json['start_date'] as Timestamp).toDate(),
      maxRedemptions: json['max_redemptions'] ?? 0,
      redeemedCount: json['redeemed_count'] ?? 0,
    );
  }
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is Timestamp) return value.toDate();
  if (value is String) return DateTime.tryParse(value);
  if (value is DateTime) return value;
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  return null;
}
