import 'package:ebidan/state_management/banner/cubit/get_banner_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BannerHome extends StatelessWidget {
  final VoidCallback onTap;
  final VoidCallback onClose;

  const BannerHome({super.key, required this.onTap, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<GetBannerCubit, GetBannerState>(
      builder: (context, state) {
        if (state is GetBannerNoBanner) {
          return const SizedBox.shrink();
        } else if (state.title.isEmpty) {
          return const SizedBox.shrink();
        } else {
          return InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primaryContainer,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  // DECORATIVE ICON (background)
                  Positioned(
                    right: -10,
                    top: -10,
                    child: Icon(
                      Icons.verified_user,
                      size: 110,
                      color: Colors.white.withOpacity(0.15),
                    ),
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // HEADER ROW
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(
                            Icons.campaign,
                            color: Colors.white,
                            size: 28,
                          ),
                          GestureDetector(
                            onTap: onClose,
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // TITLE
                      Text(
                        state.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // SUBTITLE
                      Text(
                        normalizeNewLine(state.subtitle),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // CTA
                      if (state.content != null) ...[
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Baca Selengkapnya',
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  String normalizeNewLine(String text) {
    return text.replaceAll(r'\n', '\n');
  }
}
