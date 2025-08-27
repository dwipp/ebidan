import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebidan/data/models/kehamilan_model.dart';
import 'package:ebidan/presentation/router/app_router.dart';
import 'package:flutter/material.dart';

class ListKehamilanScreen extends StatefulWidget {
  final Kehamilan latestKehamilan;
  final String bumilId;
  final String bidanId;

  const ListKehamilanScreen({
    super.key,
    required this.latestKehamilan,
    required this.bumilId,
    required this.bidanId,
  });

  @override
  State<ListKehamilanScreen> createState() => _ListKehamilanScreenState();
}

class _ListKehamilanScreenState extends State<ListKehamilanScreen> {
  List<Kehamilan> _kehamilanList = [];
  bool _loading = false;
  bool _expanded = false; // tanda apakah user sudah fetch semua

  Future<void> _fetchKehamilan() async {
    setState(() => _loading = true);
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('kehamilan')
          .where('id_bumil', isEqualTo: widget.bumilId)
          .where('id_bidan', isEqualTo: widget.bidanId)
          .orderBy('created_at', descending: true)
          .get();

      final List<Kehamilan> list = snapshot.docs
          .map((doc) => Kehamilan.fromFirestore(doc.id, doc.data()))
          .toList();

      if (mounted) {
        setState(() {
          _kehamilanList = list;
          _expanded = true;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetch kehamilan: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("List Kehamilan")),
      body: ListView(
        children: [
          // item pertama: latest kehamilan
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              title: Text("Tahun ${widget.latestKehamilan.createdAt!.year}"),
              subtitle: Text(
                "Status persalinan: ${widget.latestKehamilan.persalinan != null ? 'sudah' : 'belum'}",
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRouter.dataKehamilan,
                  arguments: {'kehamilan': widget.latestKehamilan},
                );
              },
            ),
          ),

          // item kedua: tombol atau daftar riwayat
          if (_expanded)
            ..._kehamilanList
                .skip(1)
                .map(
                  (kehamilan) => Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
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
                  ),
                )
          else
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                leading: const Icon(Icons.history),
                title: const Text("Lihat riwayat kehamilan lainnya"),
                trailing: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.expand_more),
                onTap: _loading ? null : _fetchKehamilan,
              ),
            ),
        ],
      ),
    );
  }
}
