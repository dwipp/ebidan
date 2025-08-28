import 'package:flutter/material.dart';

class PageHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool hideBackButton;

  const PageHeader({
    Key? key,
    required this.title,
    this.actions,
    this.hideBackButton = false,
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
      // centerTitle: centerTitle,
      actions: actions,
      automaticallyImplyLeading: !hideBackButton,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
