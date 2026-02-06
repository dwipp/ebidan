import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebidan/data/models/kunjungan_model.dart';
import 'package:ebidan/state_management/mode_bidan/bumil/cubit/selected_bumil_cubit.dart';
import 'package:ebidan/state_management/mode_bidan/kehamilan/cubit/selected_kehamilan_cubit.dart';
import 'package:ebidan/state_management/mode_bidan/kunjungan/cubit/selected_kunjungan_cubit.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'submit_kunjungan_state.dart';

class SubmitKunjunganCubit extends Cubit<SubmitKunjunganState> {
  final SelectedKunjunganCubit selectedKunjunganCubit;
  final SelectedBumilCubit selectedBumilCubit;
  final SelectedKehamilanCubit selectedKehamilanCubit;
  SubmitKunjunganCubit({
    required this.selectedKunjunganCubit,
    required this.selectedBumilCubit,
    required this.selectedKehamilanCubit,
  }) : super(AddKunjunganInitial());

  Future<void> submitKunjungan(
    Kunjungan data, {
    required bool firstTime,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      emit(AddKunjunganFailure('User belum login'));
      return;
    }

    emit(AddKunjunganLoading());

    try {
      final batch = FirebaseFirestore.instance.batch();

      // 1. Inisialisasi ID dan Reference
      final id = data.id.isNotEmpty
          ? data.id
          : FirebaseFirestore.instance.collection('kunjungan').doc().id;

      final docRefKunjungan = FirebaseFirestore.instance
          .collection('kunjungan')
          .doc(id);
      final docRefKehamilan = FirebaseFirestore.instance
          .collection('kehamilan')
          .doc(data.idKehamilan);
      final docRefBumil = FirebaseFirestore.instance
          .collection('bumil')
          .doc(data.idBumil);

      // 2. Persiapan Data Kunjungan
      final Map<String, dynamic> kunjungan = {
        'bb': data.bb,
        'tb': data.tb,
        'created_at': data.createdAt,
        'keluhan': data.keluhan,
        'lila': data.lila,
        'lp': data.lp,
        'planning': data.planning,
        'status': data.status,
        'td': data.td,
        'tfu': data.tfu,
        'uk': data.uk,
        'terapi': data.terapi,
        'id_bidan': user.uid,
        'id_kehamilan': data.idKehamilan,
        'id_bumil': data.idBumil,
        'next_sf': data.nextSf,
        'periksa_usg': data.periksaUsg,
      };

      // 3. Logika Bisnis & Risiko
      var kehamilan = selectedKehamilanCubit.state;
      List<String> resti = [];

      if (firstTime) {
        kunjungan['tgl_periksa_usg'] =
            selectedBumilCubit.state?.latestKehamilan?.tglPeriksaUsg;
        kunjungan['kontrol_dokter'] =
            selectedBumilCubit.state?.latestKehamilan?.kontrolDokter;

        var bumil = selectedBumilCubit.state;
        kehamilan ??= bumil?.latestKehamilan;

        if (bumil != null) {
          final ageRisk = bumil.age < 20 || bumil.age > 35;
          final gravidaRisk = (bumil.statisticRiwayat['gravida'] ?? 0) >= 4;
          final jarakRisk =
              (bumil.statisticRiwayat['gravida'] ?? 0) > 0 &&
              _cekJarakKehamilan(bumil.latestRiwayat?.tglLahir);

          kunjungan['k1_4t'] = ageRisk || gravidaRisk || jarakRisk;

          // Analisis Resti berdasarkan input kunjungan saat ini
          if (data.td != null && data.td!.contains('/')) {
            List<String> parts = data.td!.split("/");
            if (parts.length == 2) {
              int sistolik = int.tryParse(parts[0]) ?? 0;
              int diastolik = int.tryParse(parts[1]) ?? 0;
              if (sistolik >= 140 || diastolik >= 90) {
                resti.add('Hipertensi dalam kehamilan ${data.td} mmHg');
              }
            }
          }
          if (data.lila != null) {
            final lilaValue = num.tryParse(data.lila!) ?? 0;
            if (lilaValue < 23.5 && lilaValue > 0) {
              resti.add('Kekurangan Energi Kronis (lila: ${data.lila} cm)');
            }
          }
        }
      }

      // 4. Masukkan operasi Kunjungan ke Batch
      batch.set(docRefKunjungan, kunjungan, SetOptions(merge: true));

      // 5. Update Dokumen Kehamilan
      final Map<String, dynamic> updatedKehamilan = {
        'sf_count': (kehamilan?.sfCount ?? 0) + (data.nextSf ?? 0),
        'kunjungan': true,
      };
      if (firstTime && resti.isNotEmpty) {
        updatedKehamilan['resti'] = FieldValue.arrayUnion(resti);
      }
      batch.update(docRefKehamilan, updatedKehamilan);

      // 6. Update Dokumen Bumil
      // Kita gunakan dot notation untuk update field spesifik di dalam Map latest_kehamilan
      final Map<String, dynamic> bumilUpdate = {
        'latest_kehamilan_kunjungan': true,
        'latest_kunjungan_id': id,
        'latest_kunjungan': kunjungan,
        'latest_kehamilan.kunjungan': true,
        'latest_kehamilan.sf_count':
            (kehamilan?.sfCount ?? 0) + (data.nextSf ?? 0),
      };
      if (firstTime && resti.isNotEmpty) {
        // Sinkronisasi field resti di objek bumil jika ada perubahan
        bumilUpdate['latest_kehamilan_resti'] = FieldValue.arrayUnion(resti);
        bumilUpdate['latest_kehamilan.resti'] = FieldValue.arrayUnion(resti);
      }
      batch.update(docRefBumil, bumilUpdate);

      // 7. COMMIT BATCH (Tersimpan di local cache dulu jika offline)
      batch.commit();

      selectedKunjunganCubit.selectKunjungan(
        Kunjungan.fromFirestore(kunjungan, id: id),
      );

      if (kehamilan != null) {
        kehamilan.sfCount = (kehamilan.sfCount ?? 0) + (data.nextSf ?? 0);
        kehamilan.kunjungan = true;
        if (firstTime && resti.isNotEmpty) {
          kehamilan.resti = resti;
        }
        selectedKehamilanCubit.selectKehamilan(kehamilan);
      }

      var bumil = selectedBumilCubit.state;
      if (bumil != null) {
        bumil.latestKehamilanKunjungan = true;
        bumil.latestKunjunganId = id;
        bumil.latestKunjungan = selectedKunjunganCubit.state;
        bumil.latestKehamilanResti = resti;
        bumil.latestKehamilan = kehamilan;
        selectedBumilCubit.selectBumil(bumil);
      }

      emit(AddKunjunganSuccess());
    } catch (e) {
      emit(
        AddKunjunganFailure(
          e is Exception
              ? e.toString().replaceAll('Exception: ', '')
              : 'Terjadi kesalahan. Mohon coba kembali.',
        ),
      );
    }
  }

  void setInitial() => emit(AddKunjunganInitial());

  bool _cekJarakKehamilan(DateTime? tglLahirAnak) {
    if (tglLahirAnak == null) return false;

    final sekarang = DateTime.now();

    // Hitung selisih total bulan
    int selisihBulan =
        (sekarang.year - tglLahirAnak.year) * 12 +
        (sekarang.month - tglLahirAnak.month);

    // Koreksi jika tanggal hari sekarang < tanggal lahir anak (belum genap sebulan)
    if (sekarang.day < tglLahirAnak.day) {
      selisihBulan -= 1;
    }

    // risiko jika selisih < 24 bulan
    return selisihBulan < 24;
  }
}
