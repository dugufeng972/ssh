import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mssh/src/appstate.dart';
import 'package:mssh/src/floatingbox.dart';
import 'package:mssh/src/utils.dart';
import 'package:provider/provider.dart';

class Homeview extends StatefulWidget {
  const Homeview({super.key});

  @override
  State<Homeview> createState() => _HomeviewState();
}

class _HomeviewState extends State<Homeview> {
  final FloatingBoxController _floatingBoxController = FloatingBoxController();

  @override
  Widget build(BuildContext context) {
    final appThemeState = context.read<AppThemeState>();
    return MouseRegion(
      child: Center(
        child: Column(
          children: [
            Text(
              "这是home组件",
              style: TextStyle(color: appThemeState.textPrimary),
            ),
            TextButton(
              onPressed: () {
                if (_floatingBoxController.isShowing()) {
                  // print("关闭");
                  _floatingBoxController.hideFloatingBox();
                } else {
                  // print("打开");
                  _floatingBoxController.showFloatingBox(
                    context,
                    clickToClose: false,
                    customChild: _loginWidget(context),
                  );
                }
              },
              child: Text('登录'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _loginWidget(BuildContext context) {
    // final appstate = context.read<Appstate>();
    final quickConnectState = context.read<QuickConnectState>();
    final tagitemState = context.read<TagItemState>();
    final TextEditingController hostnameInput = TextEditingController();
    final TextEditingController usernameInput = TextEditingController();
    final TextEditingController portInput = TextEditingController();
    final TextEditingController passwdInput = TextEditingController();
    return Column(
      spacing: 10,
      children: [
        SizedBox(
          width: 230,
          height: 30,
          child: Row(
            children: [
              Padding(padding: EdgeInsets.only(right: 5), child: Text("主机名")),
              Expanded(
                child: TextField(
                  controller: hostnameInput,
                  decoration: InputDecoration(
                    hintText: "请输入主机名",
                    border: OutlineInputBorder(borderRadius: BorderRadius.zero),
                    contentPadding: EdgeInsets.zero,
                  ),
                  textAlignVertical: TextAlignVertical.center,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 230,
          height: 30,
          child: Row(
            children: [
              Padding(padding: EdgeInsets.only(right: 5), child: Text("用户名")),
              Expanded(
                child: TextField(
                  controller: usernameInput,
                  decoration: InputDecoration(
                    hintText: "请输入用户名",
                    border: OutlineInputBorder(borderRadius: BorderRadius.zero),
                    contentPadding: EdgeInsets.zero,
                  ),
                  textAlignVertical: TextAlignVertical.center,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 230,
          height: 30,
          child: Row(
            children: [
              Padding(padding: EdgeInsets.only(right: 5), child: Text("密码")),
              Expanded(
                child: TextField(
                  controller: passwdInput,
                  decoration: InputDecoration(
                    hintText: "请输入密码",
                    border: OutlineInputBorder(borderRadius: BorderRadius.zero),
                    contentPadding: EdgeInsets.zero,
                  ),
                  textAlignVertical: TextAlignVertical.center,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 230,
          height: 30,
          child: Row(
            children: [
              Padding(padding: EdgeInsets.only(right: 5), child: Text("端口")),
              Expanded(
                child: TextField(
                  controller: portInput,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    hintText: "请输入端口号",
                    border: OutlineInputBorder(borderRadius: BorderRadius.zero),
                    contentPadding: EdgeInsets.zero,
                  ),
                  textAlignVertical: TextAlignVertical.center,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 230,
          height: 30,
          child: Row(
            children: [
              TextButton(
                onPressed: () {
                  // print("关闭");
                  _floatingBoxController.hideFloatingBox();
                },
                child: Text("关闭"),
              ),
              SizedBox(width: 10),
              TextButton(
                onPressed: () async {
                  if (hostnameInput.text == '' ||
                      passwdInput.text == '' ||
                      usernameInput.text == '') {
                    // TODO 这里应该有个提示
                    print("空字符串");
                  } else {
                    try {
                      int port = int.parse(portInput.text);
                      await SSHSessionUtils.createClient(
                        hostname: hostnameInput.text,
                        username: usernameInput.text,
                        passwd: passwdInput.text,
                        port: port,
                        tagItemState: tagitemState,
                      );
                      quickConnectState.addQuickConnect(
                        hostnameInput.text,
                        usernameInput.text,
                        port: port,
                      );
                      // print("连接成功");
                      _floatingBoxController.hideFloatingBox();
                    } catch (e) {
                      print(e);
                    }
                  }
                },
                child: Text("连接"),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
