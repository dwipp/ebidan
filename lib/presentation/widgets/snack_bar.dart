import 'package:flutter/material.dart';

enum SnackbarType { success, error, general }

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
    if (overlay == null) return;

    final color = switch (type) {
      SnackbarType.error => Colors.red,
      SnackbarType.success => Colors.green,
      SnackbarType.general => Colors.grey.shade800,
    };

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return _AnimatedSnackbar(
          message: message,
          color: color,
          onDismissed: () {
            // Hapus overlay setelah animasi selesai
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
  final VoidCallback onDismissed;
  final Duration duration;

  const _AnimatedSnackbar({
    required this.message,
    required this.color,
    required this.onDismissed,
    this.duration = const Duration(seconds: 3),
  });

  @override
  _AnimatedSnackbarState createState() => _AnimatedSnackbarState();
}

class _AnimatedSnackbarState extends State<_AnimatedSnackbar> with SingleTickerProviderStateMixin {
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
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _controller.forward();

    // Atur timer untuk memulai animasi kembali (slide-out)
    Future.delayed(widget.duration).then((_) {
      _controller.reverse().then((_) {
        // Panggil callback setelah animasi selesai
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
              top: MediaQuery.of(context).padding.top + 14,
            ),
            child: Center(
              child: Text(
                widget.message,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}