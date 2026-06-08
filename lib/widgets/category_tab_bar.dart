import 'package:flutter/material.dart';

class CategoryTabBar extends StatelessWidget {
  const CategoryTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTap,
  });

  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          return GestureDetector(
            onTap: () => onTap(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF8B5CF6)
                    : const Color(0xFFF3F3F5),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                tabs[index],
                style: TextStyle(
                  fontSize: 13,
                  color: isSelected ? Colors.white : const Color(0xFF666666),
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class EmptyFollowingPlaceholder extends StatelessWidget {
  const EmptyFollowingPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          const Text(
            '暂无关注',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF999999),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '去关注感兴趣的摄影师吧',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFFCCCCCC),
            ),
          ),
        ],
      ),
    );
  }
}
