import 'package:ebidan/presentation/widgets/menu_button.dart';
import 'package:ebidan/presentation/router/app_router.dart';
import 'package:ebidan/presentation/widgets/page_header.dart';
import 'package:ebidan/state_management/bumil/cubit/selected_bumil_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UpdateKehamilanScreen extends StatelessWidget {
  const UpdateKehamilanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bumil = context.read<SelectedBumilCubit>().state;
    return Scaffold(
      appBar: PageHeader(title: 'Update Kehamilan'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            MenuButton(
              icon: Icons.calendar_month,
              title: 'Kunjungan Baru',
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRouter.kunjungan,
                  arguments: {'firstTime': false},
                );
              },
            ),
            MenuButton(
              icon: Icons.pregnant_woman,
              title: 'Persalinan',
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRouter.addPersalinan,
                  arguments: {
                    'kehamilanId': bumil?.latestKehamilanId,
                    'bumilId': bumil?.idBumil,
                    'resti': bumil?.latestKehamilanResti,
                    'hpht': bumil?.latestKehamilanHpht,
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
