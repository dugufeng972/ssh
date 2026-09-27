import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mssh/src/appstate.dart';
import 'package:mssh/src/floatingbox.dart';
import 'package:mssh/src/utils.dart';
import 'package:provider/provider.dart';

class Quickconnect extends StatefulWidget {
  const Quickconnect({super.key});

  @override
  State<Quickconnect> createState() => _QuickconnectState();
}

class _QuickconnectState extends State<Quickconnect> {
  final _passwdController = TextEditingController();
  final _floatingBoxController = FloatingBoxController();
  @override
  Widget build(BuildContext context) {
    final quickConnectList = context
        .select<QuickConnectState, List<QuickConnect>>(
          (value) => value.quickConnectList,
        );
    final tagitemState = context.read<TagItemState>();
    final appThemeState = context.read<AppThemeState>();
    return ListView.builder(
      itemCount: quickConnectList.length,
      itemExtent: 30,
      itemBuilder: (con, index) {
        final info = quickConnectList[index];
        final widget = Row(
          children: [
            Icon(Icons.folder, color: const Color.fromARGB(255, 234, 201, 102)),
            Expanded(
              child: Text(
                ' ${info.username}@${info.hostname}',
                style: TextStyle(color: appThemeState.textPrimary),
                maxLines: 1,
              ),
            ),
          ],
        );
        final floatingBox = Column(
          children: [
            Text(
              info.alis != ''
                  ? info.alis
                  : '${info.hostname}(${info.username})',
            ),
            SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Type: ${info.connectType}'),
                Text('Host: ${info.hostname}'),
                Text('User: ${info.username}'),
                Text('Port: ${info.port}'),
              ],
            ),
          ],
        );
        return QuickConnectItem(
          index: index,
          widget: widget,
          floatingBox: floatingBox,
          doubleTapHandler: () {
            _floatingBoxController.showFloatingBox(
              context,
              customChild: Row(
                children: [
                  Text('密码: '),
                  SizedBox(
                    width: 200,
                    height: 30,
                    child: TextField(
                      controller: _passwdController,
                      decoration: InputDecoration(
                        hintText: '请输入密码',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                      textAlignVertical: TextAlignVertical.center,
                    ),
                  ),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () async {
                        await SSHSessionUtils.createClient(
                          hostname: info.hostname,
                          username: info.username,
                          passwd: _passwdController.text,
                          tagItemState: tagitemState,
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.only(left: 10),
                        padding: EdgeInsets.only(left: 5, right: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          color: Colors.lightBlue,
                        ),
                        child: Text(
                          '连接',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ignore: must_be_immutable
class QuickConnectItem extends StatefulWidget {
  final int index;
  final Widget widget;
  final Widget floatingBox;
  void Function()? doubleTapHandler;
  QuickConnectItem({
    super.key,
    required this.index,
    required this.widget,
    required this.floatingBox,
    this.doubleTapHandler,
  });

  @override
  State<QuickConnectItem> createState() => _QuickConnectItemState();
}

class _QuickConnectItemState extends State<QuickConnectItem> {
  bool _isHover = false;
  final FloatingBoxController _floatingBoxController = FloatingBoxController();

  @override
  Widget build(BuildContext context) {
    final appThemeState = context.read<AppThemeState>();
    return Container(
      // width: 100,
      color: _isHover ? appThemeState.bgHover : null,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (event) {
          _floatingBoxController.showFloatingBox(
            context,
            position: Offset(event.position.dx + 10, event.position.dy + 10),
            clickToClose: false,
            customChild: widget.floatingBox,
          );
          setState(() {
            _isHover = true;
          });
        },
        onExit: (event) {
          _floatingBoxController.hideFloatingBox();
          setState(() {
            _isHover = false;
          });
        },
        child: GestureDetector(
          onDoubleTap: () {
            widget.doubleTapHandler?.call();
          },
          child: widget.widget,
        ),
      ),
    );
  }
}
