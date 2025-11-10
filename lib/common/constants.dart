class Constants {
  static const List<String> tempatList = [
    'Rumah Sakit',
    'Rumah Sakit Bersalin',
    'Klinik',
    'Bidan Praktik Mandiri',
    'Puskesmas',
    'Poskesdes',
    'Polindes',
    'Rumah',
    'Jalan',
  ];
  static const List<String> penolongList = [
    'Bidan',
    'Dokter',
    'Perawat',
    'Dukun Kampung',
    'Lainnya',
  ];

  static const List<String> caraLahirList = [
    'Spontan Belakang Kepala',
    'Vacuum Extraction',
    'Forceps Delivery',
    'Section Caesarea (SC)',
  ];

  static const List<String> caraAbortusList = [
    'Kuretase',
    'Mandiri',
    'Lainnya',
  ];

  static const List<String> statusBayiList = [
    'Lahir Hidup',
    'Lahir Mati',
    'IUFD',
    'Abortus',
  ];

  static const List<String> statusIbuList = ['Hidup', 'Mati'];

  static const List<String> sexList = ['Laki-laki', 'Perempuan'];

  static const List<String> statusKehamilanList = [
    'Aterm',
    'Preterm',
    'Postterm',
  ];

  // subscription constants
  static const List<String> kProductIds = [
    // 'premium_quarterly',
    'premium_semiannual',
    'premium_annual',
    'premium_monthly',
  ];
  // static const String kProductId = 'premium';
  // static const List<String> kBasePlanIds = ['monthly', 'quarterly', 'yearly'];
}
