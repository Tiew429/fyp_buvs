import 'package:flutter/material.dart';

class ScrollableWidget extends StatelessWidget {
  final Widget child;
  final bool hasBottomNavigationBar;

  const ScrollableWidget({
    super.key,
    required this.child,
    this.hasBottomNavigationBar = false,
  });

  @override
  Widget build(BuildContext context) {
    // 计算内容区域的高度
    final screenHeight = MediaQuery.of(context).size.height;
    final contentHeight = hasBottomNavigationBar
        ? screenHeight - kBottomNavigationBarHeight - 30
        : screenHeight - 60;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        // 使用固定高度而不是约束，避免无限高度约束
        height: contentHeight,
        padding: const EdgeInsets.all(20),
        child: child,
      ),
    );
  }
}
