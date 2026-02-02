// ignore_for_file: public_member_api_docs, sort_constructors_first

class Wording {
  final WordingSubscription subscription;

  Wording({required this.subscription});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'subscription': subscription.toMap()};
  }

  factory Wording.fromFirebase(Map<String, dynamic> map) {
    return Wording(
      subscription: WordingSubscription.fromFirebase(
        map['subscription'] as Map<String, dynamic>,
      ),
    );
  }
}

class WordingSubscription {
  final String premiumAnnual;
  final String premiumSemiannual;
  final String premiumQuarterly;
  final String premiumMonthly;
  final String premiumHeader;
  final String promoAnnual;
  final String promoSemiannual;
  final String promoQuarterly;
  final String promoHeader;
  final num basePrice;

  WordingSubscription({
    required this.premiumAnnual,
    required this.premiumSemiannual,
    required this.premiumQuarterly,
    required this.premiumMonthly,
    required this.premiumHeader,
    required this.promoAnnual,
    required this.promoSemiannual,
    required this.promoQuarterly,
    required this.promoHeader,
    required this.basePrice,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'premium_annual': premiumAnnual,
      'premium_semiannual': premiumSemiannual,
      'premium_quarterly': premiumQuarterly,
      'premium_monthly': premiumMonthly,
      'premium_header': premiumHeader,
      'promo_annual': promoAnnual,
      'promo_semiannual': promoSemiannual,
      'promo_quarterly': promoQuarterly,
      'promo_header': promoHeader,
      'base_price': basePrice,
    };
  }

  factory WordingSubscription.fromFirebase(Map<String, dynamic> map) {
    return WordingSubscription(
      premiumAnnual: map['premium_annual'] ?? '',
      premiumSemiannual: map['premium_semiannual'] ?? '',
      premiumQuarterly: map['premium_quarterly'] ?? '',
      premiumMonthly: map['premium_monthly'] ?? '',
      premiumHeader: map['premium_header'] ?? '',
      promoAnnual: map['promo_annual'] ?? '',
      promoSemiannual: map['promo_semiannual'] ?? '',
      promoQuarterly: map['promo_quarterly'] ?? '',
      promoHeader: map['promo_header'] ?? '',
      basePrice: map['base_price'] ?? 0,
    );
  }
}
