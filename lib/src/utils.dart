import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart';
import 'package:mssh/src/appstate.dart';
import 'package:mssh/src/terminal.dart';

class SftpUtils {
  final SSHClient client;
  String _currentRemotePath = '';
  List<SftpName> _fileList = [];
  late final SftpClient sftpClient;
  SftpUtils({required this.client}) {
    client.sftp().then(
      (sftp) => sftpClient = sftp,
      // ignore: avoid_print
      onError: (err) => print(err),
    );
  }

  set changeCurrentPath(String newPath) {
    _currentRemotePath = newPath;
  }

  String get currentPath => _currentRemotePath;
  List<SftpName> get fileList => _fileList;

  // 排序--按文件名的ascii排序，ascii码大的在前面
  int _sortByName(String a, String b) {
    int len = a.length > b.length ? b.length : a.length;
    for (var i = 0; i < len; i++) {
      int res = a[i].compareTo(b[i]);
      if (res != 0) {
        return res;
      }
    }
    if (a.length == len) {
      return 1;
    } else {
      return -1;
    }
  }

  // 更新文件列表
  Future<void> updateFileList(String newPath) async {
    if (_currentRemotePath != '') {
      print('更新了');
      _fileList = await sftpClient.listdir(newPath);
      // _fileList.forEach((val) => print(val.filename));
      _fileList.sort((a, b) {
        if (a.attr.isDirectory && b.attr.isDirectory) {
          return _sortByName(a.filename, b.filename);
        }
        if (a.attr.isDirectory) {
          return 1;
        }
        if (b.attr.isDirectory) {
          return -1;
        }
        return _sortByName(a.filename, b.filename);
        // return 1;
      });
    } else {
      // ignore: avoid_print
      print('远程路径为空字符串');
    }
  }

  // 获取指定目录文件列表
  Future<List<SftpName>> getFileList(String p) async {
    return await sftpClient.listdir('$_currentRemotePath/$p');
  }
}

class SSHSessionUtils {
  static Future<SSHClient> createClient({
    required String hostname,
    required String username,
    required String passwd,
    int? port,
    TagItemState? tagItemState,
  }) async {
    final client = SSHClient(
      await SSHSocket.connect(hostname, port ?? 22),
      username: username,
      onPasswordRequest: () => passwd,
    );
    if (tagItemState != null) {
      // 创建ssh连接的同时创建一个新的标签和标签页
      tagItemState.addTag(
        '$username@$hostname',
        SSHSessionTerminal(key: ObjectKey(client), client: client),
        client,
      );
      tagItemState.activeTag(tagItemState.tags.length - 1);
    }
    return client;
  }
}
