import 'package:flutter/material.dart';
import 'package:mssh/src/appstate.dart';
import 'package:provider/provider.dart';

class FloatingBox extends StatelessWidget {
  final Widget? customChild;
  const FloatingBox({super.key, this.customChild});

  @override
  Widget build(BuildContext context) {
    final appThemeState = context.read<AppThemeState>();
    return Material(
      type: MaterialType.transparency,
      child: Container(
        decoration: BoxDecoration(
          color: appThemeState.bgElevated,
          // borderRadius: BorderRadius.circular(12),
          border: Border.all(
            width: 1,
            style: BorderStyle.solid,
            color: appThemeState.borderDefault,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(50),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: customChild ?? Column(children: [Text("ddd"), Text("ddd")]),
      ),
    );
  }
}

class FloatingBoxController {
  OverlayEntry? _overlayEntry;

  bool isShowing() {
    if (_overlayEntry != null) {
      return true;
    }
    return false;
  }

  // 创建一个全屏的界面，来实现点击空白处关闭弹窗
  Widget _renderByCondition(bool flag) {
    if (flag) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          hideFloatingBox();
        },
        child: SizedBox.expand(),
      );
    } else {
      return SizedBox.shrink();
    }
  }

  // 显示
  void showFloatingBox(
    BuildContext context, {
    Offset? position,
    bool clickToClose = true,
    Widget? customChild,
  }) {
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(child: _renderByCondition(clickToClose)),
            Positioned(
              left: position?.dx ?? 100,
              top: position?.dy ?? 100,
              child: FloatingBox(customChild: customChild),
            ),
          ],
        );
      },
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  // 更新悬浮窗位置
  // void updatePosition(Offset position) {
  //   _overlayEntry?.remove();
  // }

  // 关闭悬浮窗
  void hideFloatingBox() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  /// dispose时调用
  void dispose() {
    hideFloatingBox();
  }
}
