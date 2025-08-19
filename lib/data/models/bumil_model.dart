class Bumil {
  final String idBidan;
  final String namaIbu;
  final String noHp;

  Bumil({required this.idBidan, required this.namaIbu, required this.noHp});

  factory Bumil.fromMap(String idBidan, Map<String, dynamic> map) {
    return Bumil(
      idBidan: idBidan,
      namaIbu: map['nama_ibu'] ?? '', // field di Firestore
      noHp: map['no_hp'] ?? '',
    );
  }
}
