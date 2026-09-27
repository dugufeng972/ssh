import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mssh/src/floatingbox.dart';
import 'package:mssh/src/vecicon.dart';

class Mytest extends StatefulWidget {
  const Mytest({super.key});

  @override
  State<Mytest> createState() => _MytestState();
}

class _MytestState extends State<Mytest> {
  int ac = -1;
  final List<String> _iconPathList = [
    'assets/svg/filetree/arrow-left-outline.svg',
    'assets/svg/filetree/folder-up-outline.svg',
    'assets/svg/filetree/folder-down-outline.svg',
    'assets/svg/filetree/folder-add-outline.svg',
    'assets/svg/filetree/file-plus-outline.svg',
    'assets/svg/filetree/refresh-outline.svg',
  ];
  final FloatingBoxController _floatingBoxController = FloatingBoxController();
  Timer? _timer;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 100,
      itemExtent: 30,
      itemBuilder: (context, index) {
        print('====$index=====');
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          onHover: (event) {
            if (_timer?.isActive ?? false) return;
            _floatingBoxController.hideFloatingBox();
            _floatingBoxController.showFloatingBox(
              context,
              position: Offset(event.position.dx + 10, event.position.dy + 10),
              clickToClose: false,
              customChild: Text('$index'),
            );
            _timer = Timer(
              const Duration(milliseconds: 30),
              () => _timer = null,
            );
          },
          child: GestureDetector(
            onTap: () {
              setState(() {
                ac = index;
              });
            },
            child: Container(
              color: ac == index
                  ? Colors.red
                  : index % 2 == 0
                  ? Colors.amber
                  : Colors.blue,
              child: Row(
                children: [
                  VecIcon(
                    assetPath: _iconPathList[index % _iconPathList.length],
                  ),
                  Text('文字-$index'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
