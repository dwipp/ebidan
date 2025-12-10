import 'package:ebidan/presentation/widgets/page_header.dart';
import 'package:ebidan/state_management/general/cubit/connectivity_cubit.dart';
import 'package:ebidan/state_management/mode_koordinator/bidan/cubit/get_bidan_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ListBidanScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    context.read<GetBidanCubit>().fetchBidanList(
      context.read<ConnectivityCubit>().state,
    );
    return Scaffold(
      appBar: PageHeader(
        title: Text('Daftar Bidan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: Colors.cyan),
            onPressed: () {
              // masuk ke page invite bidan
              // menampilkan textfield untuk input NIP bidan, kemudian menampilkan data singkat bidan di bawah nya dan ada tombol invite
            },
          ),
        ],
      ),
      body: BlocBuilder<GetBidanCubit, GetBidanState>(
        builder: (context, state) {
          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: state.bidanList.length,
            itemBuilder: (context, i) {
              final dataBidan = state.bidanList[i];
              return Card(
                elevation: 1,
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.pink[50],
                    child: const Icon(Icons.person, color: Colors.pinkAccent),
                  ),
                  title: Text(
                    dataBidan.nama,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    'NIP: ${dataBidan.nip}',
                    style: const TextStyle(fontSize: 13),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // masuk ke page data desa sederhana dari bidan.
                    // jumlah kehamilan saat ini, jumlah melahirkan bulan ini, jumlah kunjungan bulan ini, dll
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
