import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebidan/data/models/kehamilan_model.dart';
import 'package:ebidan/data/models/kunjungan_model.dart';
import 'package:ebidan/logic/utility/Utils.dart';
import 'package:ebidan/presentation/router/app_router.dart';
import 'package:flutter/material.dart';

class ListKunjunganScreen extends StatefulWidget {
  final String bumilId;
  final String bidanId;

  const ListKunjunganScreen({
    super.key,
    required this.bumilId,
    required this.bidanId,
  });

  @override
  State<ListKunjunganScreen> createState() => _ListKunjunganScreenState();
}

class _ListKunjunganScreenState extends State<ListKunjunganScreen> {
  List<Kunjungan> _kunjunganlist = [];
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
          .limit(1)
          .get();

      List<Kunjungan> list = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();

        final kunjunganSnap = await doc.reference.collection('kunjungan').get();
        final kunjunganList = kunjunganSnap.docs
            .map((e) => Kunjungan.fromFirestore(e.data()))
            .toList();
        list = kunjunganList;
        // list.add(Kehamilan.fromFirestore(doc.id, data, kunjunganList));
      }

      if (mounted) {
        setState(() {
          _kunjunganlist = list;
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

    if (_kunjunganlist.isEmpty) {
      return const Center(child: Text("Tidak ada data kunjungan"));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("List Kunjungan")),
      body: ListView.builder(
        itemCount: _kunjunganlist.length,
        itemBuilder: (context, index) {
          final kunjungan = _kunjunganlist[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              title: Text(Utils.formattedDate(kunjungan.createdAt)),
              subtitle: kunjungan.status == '-'
                  ? null
                  : Text('status: ${kunjungan.status}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRouter.detailKunjungan,
                  arguments: {'kunjungan': kunjungan},
                );
              },
            ),
          );
        },
      ),
    );
  }
}
