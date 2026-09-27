import 'package:flutter/material.dart';
import 'package:mssh/src/appstate.dart';
import 'package:provider/provider.dart';

class Mainview extends StatefulWidget {
  const Mainview({super.key});

  @override
  State<Mainview> createState() => _MainviewState();
}

class _MainviewState extends State<Mainview> {
  bool _isMove = false;
  int _isOnBtn = -1;
  @override
  Widget build(BuildContext context) {
    // 标签页列表
    final tags = context.select<TagItemState, List<SessionItem>>(
      (value) => value.tags,
    );
    // 当前活动的标签页
    int activeTagNum = context.select<TagItemState, int>(
      (value) => value.activeTagNum,
    );
    final tagItemState = context.read<TagItemState>();
    final appThemeState = context.read<AppThemeState>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      // 终端区域
      children: [
        // 标签页区
        Container(
          width: double.infinity,
          foregroundDecoration: BoxDecoration(
            border: BoxBorder.fromLTRB(
              bottom: BorderSide(color: appThemeState.borderDefault, width: 1),
            ),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(tags.length, (index) {
                return MouseRegion(
                  cursor: SystemMouseCursors.click,
                  onEnter: (event) {},
                  child: GestureDetector(
                    behavior: HitTestBehavior.deferToChild,
                    //TODO 这个是想做标签页拖动功能，没有完成
                    onPanUpdate: (details) {
                      _isMove = true;
                    },
                    onPanEnd: (details) {
                      if (_isMove) {
                        _isMove = false;
                      } else {
                        tagItemState.activeTag(index);
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.only(right: 5, left: 5),
                      alignment: AlignmentGeometry.center,
                      decoration: BoxDecoration(
                        color: index == activeTagNum
                            ? appThemeState.bgSecondary
                            : appThemeState.bgBase,
                        border: BoxBorder.fromLTRB(
                          bottom: index != activeTagNum
                              ? BorderSide(
                                  color: appThemeState.borderDefault,
                                  width: 1,
                                )
                              : BorderSide.none,
                          left: BorderSide.none,
                          right: BorderSide(
                            color: appThemeState.borderDefault,
                            width: 1,
                          ),
                          top: index == activeTagNum
                              ? BorderSide(
                                  color: appThemeState.primaryActive,
                                  width: 1,
                                  style: BorderStyle.solid,
                                )
                              : BorderSide.none,
                        ),
                      ),
                      height: 30,
                      child: Stack(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                tags[index].name,
                                // 'dd',
                                style: TextStyle(
                                  color: appThemeState.textPrimary,
                                ),
                              ),
                              if (index != 0)
                                MouseRegion(
                                  onEnter: (event) =>
                                      setState(() => _isOnBtn = index),
                                  onExit: (event) =>
                                      setState(() => _isOnBtn = -1),

                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      tagItemState.delView(index);
                                    },
                                    child: Container(
                                      height: 20,
                                      width: 20,
                                      // color: Colors.brown,
                                      margin: EdgeInsets.only(left: 5, top: 3),
                                      decoration: BoxDecoration(
                                        color: _isOnBtn == index
                                            ? Colors.red
                                            : Colors.amber,
                                      ),
                                      child: Icon(Icons.close, size: 14),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        // 终端显示输入区
        Expanded(
          child: IndexedStack(
            index: activeTagNum,
            children: tags.map((el) => el.widget).toList(),
          ),
        ),
      ],
    );
  }
}
