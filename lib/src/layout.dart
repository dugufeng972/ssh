// ignore_for_file: prefer_final_fields, avoid_print

import 'package:flutter/material.dart';
import 'package:mssh/src/appstate.dart';
import 'package:mssh/src/mainview.dart';
import 'package:mssh/src/sidebar.dart';
import 'package:provider/provider.dart';
import 'package:resizable_splitter/resizable_splitter.dart';

enum ViewPage { noView, fileView, connectionView }

class Layout extends StatefulWidget {
  const Layout({super.key});

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  ViewPage _openOutput = ViewPage.noView;
  final mainViewKey = GlobalKey();

  Widget buildByCondition(BuildContext context) {
    final leftSideBarView = context.select<SidebarState, Map<String, Widget>>(
      (val) => val.leftList,
    );
    final leftActiveKey = context.select<SidebarState, String>(
      (val) => val.leftActiveKey,
    );
    final rightSideBarView = context.select<SidebarState, Map<String, Widget>>(
      (val) => val.rightList,
    );
    final rightActiveKey = context.select<SidebarState, String>(
      (val) => val.rightActiveKey,
    );
    final appThemeState = context.read<AppThemeState>();
    Widget result = Container(
      color: appThemeState.bgPrimary,
      child: Mainview(key: mainViewKey),
    );
    if (rightActiveKey != '') {
      result = ResizableSplitter(
        divider: SplitterDividerStyle(
          interactiveExtent: 8,
          thickness: 1,
          color: WidgetStateProperty.resolveWith((states) {
            // 根据状态设置不同颜色
            if (states.contains(WidgetState.dragged)) {
              return appThemeState.primary;
            }
            if (states.contains(WidgetState.hovered)) {
              return appThemeState.primaryHover;
            }
            return appThemeState.borderDefault; // 默认颜色
          }),
        ),
        initialPosition: const SplitterPosition.endPixels(200),
        startConstraints: const SplitterPaneConstraints(minExtent: 80),
        constraintPolicy: SplitterConstraintPolicy.favorStart,
        start: result,
        // 右侧边栏视图区域
        // 需要根据_openRight类型选择对应的组件
        end: Container(
          color: appThemeState.bgSecondary,
          child: rightSideBarView[rightActiveKey] ?? Container(),
        ),
      );
    }
    // 左侧边栏
    if (leftActiveKey != '') {
      result = ResizableSplitter(
        divider: SplitterDividerStyle(
          interactiveExtent: 8,
          thickness: 1,
          color: WidgetStateProperty.resolveWith((states) {
            // 根据状态设置不同颜色
            if (states.contains(WidgetState.dragged)) {
              return appThemeState.primary;
            }
            if (states.contains(WidgetState.hovered)) {
              return appThemeState.primaryHover;
            }
            return appThemeState.borderDefault; // 默认颜色
          }),
        ),
        initialPosition: const SplitterPosition.startPixels(150),
        endConstraints: const SplitterPaneConstraints(minExtent: 80),
        constraintPolicy: SplitterConstraintPolicy.favorEnd,
        // map返回值是可空的，当为空时应该换成提醒界面
        start: Container(
          color: appThemeState.bgSecondary,
          child: leftSideBarView[leftActiveKey] ?? Container(),
        ),
        // start: _map[_openLeft] ?? Container(),
        // 右侧边栏视图区域
        end: result,
      );
    }
    // 输出栏区域
    if (_openOutput != ViewPage.noView) {
      result = ResizableSplitter(
        axis: Axis.vertical,
        start: result,
        end: Container(height: 50, color: Colors.amber),
      );
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: [
          // 侧边栏和终端区域
          Expanded(
            child: Row(
              children: [
                // 左侧边栏按钮
                Sidebar(leftOrRight: 'left'),
                // 两边侧边栏之间的区域
                Expanded(child: buildByCondition(context)),
                // 右侧边栏按钮
                Sidebar(leftOrRight: 'right'),
              ],
            ),
          ),
          // 底部状态栏
          Container(
            width: double.infinity,
            height: 20,
            color: Colors.red,
            child: Row(
              children: [
                Container(
                  color: const Color.fromARGB(255, 7, 255, 61),
                  width: 50.0,
                  height: 20.0,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// class Msg {
//   Offset? globalPosition;
//   Size? size;
//   bool dragSideBarView;
//   Msg({this.globalPosition, this.size, required this.dragSideBarView});
// }

// class Data {
//   double dx;
//   Data({required this.dx});
// }
