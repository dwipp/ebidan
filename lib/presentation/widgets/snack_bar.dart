import 'package:ebidan/common/utility/app_colors.dart';
import 'package:ebidan/common/utility/remote_config_helper.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

enum SnackbarType { success, error, general, updateApp }

class Snackbar {
  static OverlayEntry? _overlayEntry;

  static void show(
    BuildContext context, {
    required String message,
    SnackbarType type = SnackbarType.general,
    Duration duration = const Duration(seconds: 3),
  }) {
    if (_overlayEntry != null) {
      return;
    }

    final overlay = Overlay.of(context);

    final color = switch (type) {
      SnackbarType.error => context.themeColors.error,
      SnackbarType.success => context.themeColors.tertiary,
      SnackbarType.updateApp => context.themeColors.secondary,
      SnackbarType.general => context.themeColors.darkGrey,
    };

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return _AnimatedSnackbar(
          message: message,
          color: color,
          type: type,
          onDismissed: () {
            if (_overlayEntry != null) {
              _overlayEntry!.remove();
              _overlayEntry = null;
            }
          },
        );
      },
    );

    overlay.insert(_overlayEntry!);
  }
}

class _AnimatedSnackbar extends StatefulWidget {
  final String message;
  final Color color;
  final SnackbarType type;
  final VoidCallback onDismissed;

  const _AnimatedSnackbar({
    required this.message,
    required this.color,
    required this.type,
    required this.onDismissed,
  });

  @override
  _AnimatedSnackbarState createState() => _AnimatedSnackbarState();
}

class _AnimatedSnackbarState extends State<_AnimatedSnackbar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  double _appBarHeight = 0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    Future.delayed(const Duration(seconds: 3)).then((_) {
      if (!mounted) return;
      _controller.reverse().then((_) {
        widget.onDismissed();
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    _appBarHeight = kToolbarHeight + statusBarHeight;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onUpdateAppPressed() async {
    final versionUrl = RemoteConfigHelper.versionUrl;
    final url = versionUrl.isNotEmpty
        ? versionUrl
        : 'https://play.google.com/store/apps/details?id=id.ebidan.aos';
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {}

    _controller.reverse().then((_) {
      widget.onDismissed();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _offsetAnimation,
        child: Material(
          color: Colors.transparent,
          child: Container(
            height: _appBarHeight,
            color: widget.color,
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: MediaQuery.of(context).padding.top,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.message,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
                if (widget.type == SnackbarType.updateApp)
                  TextButton(
                    onPressed: _onUpdateAppPressed,
                    style: TextButton.styleFrom(
                      side: const BorderSide(color: Colors.white),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                    ),
                    child: const Text(
                      'UPDATE',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
