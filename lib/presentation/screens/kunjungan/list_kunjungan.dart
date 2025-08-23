import 'package:cloud_firestore/cloud_firestore.dart';
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
  List<Kunjungan> _kunjunganList = [];
  bool _loading = true;
  bool _sortDesc = true; // default: terbaru di atas

  @override
  void initState() {
    super.initState();
    _fetchKunjungan();
  }

  Future<void> _fetchKunjungan() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('kehamilan')
          .doc(widget.docId)
          .collection('kunjungan')
          .orderBy('created_at', descending: _sortDesc)
          .get();

      final kunjunganList = snapshot.docs
          .map((e) => Kunjungan.fromFirestore(e.data()))
          .toList();

      if (mounted) {
        setState(() {
          _kunjunganList = kunjunganList;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetch kunjungan: $e');
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _toggleSort() {
    setState(() {
      _sortDesc = !_sortDesc;
      _loading = true;
    });
    _fetchKunjungan();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_kunjunganList.isEmpty) {
      return const Center(child: Text("Tidak ada data kunjungan"));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Kunjungan"),
        actions: [
          IconButton(
            icon: Icon(_sortDesc ? Icons.arrow_downward : Icons.arrow_upward),
            tooltip: _sortDesc ? "Urutkan Ascending" : "Urutkan Descending",
            onPressed: _toggleSort,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _kunjunganList.length,
        itemBuilder: (context, index) {
          final kunjungan = _kunjunganList[index];
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
