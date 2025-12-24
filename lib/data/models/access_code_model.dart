import 'package:cloud_firestore/cloud_firestore.dart';

class AccessCode {
  final int accessDurationDays;
  final String msgTitle;
  final String code;
  final String msgDesc;
  final DateTime expiryDate;
  final DateTime startDate;
  final int maxRedemptions;
  final int redeemedCount;

  AccessCode({
    required this.accessDurationDays,
    required this.msgTitle,
    required this.code,
    required this.msgDesc,
    required this.expiryDate,
    required this.startDate,
    required this.maxRedemptions,
    required this.redeemedCount,
  });

  factory AccessCode.fromFirestore(Map<String, dynamic> json) {
    return AccessCode(
      accessDurationDays: json['access_duration_days'] ?? 0,
      msgTitle: json['msg_title'] ?? '',
      code: json['code'] ?? '',
      msgDesc: json['msg_desc'] ?? '',
      expiryDate: (json['expiry_date'] as Timestamp).toDate(),
      startDate: (json['start_date'] as Timestamp).toDate(),
      maxRedemptions: json['max_redemptions'] ?? 0,
      redeemedCount: json['redeemed_count'] ?? 0,
    );
  }
}
