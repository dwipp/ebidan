import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AnimatedDataCard extends StatefulWidget {
  final String label;
  final int value;
  final bool isTotal;
  final Color? backgroundColor;
  final IconData? icon;

  const AnimatedDataCard({
    super.key,
    required this.label,
    required this.value,
    this.isTotal = false,
    this.backgroundColor,
    this.icon,
  });

  @override
  State<AnimatedDataCard> createState() => _AnimatedDataCardState();
}

class _AnimatedDataCardState extends State<AnimatedDataCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _animation =
        IntTween(begin: 0, end: widget.value).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOut),
        )..addListener(() {
          setState(() {});
        });

    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedDataCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animation = IntTween(
        begin: 0,
        end: widget.value,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(from: 0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color:
              widget.backgroundColor ??
              (widget.isTotal ? Colors.blue.shade100 : Colors.white),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: widget.isTotal ? 8 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (widget.icon != null) ...[
              Icon(widget.icon, size: 20, color: Colors.grey[700]),
              const SizedBox(height: 4),
            ],
            FittedBox(
              fit: BoxFit.scaleDown,
              child: DefaultTextStyle(
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: widget.isTotal ? Colors.blue : Colors.grey[700],
                  fontWeight: widget.isTotal
                      ? FontWeight.bold
                      : FontWeight.w500,
                ),
                child: Text(widget.label),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              NumberFormat.compact().format(_animation.value),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: widget.isTotal ? Colors.blue : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
