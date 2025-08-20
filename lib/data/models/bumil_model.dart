class Bumil {
  final String idBidan;
  final String namaIbu;
  final String noHp;
  final String idBumil;

  Bumil({
    required this.idBidan,
    required this.namaIbu,
    required this.noHp,
    required this.idBumil,
  });

  factory Bumil.fromMap(String idBumil, Map<String, dynamic> map) {
    return Bumil(
      idBidan: map['id_bidan'] ?? '',
      namaIbu: map['nama_ibu'] ?? '', // field di Firestore
      noHp: map['no_hp'] ?? '',
      idBumil: idBumil,
    );
  }
}
