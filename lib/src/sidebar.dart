import 'package:flutter/material.dart';
import 'package:mssh/src/appstate.dart';
import 'package:mssh/src/vecIcon.dart';
import 'package:provider/provider.dart';

class Sidebar extends StatefulWidget {
  final String leftOrRight;
  const Sidebar({super.key, required this.leftOrRight});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  @override
  Widget build(BuildContext context) {
    final appThemeState = context.read<AppThemeState>();
    List<String> itemList = [];
    if (widget.leftOrRight == 'left') {
      itemList = context.select<SidebarState, List<String>>(
        (val) => val.leftList.keys.toList(),
      );
    } else {
      itemList = context.select<SidebarState, List<String>>(
        (val) => val.rightList.keys.toList(),
      );
    }
    return Container(
      decoration: BoxDecoration(
        border: widget.leftOrRight == 'left'
            ? Border(
                right: BorderSide(color: appThemeState.borderDefault, width: 1),
              )
            : Border(
                left: BorderSide(color: appThemeState.borderDefault, width: 1),
              ),
      ),
      child: Column(
        children: itemList
            .map(
              (el) => SideItem(
                iconPath: el,
                size: 40,
                leftOrRight: widget.leftOrRight,
              ),
            )
            .toList(),
      ),
    );
  }
}

// ignore: must_be_immutable
class SideItem extends StatefulWidget {
  final String iconPath;
  Color? color;
  double size;
  String leftOrRight;
  SideItem({
    super.key,
    required this.iconPath,
    this.color,
    required this.size,
    required this.leftOrRight,
  });

  @override
  State<SideItem> createState() => _SideItemState();
}

class _SideItemState extends State<SideItem> {
  bool _isHover = false;
  @override
  Widget build(BuildContext context) {
    String activeKey = '';
    if (widget.leftOrRight == 'left') {
      activeKey = context.select<SidebarState, String>(
        (val) => val.leftActiveKey,
      );
    } else {
      activeKey = context.select<SidebarState, String>(
        (val) => val.rightActiveKey,
      );
    }
    final sidebarState = context.read<SidebarState>();
    final appThemeState = context.read<AppThemeState>();

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (event) => setState(() => _isHover = true),
      onExit: (event) => setState(() => _isHover = false),
      child: GestureDetector(
        onTap: () {
          if (widget.leftOrRight == 'left') {
            if (widget.iconPath == activeKey) {
              sidebarState.setLeftActiveKey('');
            } else {
              sidebarState.setLeftActiveKey(widget.iconPath);
            }
          } else {
            if (widget.iconPath == activeKey) {
              sidebarState.setRightActiveKey('');
            } else {
              sidebarState.setRightActiveKey(widget.iconPath);
            }
          }
        },
        child: Container(
          width: widget.size,
          height: widget.size,
          color: _isHover ? appThemeState.bgHover : null,
          child: Padding(
            padding: EdgeInsetsGeometry.all(8),
            child: VecIcon(
              assetPath: widget.iconPath,
              size: 24,
              color: widget.iconPath == activeKey
                  ? Color(0xFFCED0D6)
                  : Color(0xFF6C707E),
            ),
          ),
        ),
      ),
    );
  }
}
