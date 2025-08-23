import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebidan/data/models/kehamilan_model.dart';
import 'package:ebidan/data/models/kunjungan_model.dart';
import 'package:ebidan/logic/utility/Utils.dart';
import 'package:ebidan/presentation/router/app_router.dart';
import 'package:flutter/material.dart';

class ListKunjunganScreen extends StatefulWidget {
  final String docId;

  const ListKunjunganScreen({super.key, required this.docId});

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
          .doc(widget.docId)
          .collection('kunjungan')
          .get();
      final kunjunganList = snapshot.docs
          .map((e) => Kunjungan.fromFirestore(e.data()))
          .toList();

      if (mounted) {
        setState(() {
          _kunjunganlist = kunjunganList;
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
