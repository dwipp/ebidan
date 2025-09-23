import 'package:ebidan/common/utility/app_colors.dart';
import 'package:ebidan/state_management/general/cubit/connectivity_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PageHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool hideBackButton;
  final bool hideNetworkStatus;

  const PageHeader({
    Key? key,
    required this.title,
    this.actions,
    this.hideBackButton = false,
    this.hideNetworkStatus = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: hideBackButton
          ? null
          : GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).maybePop();
                }
              },
              onLongPress: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Icon(Icons.arrow_back),
            ),
      title: Text(title),
      actions: [
        if (!(hideNetworkStatus))
          // indikator network
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: BlocBuilder<ConnectivityCubit, ConnectivityState>(
              builder: (context, state) {
                final connected = state.connected;
                final onlyNetwork = actions == null || actions!.isEmpty;
                return Row(
                  children: [
                    Icon(
                      connected ? Icons.wifi : Icons.wifi_off,
                      color: connected
                          ? context.themeColors.tertiary
                          : context.themeColors.error,
                    ),
                    if (onlyNetwork) const SizedBox(width: 12),
                  ],
                );
              },
            ),
          ),
        ...?actions,
      ],
      automaticallyImplyLeading: !hideBackButton,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
