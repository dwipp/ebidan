import 'package:ebidan/state_management/banner/cubit/get_banner_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

class BannerContentScreen extends StatelessWidget {
  const BannerContentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: BlocBuilder<GetBannerCubit, GetBannerState>(
          builder: (context, state) {
            return Markdown(
              data: state.content,
              padding: const EdgeInsets.all(16),
              styleSheet: MarkdownStyleSheet(
                h1: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                h2: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                p: const TextStyle(fontSize: 14, height: 1.6),
                listBullet: const TextStyle(fontSize: 14),
              ),
            );
          },
        ),
      ),
    );
  }
}
