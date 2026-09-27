import 'package:flutter/material.dart';

class ThreePane extends StatefulWidget {
  const ThreePane({super.key});

  @override
  State<ThreePane> createState() => _ThreePaneState();
}

class _ThreePaneState extends State<ThreePane> {
  double leftWidth = 200;
  double middleWidth = 600;
  double rightWidth = 300;

  static const double handleWidth = 4;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 左
        SizedBox(
          width: leftWidth,
          child: Container(color: Colors.blue),
        ),

        // 左边分割线
        _ResizeHandle(
          onDrag: (dx) {
            setState(() {
              final newLeft = leftWidth + dx;
              final newMiddle = middleWidth - dx;

              if (newLeft >= 100 && newMiddle >= 200) {
                leftWidth = newLeft;
                middleWidth = newMiddle;
              }
            });
          },
        ),

        // 中
        SizedBox(
          width: middleWidth,
          child: Container(color: Colors.green),
        ),

        // 右边分割线
        _ResizeHandle(
          onDrag: (dx) {
            setState(() {
              final newMiddle = middleWidth + dx;
              final newRight = rightWidth - dx;

              if (newMiddle >= 200 && newRight >= 100) {
                middleWidth = newMiddle;
                rightWidth = newRight;
              }
            });
          },
        ),

        // 右
        SizedBox(
          width: rightWidth,
          child: Container(color: Colors.red),
        ),
      ],
    );
  }
}

class _ResizeHandle extends StatelessWidget {
  final ValueChanged<double> onDrag;

  const _ResizeHandle({required this.onDrag});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragUpdate: (details) {
          onDrag(details.delta.dx);
        },
        child: const SizedBox(width: _ThreePaneState.handleWidth),
      ),
    );
  }
}

class DialogBox {}
