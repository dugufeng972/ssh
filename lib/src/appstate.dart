// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart';
import 'package:mssh/src/filetreeview.dart';
import 'package:mssh/src/homeview.dart';
import 'package:mssh/src/profiler.dart';
import 'package:mssh/src/quickconnect.dart';

class Appstate with ChangeNotifier {
  List<QuickConnect> _list = [];
  List<SessionItem> _tags = [
    SessionItem("home", Homeview(key: ValueKey("home"))),
  ];
  int activeTagNum = 0;
  // SidebarState sidebarState = SidebarState();

  List<SessionItem> get tags => _tags;
  List<QuickConnect> get list => _list;

  void addTag(String name, Widget widget, SSHClient client) {
    _tags = [..._tags, SessionItem(name, widget, client: client)];
    notifyListeners();
  }

  // 切换对应组件前台显示
  void activeTag(int num) {
    if (num < 0 || num >= _tags.length) {
      print("激活tag的数字错误");
      return;
    }
    activeTagNum = num;
    // QuickConnect('d', 'd');
    notifyListeners();
  }

  // 删除对应组件
  void delView(int index) {
    print('del view index: $index');
    if (index <= 0 || index > _tags.length) {
      print("激活tag的数字错误");
      return;
    }
    _tags.removeAt(index);
    if (activeTagNum >= _tags.length) {
      activeTagNum = _tags.length - 1;
    }
    notifyListeners();
  }

  /// 修改当前活动页面的远程路径
  // void setActiveTagRemotePathAndUpdateList(String newPath) async {
  //   _tags[activeTagNum].sftpUtils?.changeCurrentPath = newPath;
  //   await _tags[activeTagNum].sftpUtils!.updateFileList(newPath);
  //   notifyListeners();
  // }
}

/// 快速连接状态
class QuickConnectState with ChangeNotifier {
  List<QuickConnect> quickConnectList = [];
  void addQuickConnect(
    String hostname,
    String username, {
    int? port,
    String? connectType,
    String? alis,
  }) {
    quickConnectList.add(
      QuickConnect(
        hostname,
        username,
        port ?? 22,
        connectType ?? 'ssh',
        alis ?? '',
      ),
    );
    stateToJson();
    notifyListeners();
  }

  // 序列化
  void stateToJson() async {
    String jsonString = jsonEncode(
      quickConnectList.map((val) => val.toJson()).toList(),
    );
    var file = File('config');
    try {
      file.writeAsString(jsonString);
    } catch (e) {
      print('写入状态出异常$e');
    }
  }

  // 反序列化
  void jsonToState() async {
    try {
      var file = File('config');
      if (file.existsSync()) {
        file.readAsString().then((res) {
          List decoded = jsonDecode(res);
          quickConnectList = decoded
              .map((e) => QuickConnect.fromJson(e))
              .toList();
          notifyListeners();
        });
      }
    } catch (e) {
      print(e);
    }
  }
}

class QuickConnect {
  String hostname;
  int port;
  String username;
  String connectType;
  String alis; // 别名
  QuickConnect(
    this.hostname,
    this.username,
    this.port,
    this.connectType,
    this.alis,
  );
  // 序列化：对象转 Map
  Map<String, dynamic> toJson() => {
    'alis': alis,
    'hostname': hostname,
    'port': port,
    'username': username,
    'connectType': connectType,
  };
  // 反序列化：Map 转对象
  factory QuickConnect.fromJson(Map<String, dynamic> json) => QuickConnect(
    json['hostname'],
    json['username'],
    json['port'],
    json['connectType'],
    json['alis'],
  );
}

/// 活动标签状态
class TagItemState with ChangeNotifier {
  List<SessionItem> tags = [
    SessionItem("home", Homeview(key: ValueKey("home"))),
  ];
  int activeTagNum = 0;
  Map<SSHClient, Timer> timers = {};

  // 增加tag
  void addTag(String name, Widget widget, SSHClient client) {
    tags = [...tags, SessionItem(name, widget, client: client)];
    notifyListeners();
  }

  // 切换对应组件前台显示
  void activeTag(int num) {
    if (num < 0 || num >= tags.length) {
      print("激活tag的数字错误");
      return;
    }
    activeTagNum = num;
    notifyListeners();
  }

  // 删除对应组件
  void delView(int index) {
    print('del view index: $index');
    if (index <= 0 || index > tags.length) {
      print("激活tag的数字错误");
      return;
    }
    tags.removeAt(index);
    if (activeTagNum >= tags.length) {
      activeTagNum = tags.length - 1;
    }
    notifyListeners();
  }

  /// 修改当前活动页面的远程路径
  void setActiveTagRemotePathAndUpdateList(String newPath) async {
    tags[activeTagNum].currentRemotePath = newPath;
    await tags[activeTagNum].updateFileList(newPath);
    tags[activeTagNum].dirty = true;
    notifyListeners();
  }

  /// 开启定时任务获取远程设备信息
  void getRemoteInfo() {
    if (tags.length == 1) return;
    for (var i = 1; i < tags.length; i++) {}
  }
}

class SessionItem {
  String name;
  Widget widget;
  SSHClient? client;
  // 文件相关
  SftpClient? sftpClient;
  String currentRemotePath = '';
  List<SftpName> fileList = [];
  bool dirty = false;
  // 性能监控
  Map<ProfilerNameList, List<double>> map = {
    ProfilerNameList.ram: [2, 5, 3, 6, 3], // 有个数限制，当前是30个
  };

  SessionItem(this.name, this.widget, {this.client}) {
    if (client != null) {
      client!.sftp().then((sc) => sftpClient = sc);
    }
  }

  /// 更新文件列表
  Future<void> updateFileList(String newPath) async {
    print(newPath);
    if (currentRemotePath != '') {
      print('更新了 ${DateTime.now()}');
      fileList = await sftpClient?.listdir(newPath) ?? [];
      print('获取了 ${DateTime.now()}');
      currentRemotePath = newPath;
    } else {
      print('远程路径为空字符串');
    }
  }

  /// 获取指定目录文件列表
  Future<List<SftpName>> getFileList(String p) async {
    if (sftpClient == null) {
      throw Exception('sftpClient未初始化! 在TagItem中');
    }
    return await sftpClient!.listdir('$currentRemotePath/$p');
  }
}

/// 侧边栏相关状态
class SidebarState with ChangeNotifier {
  final Map<String, Widget> _leftList = {
    'assets/svg/sidebar/folder-outline.svg': Filetreeview(),
    'assets/svg/sidebar/link.svg': Quickconnect(),
    'assets/svg/sidebar/settings2-outline.svg': Filetreeview(),
  };
  String _leftActiveKey = '';
  Map<String, Widget> get leftList => _leftList;
  String get leftActiveKey => _leftActiveKey;

  final Map<String, Widget> _rightList = {
    'assets/svg/sidebar/notifications.svg': Filetreeview(),
    'assets/svg/sidebar/profiler.svg': Profiler(),
  };
  String _rightActiveKey = '';
  Map<String, Widget> get rightList => _rightList;
  String get rightActiveKey => _rightActiveKey;
  SidebarState();

  void setLeftActiveKey(String key) {
    if (key == _leftActiveKey) {
      _leftActiveKey = '';
    } else {
      _leftActiveKey = key;
    }
    notifyListeners();
  }

  void setRightActiveKey(String key) {
    if (key == _rightActiveKey) {
      _rightActiveKey = '';
    } else {
      _rightActiveKey = key;
    }
    notifyListeners();
  }
}

/// 文件列表相关状态
class FiletreeState with ChangeNotifier {
  /// icon列表
  // final List<String> iconPathList = [
  //   'assets/svg/filetree/arrow-left-outline.svg',
  //   'assets/svg/filetree/folder-up-outline.svg',
  //   'assets/svg/filetree/folder-down-outline.svg',
  //   'assets/svg/filetree/folder-add-outline.svg',
  //   'assets/svg/filetree/file-plus-outline.svg',
  //   'assets/svg/filetree/refresh-outline.svg',
  // ];

  // -1为未选中
  int selectedIndex = -1;
  void setIndex(int index) {
    selectedIndex = index;
    print('选中了$index');
    notifyListeners();
  }
}

/// 监控栏相关状态
class ProfilerState with ChangeNotifier {
  Map<ProfilerNameList, List<double>> map = {
    ProfilerNameList.ram: [2, 5, 3, 6, 3], // 有个数限制，当前是30个
  };
  // 目录列表
  List<String> diskList = ['/', '/boot', '/var/log'];
  void addRamList(ProfilerNameList name, double val) {
    var oldList = map[name]!;
    var newList = List<double>.from(oldList);
    if (newList.length < 30) {
      newList.add(val);
    } else {
      newList.removeAt(0);
      newList.add(val);
    }
    map[name] = newList;
    notifyListeners();
  }

  Timer? timer;
  void test() {
    var rand = Random();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      var n = rand.nextInt(10).toDouble();
      print('增加了数字$n');
      addRamList(ProfilerNameList.ram, n);
      // notifyListeners();
    });
  }
}

enum ProfilerNameList { ram, cpu, disk }

/// 主题状态
class AppTheme {
  // ========== 深色主题 ==========
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      // 主色
      primary: Color(0xFF3B82F6),
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFF1E3A5F),
      onPrimaryContainer: Color(0xFF8FBFFF),

      // 背景层
      surface: Color(0xFF1E1E1E),
      onSurface: Color(0xFFE6E6E6),
      surfaceContainerHighest: Color(0xFF2D2D30),
      onSurfaceVariant: Color(0xFFB0B0B4),

      // 边框
      outline: Color(0xFF3C3C41),
      outlineVariant: Color(0xFF2E2E32),

      // 语义色
      error: Color(0xFFEF4444),
      onError: Color(0xFFFFFFFF),
    ),
    scaffoldBackgroundColor: const Color(0xFF1E1E1E),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Color(0xFFE6E6E6),
      elevation: 0,
      scrolledUnderElevation: 1,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF2D2D30),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Color(0xFF3C3C41)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1E1E1E),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFF3C3C41)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFF3C3C41)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
      ),
      hintStyle: const TextStyle(color: Color(0xFF808085)),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF2A2A2E),
      thickness: 1,
    ),
    // 明暗主题下用 surface 色叠加来表现层级
    applyElevationOverlayColor: true,
  );

  // ========== 浅色主题（按需调整） ==========
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF2563EB),
      onPrimary: Color(0xFFFFFFFF),
      surface: Color(0xFFF5F5F5),
      onSurface: Color(0xFF1E1E1E),
      outline: Color(0xFFD4D4D8),
      error: Color(0xFFDC2626),
    ),
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
  );
}

/// 主题状态
class AppThemeState with ChangeNotifier {
  // 黑色模式 -- 默认主题
  // 中性色
  Color bgBase = Color(0xFF121212); // 窗口最底层背景（OLED 友好）
  Color bgPrimary = Color(0xFF1E1E1E); //主内容区背景（推荐默认）
  Color bgSecondary = Color(0xFF252526); // 侧边栏 / 面板
  Color bgTertiary = Color(0xFF2D2D30); //卡片 / 悬浮块
  Color bgElevated = Color(0xFF333337); //弹窗 / 下拉菜单
  Color bgHover = Color(0xFF3A3A3D); //悬停态
  Color bgActive = Color(0xFF454549); //按下 / 选中态
  Color bgDisabled = Color(0xFF2A2A2C); //禁用背景
  Color borderSubtle = Color(0xFF2E2E32); //极弱分隔线
  Color borderDefault = Color(0xFF3C3C41); //常规边框
  Color borderStrong = Color(0xFF4A4A50); //强调边框
  Color divider = Color(0xFF2A2A2E); //列表分隔线
  // 文字色
  Color textPrimary = Color(0xFFE6E6E6); //	正文 / 标题
  Color textSecondary = Color(0xFFB0B0B4); //	次要说明
  Color textTertiary = Color(0xFF808085); //占位符 / 辅助
  Color textDisabled = Color(0xFF565659); //禁用文字
  Color textInverse = Color(0xFF1E1E1E); //亮色按钮上的文字
  Color textLink = Color(0xFF4EA1FF); //链接
  // 品牌主色
  Color primary = Color(0xFF3B82F6); //主按钮 / 强调
  Color primaryHover = Color(0xFF4E90F7); //悬停
  Color primaryActive = Color(0xFF2F6FD8); //	按下
  Color primarySubtle = Color(0xFF1E3A5F); //	选中项背景（弱化）
  Color primaryBorder = Color(0xFF2C5FA8); //	输入框聚焦边框
  // icon颜色
  Color iconWhite = Color(0xFFFFFFFF); // 纯白
  Color iconWhiteSoft = Color(0xFFE0E0E0); // 次白（推荐）
  Color iconWhiteMedium = Color(0xFFBDBDBD); // 中等灰白
  Color iconGrey = Color(0xFF9E9E9E); // 灰色（次要图标）
  Color iconPrimary = Color(0xFF90CAF9); // 主色调图标（蓝）
  Color iconDisabled = Color(0xFF616161); // 禁用状态
  // 语义色
  Color success = Color(0xFF22C55E);
  Color successSoft = Color(0xFF14361F);
  Color warning = Color(0xFFF59E0B);
  Color error = Color(0xFFEF4444);
  Color info = Color(0xFF3B82F6);
  AppThemeState();
  AppThemeState.dark({
    this.bgBase = const Color(0xFF121212),
    this.bgPrimary = const Color(0xFF1E1E1E),
    this.bgSecondary = const Color(0xFF252526),
    this.bgTertiary = const Color(0xFF2D2D30),
    this.bgElevated = const Color(0xFF333337),
    this.bgHover = const Color(0xFF3A3A3D),
    this.bgActive = const Color(0xFF454549),
    this.bgDisabled = const Color(0xFF2A2A2C),
    this.borderSubtle = const Color(0xFF2E2E32),
    this.borderDefault = const Color(0xFF3C3C41),
    this.borderStrong = const Color(0xFF4A4A50),
    this.divider = const Color(0xFF2A2A2E),
    this.textPrimary = const Color(0xFFE6E6E6),
    this.textSecondary = const Color(0xFFB0B0B4),
    this.textTertiary = const Color(0xFF808085),
    this.textDisabled = const Color(0xFF565659),
    this.textInverse = const Color(0xFF1E1E1E),
    this.textLink = const Color(0xFF4EA1FF),
    this.primary = const Color(0xFF3B82F6),
    this.primaryHover = const Color(0xFF4E90F7),
    this.primaryActive = const Color(0xFF2F6FD8),
    this.primarySubtle = const Color(0xFF1E3A5F),
    this.primaryBorder = const Color(0xFF2C5FA8),
  });
  AppThemeState.light({
    this.bgBase = const Color(0xFFF5F5F5),
    this.bgPrimary = const Color(0xFFFFFFFF),
    this.bgSecondary = const Color(0xFFF5F5F5),
    this.bgTertiary = const Color(0xFFF5F5F5),
    this.bgElevated = const Color(0xFFFFFFFF),
    this.bgHover = const Color(0xFFF0F0F0),
    this.bgActive = const Color(0xFFE6E6E6),
    this.bgDisabled = const Color(0xFFF5F5F5),
    this.borderSubtle = const Color(0xFFE6E6E6),
    this.borderDefault = const Color(0xFFD4D4D8),
    this.borderStrong = const Color(0xFFBFBFBF),
    this.divider = const Color(0xFFE6E6E6),
    this.textPrimary = const Color(0xFF1E1E1E),
    this.textSecondary = const Color(0xFF3C3C41),
    this.textTertiary = const Color(0xFF565659),
    this.textDisabled = const Color(0xFF808085),
    this.textInverse = const Color(0xFFFFFFFF),
    this.textLink = const Color(0xFF2563EB),
    this.primary = const Color(0xFF2563EB),
    this.primaryHover = const Color(0xFF3B82F6),
    this.primaryActive = const Color(0xFF1D4ED8),
    this.primarySubtle = const Color(0xFFEFF6FF),
    this.primaryBorder = const Color(0xFF93C5FD),
  });
}
