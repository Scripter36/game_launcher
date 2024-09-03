import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AutoplayIndicator extends HookWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;

  const AutoplayIndicator({required this.value, required this.onChanged, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      splashFactory: InkRipple.splashFactory,
      borderRadius: BorderRadius.circular(8),
      child: Ink(
        color: Colors.black.withOpacity(0.6),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: AnimatedSwitcher(
                duration: Durations.short3,
                child: value ? PhosphorIcon(PhosphorIcons.check(PhosphorIconsStyle.bold), size: 12) : null,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'AUTOPLAY',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
