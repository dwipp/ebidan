import 'package:ebidan/common/Utils.dart';
import 'package:ebidan/data/models/kehamilan_model.dart';
import 'package:ebidan/presentation/router/app_router.dart';
import 'package:ebidan/state_management/kehamilan/cubit/get_kehamilan_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ListKehamilanScreen extends StatefulWidget {
  final Kehamilan latestKehamilan;
  final bool latestStatusKunjungan;
  final String bumilId;
  final String bidanId;

  const ListKehamilanScreen({
    super.key,
    required this.latestKehamilan,
    required this.latestStatusKunjungan,
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

  @override
  void initState() {
    context.read<GetKehamilanCubit>().setInitial();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("List Kehamilan")),
      body: BlocConsumer<GetKehamilanCubit, GetKehamilanState>(
        listener: (context, state) {
          if (state is GetKehamilanSuccess) {
            _kehamilanList = state.kehamilans;
            _expanded = true;
            _loading = false;
          } else if (state is GetKehamilanEmpty) {
            _expanded = true;
            _loading = false;
          } else if (state is GetKehamilanLoading) {
            _expanded = false;
            _loading = true;
          } else if (state is GetKehamilanFailure) {
            Utils.showSnackBar(
              context,
              content: 'Gagal: ${state.message}',
              isSuccess: false,
            );
            _expanded = false;
            _loading = false;
          }
        },
        builder: (context, state) {
          return ListView(
            children: [
              // item pertama: latest kehamilan
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text(
                    "Tahun ${widget.latestKehamilan.createdAt!.year}",
                  ),
                  subtitle: Text(
                    "Status persalinan: ${widget.latestKehamilan.persalinan != null ? 'sudah' : 'belum'}",
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRouter.detailKehamilan,
                      arguments: {
                        'kehamilan': widget.latestKehamilan,
                        'statusKunjungan': widget.latestStatusKunjungan,
                      },
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
                              AppRouter.detailKehamilan,
                              arguments: {
                                'kehamilan': kehamilan,
                                'statusKunjungan': widget.latestStatusKunjungan,
                              },
                            );
                          },
                        ),
                      ),
                    )
              else
                Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
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
                    onTap: _loading
                        ? null
                        : () {
                            context.read<GetKehamilanCubit>().getKehamilan(
                              bumilId: widget.bumilId,
                            );
                          },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
