class Persalinan {
  String? beratLahir;
  String? cara;
  String? lingkarKepala;
  String? panjangBadan;
  String? penolong;
  String? sex;
  String? statusBayi;
  String? tempat;
  String? umurKehamilan;
  DateTime? tglPersalinan;
  DateTime? createdAt;

  Persalinan({
    this.beratLahir,
    this.cara,
    this.lingkarKepala,
    this.panjangBadan,
    this.penolong,
    this.sex,
    this.statusBayi,
    this.tempat,
    this.umurKehamilan,
    this.tglPersalinan,
    this.createdAt,
  });

  /// constructor kosong untuk form
  factory Persalinan.empty() {
    return Persalinan(createdAt: DateTime.now());
  }

  /// convert ke map firestore
  Map<String, dynamic> toMap() {
    return {
      "berat_lahir": beratLahir,
      "cara": cara,
      "lingkar_kepala": lingkarKepala,
      "panjang_badan": panjangBadan,
      "penolong": penolong,
      "sex": sex,
      "status_bayi": statusBayi,
      "tempat": tempat,
      "umur_kehamilan": umurKehamilan,
      "tgl_persalinan": tglPersalinan,
      "created_at": createdAt ?? DateTime.now(),
    };
  }

  /// convert dari firestore ke model
  factory Persalinan.fromMap(Map<String, dynamic> map) {
    return Persalinan(
      beratLahir: map['berat_lahir']?.toString(),
      cara: map['cara'],
      lingkarKepala: map['lingkar_kepala']?.toString(),
      panjangBadan: map['panjang_badan']?.toString(),
      penolong: map['penolong'],
      sex: map['sex'],
      statusBayi: map['status_bayi'],
      tempat: map['tempat'],
      umurKehamilan: map['umur_kehamilan']?.toString(),
      tglPersalinan: map['tgl_persalinan'] is DateTime
          ? map['tgl_persalinan']
          : (map['tgl_persalinan']?.toDate()),
      createdAt: map['created_at'] is DateTime
          ? map['created_at']
          : (map['created_at']?.toDate()),
    );
  }
}
