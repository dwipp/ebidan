import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebidan/data/models/kehamilan_model.dart';
import 'package:ebidan/data/models/kunjungan_model.dart';
import 'package:ebidan/presentation/router/app_router.dart';
import 'package:flutter/material.dart';

class ListKehamilanScreen extends StatefulWidget {
  final String bumilId;
  final String bidanId;

  const ListKehamilanScreen({
    super.key,
    required this.bumilId,
    required this.bidanId,
  });

  @override
  State<ListKehamilanScreen> createState() => _ListKehamilanScreenState();
}

class _ListKehamilanScreenState extends State<ListKehamilanScreen> {
  List<Kehamilan> _kehamilanList = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchKehamilan();
  }

  Future<void> _fetchKehamilan() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('kehamilan')
          .where('id_bumil', isEqualTo: widget.bumilId)
          .where('id_bidan', isEqualTo: widget.bidanId)
          .orderBy('created_at', descending: true)
          .get();

      final List<Kehamilan> list = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();

        final kunjunganSnap = await doc.reference.collection('kunjungan').get();
        final kunjunganList = kunjunganSnap.docs
            .map((e) => Kunjungan.fromFirestore(e.data()))
            .toList();

        list.add(Kehamilan.fromFirestore(doc.id, data, kunjunganList));
      }

      if (mounted) {
        setState(() {
          _kehamilanList = list;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetch kehamilan: $e');
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_kehamilanList.isEmpty) {
      return const Center(child: Text("Tidak ada data kehamilan"));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("List Kehamilan")),
      body: ListView.builder(
        itemCount: _kehamilanList.length,
        itemBuilder: (context, index) {
          final kehamilan = _kehamilanList[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              title: Text("Tahun ${kehamilan.createdAt!.year}"),
              subtitle: Text(
                "Status persalinan: ${kehamilan.persalinan != null ? 'sudah' : 'belum'}",
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRouter.dataKehamilan,
                  arguments: {'kehamilan': kehamilan},
                );
              },
            ),
          );
        },
      ),
    );
  }
}
