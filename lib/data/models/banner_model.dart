import 'package:cloud_firestore/cloud_firestore.dart';

class BannerModel {
  // final String id;
  final String title;
  final String subtitle;
  final String content;
  final bool isActive;

  BannerModel({
    // required this.id,
    required this.title,
    required this.subtitle,
    required this.content,
    required this.isActive,
  });

  /// =============================
  /// FROM FIRESTORE
  /// =============================
  factory BannerModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;

    return BannerModel(
      // id: doc.id,
      title: data['title'] as String? ?? '',
      subtitle: data['subtitle'] as String? ?? '',
      content: data['content'] as String? ?? '',
      isActive: data['is_active'] as bool? ?? false,
    );
  }

  /// =============================
  /// TO FIRESTORE
  /// =============================
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'subtitle': subtitle,
      'content': content,
      'is_active': isActive,
    };
  }
}
