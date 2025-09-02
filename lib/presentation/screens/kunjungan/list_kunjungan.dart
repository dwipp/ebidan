import 'package:ebidan/data/models/kunjungan_model.dart';
import 'package:ebidan/common/Utils.dart';
import 'package:ebidan/presentation/router/app_router.dart';
import 'package:ebidan/presentation/widgets/page_header.dart';
import 'package:ebidan/state_management/kunjungan/cubit/get_kunjungan_cubit.dart';
import 'package:ebidan/state_management/kunjungan/cubit/selected_kunjungan_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ListKunjunganScreen extends StatefulWidget {
  final String docId;

  const ListKunjunganScreen({super.key, required this.docId});

  @override
  State<ListKunjunganScreen> createState() => _ListKunjunganScreenState();
}

class _ListKunjunganScreenState extends State<ListKunjunganScreen> {
  List<Kunjungan> _kunjunganList = [];
  bool _sortDesc = true; // default: terbaru di atas

  @override
  void initState() {
    super.initState();
    context.read<GetKunjunganCubit>().getKunjungan(kehamilanId: widget.docId);
  }

  void _toggleSort() {
    setState(() {
      _sortDesc = !_sortDesc;
      Utils.sortByDateTime<Kunjungan>(
        _kunjunganList,
        (k) => k.createdAt!,
        descending: _sortDesc,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    context.read<SelectedKunjunganCubit>().clear;
    return Scaffold(
      appBar: PageHeader(
        title: "Kunjungan",
        actions: [
          IconButton(
            icon: Icon(_sortDesc ? Icons.arrow_downward : Icons.arrow_upward),
            tooltip: _sortDesc ? "Urutkan Ascending" : "Urutkan Descending",
            onPressed: _toggleSort,
          ),
        ],
      ),
      body: BlocConsumer<GetKunjunganCubit, GetKunjunganState>(
        listener: (context, state) {
          if (state is GetKunjunganSuccess) {
            _kunjunganList = state.kunjungans;
          } else if (state is GetKunjunganFailure) {
            Utils.showSnackBar(
              context,
              content: 'Gagal: ${state.message}',
              isSuccess: false,
            );
          }
        },
        builder: (context, state) {
          if (state is GetKunjunganLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is GetKunjunganEmpty ||
              state is GetKunjunganFailure) {
            return const Center(child: Text("Tidak ada data kunjungan"));
          } else if (state is GetKunjunganFailure) {
            return const Center(child: Text("Tidak ada data kunjungan"));
          }
          return ListView.builder(
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
                    context.read<SelectedKunjunganCubit>().selectKunjungan(
                      kunjungan,
                    );
                    Navigator.pushNamed(
                      context,
                      AppRouter.detailKunjungan,
                    ).then((value) {
                      context.read<GetKunjunganCubit>().getKunjungan(
                        kehamilanId: widget.docId,
                      );
                    });
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
