import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

class TutorialStep {
  final GlobalKey targetKey;
  final String message;

  TutorialStep({required this.targetKey, required this.message});
}

class TutorialOverlay extends StatefulWidget {
  final List<TutorialStep> steps;
  final VoidCallback onComplete;

  const TutorialOverlay({
    super.key,
    required this.steps,
    required this.onComplete,
  });

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay> {
  int _currentStep = 0;
  Rect? _targetRect;

  @override
  void initState() {
    super.initState();
    _measureTarget();
  }

  void _measureTarget() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final rect = _calculateRect();
      if (rect != null) {
        setState(() => _targetRect = rect);
      } else {
        // Target not found, skip step
        _advance();
      }
    });
  }

  Rect? _calculateRect() {
    if (_currentStep >= widget.steps.length) return null;
    final key = widget.steps[_currentStep].targetKey;
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return null;
    final pos = renderBox.localToGlobal(Offset.zero);
    const padding = 6.0;
    return Rect.fromLTWH(
      pos.dx - padding,
      pos.dy - padding,
      renderBox.size.width + padding * 2,
      renderBox.size.height + padding * 2,
    );
  }

  void _advance() {
    if (_currentStep < widget.steps.length - 1) {
      _currentStep++;
      _targetRect = null;
      _measureTarget();
    } else {
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_targetRect == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final screen = MediaQuery.of(context).size;
    final step = widget.steps[_currentStep];
    final isLast = _currentStep == widget.steps.length - 1;

    // Decide tooltip position
    final targetCenterY = _targetRect!.center.dy;
    final showBelow = targetCenterY < screen.height * 0.5;

    return GestureDetector(
      onTap: _advance,
      behavior: HitTestBehavior.opaque,
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            // Dark overlay with spotlight
            Positioned.fill(
              child: CustomPaint(
                painter: _SpotlightPainter(targetRect: _targetRect!),
              ),
            ),

            // Spotlight border
            Positioned(
              left: _targetRect!.left,
              top: _targetRect!.top,
              child: IgnorePointer(
                child: Container(
                  width: _targetRect!.width,
                  height: _targetRect!.height,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ),

            // Tooltip card
            Positioned(
              left: 24,
              right: 24,
              top: showBelow ? _targetRect!.bottom + 20 : null,
              bottom: showBelow
                  ? null
                  : screen.height - _targetRect!.top + 20,
              child: _buildTooltip(context, step, l10n, isLast),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTooltip(
    BuildContext context,
    TutorialStep step,
    AppLocalizations l10n,
    bool isLast,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            step.message,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF1F2937),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Step dots
              Row(
                children: List.generate(
                  widget.steps.length,
                  (i) => Container(
                    width: i == _currentStep ? 20 : 8,
                    height: 8,
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: i == _currentStep
                          ? const Color(0xFF7C3AED)
                          : const Color(0xFFE0E0E0),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              if (!isLast)
                TextButton(
                  onPressed: () => widget.onComplete(),
                  child: Text(
                    l10n.tutorialSkip,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              const SizedBox(width: 4),
              ElevatedButton(
                onPressed: _advance,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(isLast ? l10n.tutorialDone : l10n.tutorialNext),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  final Rect targetRect;

  _SpotlightPainter({required this.targetRect});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.75);

    final fullPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final cutoutPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(targetRect, const Radius.circular(12)),
      );

    final path = Path.combine(PathOperation.difference, fullPath, cutoutPath);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SpotlightPainter oldDelegate) {
    return targetRect != oldDelegate.targetRect;
  }
}
