import 'dart:async';

import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mssh/src/appstate.dart';
import 'package:mssh/src/floatingbox.dart';
import 'package:mssh/src/vecicon.dart';
import 'package:provider/provider.dart';

class Filetreeview extends StatefulWidget {
  const Filetreeview({super.key});

  @override
  State<Filetreeview> createState() => _FiletreeviewState();
}

class _FiletreeviewState extends State<Filetreeview> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FileControl(),
        Expanded(child: FileList()),
      ],
    );
  }
}

/// 顶部icon列表,控制
class FileControl extends StatefulWidget {
  const FileControl({super.key});

  @override
  State<FileControl> createState() => _FileControlState();
}

class _FileControlState extends State<FileControl> {
  String _isHover = '';
  final List<String> _iconPathList = [
    'assets/svg/filetree/arrow-left-outline.svg',
    'assets/svg/filetree/folder-up-outline.svg',
    'assets/svg/filetree/folder-down-outline.svg',
    'assets/svg/filetree/folder-add-outline.svg',
    'assets/svg/filetree/file-plus-outline.svg',
    'assets/svg/filetree/refresh-outline.svg',
  ];
  @override
  Widget build(BuildContext context) {
    // final selectedIndex = context.select<FiletreeState, int>(
    //   (value) => value.selectedIndex,
    // );
    final appThemeState = context.read<AppThemeState>();
    return Container(
      width: double.infinity,
      foregroundDecoration: BoxDecoration(
        border: BoxBorder.fromLTRB(
          bottom: BorderSide(color: appThemeState.borderDefault, width: 1),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _iconPathList
              .map(
                (el) => MouseRegion(
                  cursor: SystemMouseCursors.click,
                  onEnter: (event) => setState(() => _isHover = el),
                  onExit: (event) => setState(() => _isHover = ''),
                  child: GestureDetector(
                    child: Container(
                      width: 30,
                      height: 30,
                      padding: EdgeInsets.all(6),
                      color: _isHover == el ? appThemeState.bgHover : null,
                      foregroundDecoration: _isHover == el
                          ? BoxDecoration(
                              border: Border.all(
                                color: appThemeState.borderStrong,
                                width: 1,
                              ),
                            )
                          : null,
                      child: VecIcon(
                        assetPath: el,
                        size: 20,
                        color: appThemeState.iconWhiteSoft,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

/// 文件列表区域
class FileList extends StatefulWidget {
  const FileList({super.key});

  @override
  State<FileList> createState() => _FileListState();
}

class _FileListState extends State<FileList> {
  int _isHover = -1;
  final _hoverFileItemBoxController = FloatingBoxController();
  Timer? _timer;
  int _lastActiveTagIndex = -1;
  SftpClient? sftpClient;
  String currentRemotePath = '';
  List<SftpName> fileList = [];

  /// 更新文件列表
  Future<List<SftpName>> updateFileList(
    SftpClient sftpClient,
    String newPath,
  ) async {
    // print(newPath);
    currentRemotePath = newPath;
    // print('更新了 ${DateTime.now()}');
    return sftpClient.listdir(newPath);
    // print('获取了 ${DateTime.now()}');
  }

  // 获取父级目录
  String _parentPath(String path) {
    // 统一去掉结尾斜杠（根目录 "/" 除外）
    if (path.length > 1 && path.endsWith('/')) {
      path = path.substring(0, path.length - 1);
    }
    // 根目录的上级还是根目录
    if (path == '/' || path.isEmpty) return '/';

    final idx = path.lastIndexOf('/');
    if (idx <= 0) return '/'; // "/foo" 的上级是 "/"
    return path.substring(0, idx); // "/foo/bar" → "/foo"
  }

  @override
  void dispose() {
    _hoverFileItemBoxController.hideFloatingBox();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeTagNum = context.select<TagItemState, int>(
      (value) => value.activeTagNum,
    );
    if (activeTagNum == 0) {
      return Container(); // home页面不应该显示
    }
    final dirty = context.select<TagItemState, bool>(
      (value) => value.tags[activeTagNum].dirty,
    );
    final tagItem = context.select<TagItemState, SessionItem>(
      (value) => value.tags[activeTagNum],
    );
    final fileTreeState = context.read<FiletreeState>();
    final selectedIndex = context.select<FiletreeState, int>(
      (value) => value.selectedIndex,
    );
    sftpClient = context.select<TagItemState, SftpClient?>(
      (value) => value.tags[activeTagNum].sftpClient,
    );
    // 当终端中切换目录或者切换tag时更新列表和当前目录
    if (dirty || _lastActiveTagIndex != activeTagNum) {
      fileList = tagItem.fileList;
      currentRemotePath = tagItem.currentRemotePath;
      // fileList = context.select<TagItemState, List<SftpName>>(
      //   (value) => value.tags[activeTagNum].fileList
      //       .where((f) => f.filename != '.')
      //       .toList(),
      // );
      // currentRemotePath = context.select<TagItemState, String>(
      //   (value) => value.tags[activeTagNum].currentRemotePath,
      // );
      _lastActiveTagIndex = activeTagNum;
    }
    return ListView.builder(
      itemExtent: 30,
      itemCount: fileList.length,
      itemBuilder: (cx, index) {
        final info = fileList[index];
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          onHover: (event) {
            if (_timer?.isActive ?? false) return;
            _hoverFileItemBoxController.hideFloatingBox();
            _hoverFileItemBoxController.showFloatingBox(
              context,
              position: Offset(event.position.dx + 10, event.position.dy + 10),
              clickToClose: false,
              customChild: HoverFileItemBox(longname: info.longname),
            );
            _timer = Timer(
              const Duration(milliseconds: 30),
              () => _timer = null,
            );
          },
          onEnter: (event) => setState(() => _isHover = index),
          onExit: (event) {
            setState(() => _isHover = -1);
            _hoverFileItemBoxController.hideFloatingBox();
          },
          child: GestureDetector(
            onPanDown: (e) {
              fileTreeState.setIndex(index);
            },
            onDoubleTap: () async {
              final path = info.filename != '..'
                  ? '$currentRemotePath/${info.filename}'
                  : _parentPath(currentRemotePath);
              tagItem.dirty = false;
              final newList = await updateFileList(sftpClient!, path);
              setState(() {
                fileList = newList.where((f) => f.filename != '.').toList();
                currentRemotePath = path;
              });
            },
            child: Container(
              padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
              decoration: BoxDecoration(
                color: selectedIndex == index || index == _isHover
                    ? Color(0xFF3A3A3D)
                    : null,
              ),
              foregroundDecoration: BoxDecoration(
                border: selectedIndex == index
                    ? Border.all(color: Color(0xFF4E90F7), width: 1)
                    : null,
              ),
              child: Row(
                spacing: 5,
                children: [
                  VecIcon(
                    assetPath: info.attr.isDirectory
                        ? 'assets/svg/filetree/azure-folder-blank.svg'
                        : 'assets/svg/filetree/azure-file.svg',
                    size: 18,
                  ),
                  Expanded(
                    child: Text(info.filename, overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 文件项悬浮框内容
class HoverFileItemBox extends StatelessWidget {
  final String longname;
  const HoverFileItemBox({super.key, required this.longname});

  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.all(5), child: Text(longname));
  }
}
