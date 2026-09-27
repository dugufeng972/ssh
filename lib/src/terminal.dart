// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:io';
// import 'dart:nativewrappers/_internal/vm/lib/async_patch.dart';

import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pty2/flutter_pty.dart';
import 'package:mssh/src/appstate.dart';
import 'package:provider/provider.dart';
import 'package:xterm2/xterm.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final terminal = Terminal(maxLines: 10000);

  final terminalController = TerminalController();

  late final Pty pty;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.endOfFrame.then((_) {
      if (mounted) _startPty();
    });
  }

  void _startPty() {
    pty = Pty.start(
      shell,
      columns: terminal.viewWidth,
      rows: terminal.viewHeight,
    );

    pty.output
        .cast<List<int>>()
        .transform(Utf8Decoder())
        .listen(terminal.write);

    pty.exitCode.then((code) {
      terminal.write('the process exited with exit code $code');
    });

    terminal.onOutput = (data) {
      pty.write(const Utf8Encoder().convert(data));
    };

    terminal.onResize = (w, h, pw, ph) {
      _timer?.cancel();
      _timer = Timer(Duration(milliseconds: 100), () {
        pty.resize(h, w, pixelWidth: pw, pixelHeight: ph);
      });
    };
    terminal.onCurrentDirectoryChange = (dir) {
      print("目录变化了");
      print(dir);
    };
  }

  @override
  Widget build(BuildContext context) {
    return TerminalView(
      terminal,
      controller: terminalController,
      autofocus: true,
      backgroundOpacity: 0.7,
      onSecondaryTapDown: (details, offset) async {
        final selection = terminalController.selection;
        if (selection != null) {
          final text = terminal.buffer.getText(selection);
          terminalController.clearSelection();
          await Clipboard.setData(ClipboardData(text: text));
        } else {
          final data = await Clipboard.getData('text/plain');
          final text = data?.text;
          if (text != null) {
            terminal.paste(text);
            terminal.onCurrentDirectoryChange;
          }
        }
      },
    );
  }
}

String get shell {
  if (Platform.isMacOS || Platform.isLinux) {
    return Platform.environment['SHELL'] ?? 'bash';
  }

  if (Platform.isWindows) {
    return 'powershell.exe';
  }

  return 'sh';
}

class SSHSessionTerminal extends StatefulWidget {
  final SSHClient client;
  const SSHSessionTerminal({super.key, required this.client});

  @override
  State<SSHSessionTerminal> createState() => _SSHSessionTerminalState();
}

class _SSHSessionTerminalState extends State<SSHSessionTerminal> {
  final terminal = Terminal(maxLines: 10000);
  final terminalController = TerminalController();
  late SSHSession session;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final tagItemState = context.read<TagItemState>();
    final fileTreeState = context.read<FiletreeState>();
    initTerminal(tagItemState, fileTreeState);
  }

  @override
  void dispose() {
    super.dispose();
    widget.client.close();
  }

  void initTerminal(
    TagItemState tagItemState,
    FiletreeState fileTreeState,
  ) async {
    try {
      session = await widget.client.shell(
        pty: SSHPtyConfig(
          width: terminal.viewWidth,
          height: terminal.viewHeight,
        ),
      );
      print("w:${terminal.viewWidth} h:${terminal.viewHeight}");
      terminal.onResize = (w, h, pw, ph) {
        _timer?.cancel();
        _timer = Timer(Duration(milliseconds: 100), () {
          session.resizeTerminal(w, h, pw, ph);
          print("w:$w h:$h");
        });
      };
      terminal.onOutput = (data) {
        print(data);
        session.write(utf8.encode(data));
      };
      terminal.onCurrentDirectoryChange = (dir) {
        print("目录变化了");
        print(dir);
        tagItemState.setActiveTagRemotePathAndUpdateList(dir);
        fileTreeState.setIndex(-1);
      };
      session.stdout
          .cast<List<int>>()
          .transform(Utf8Decoder())
          .listen(terminal.write);
      session.stderr
          .cast<List<int>>()
          .transform(Utf8Decoder())
          .listen(terminal.write);
    } catch (e) {
      terminal.write('$e\r\n');
      // initTerminal();
    }
  }

  @override
  Widget build(BuildContext context) {
    return TerminalView(
      terminal,
      controller: terminalController,
      autofocus: true,
      backgroundOpacity: 0.7,
      onSecondaryTapDown: (details, offset) async {
        final selection = terminalController.selection;
        if (selection != null) {
          final text = terminal.buffer.getText(selection);
          terminalController.clearSelection();
          await Clipboard.setData(ClipboardData(text: text));
        } else {
          final data = await Clipboard.getData('text/plain');
          final text = data?.text;
          if (text != null) {
            terminal.paste(text);
            terminal.onCurrentDirectoryChange;
          }
        }
      },
    );
  }
}
