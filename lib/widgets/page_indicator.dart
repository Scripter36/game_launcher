import 'package:flutter/material.dart';

class PageIndicator extends StatelessWidget {
  PageIndicator({
    required this.pageCount,
    required this.currentPage,
    Function(int)? onPageSelected,
    Key? key,
  })  : onPageSelected = onPageSelected ?? ((_) {}),
        super(key: key);

  final int pageCount;
  final int currentPage;
  final Function(int) onPageSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 12,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(pageCount, (index) {
          final isCurrent = index == currentPage;
          return GestureDetector(
            onTap: () => onPageSelected(index),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: AnimatedContainer(
                duration: Durations.medium1,
                width: isCurrent ? 12 : 8,
                height: isCurrent ? 12 : 8,
                decoration: BoxDecoration(
                  color: isCurrent ? Colors.white.withOpacity(0.6) : Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
