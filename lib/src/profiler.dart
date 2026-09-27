import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mssh/src/appstate.dart';
import 'package:mssh/src/vecicon.dart';
import 'package:provider/provider.dart';

class Profiler extends StatefulWidget {
  const Profiler({super.key});

  @override
  State<Profiler> createState() => _ProfilerState();
}

class _ProfilerState extends State<Profiler> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // 设备信息
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DeviceCard(),
          ),
          // cpu监控
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: CpuCard(),
          ),
          // 内存监控
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: RamCard(),
          ),
          // 网络监控
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: NetWorkCard(),
          ),
          // 磁盘监控
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DiskCard(),
          ),
        ],
      ),
    );
  }
}

/// 设备信息监控卡片
class DeviceCard extends StatelessWidget {
  const DeviceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final appThemeState = context.read<AppThemeState>();
    return Container(
      width: 250,
      // height: 160,
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: appThemeState.bgTertiary,
        border: Border.all(
          width: 1,
          style: BorderStyle.solid,
          color: appThemeState.borderStrong,
        ),
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        spacing: 10,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  VecIcon(
                    assetPath: 'assets/svg/profiler/cwmScreenOn.svg',
                    size: 16,
                    color: appThemeState.iconWhiteSoft,
                  ),
                  Text(
                    '系统',
                    style: TextStyle(color: appThemeState.textPrimary),
                  ),
                ],
              ),
              Text(
                '刷新中...',
                style: TextStyle(color: appThemeState.textPrimary),
              ),
            ],
          ),
          Column(
            spacing: 10,
            children: [
              Row(
                spacing: 60,
                children: [
                  Column(
                    children: [
                      Text(
                        '主机',
                        style: TextStyle(color: appThemeState.textSecondary),
                      ),
                      Text(
                        'armbian',
                        style: TextStyle(color: appThemeState.textPrimary),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        '主机',
                        style: TextStyle(color: appThemeState.textSecondary),
                      ),
                      Text(
                        'armbian',
                        style: TextStyle(color: appThemeState.textPrimary),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                spacing: 60,
                children: [
                  Column(
                    children: [
                      Text(
                        '主机',
                        style: TextStyle(color: appThemeState.textSecondary),
                      ),
                      Text(
                        'armbian',
                        style: TextStyle(color: appThemeState.textPrimary),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        '主机',
                        style: TextStyle(color: appThemeState.textSecondary),
                      ),
                      Text(
                        'armbian',
                        style: TextStyle(color: appThemeState.textPrimary),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          // Expanded(
          //   child: GridView.count(
          //     scrollDirection: Axis.horizontal,
          //     mainAxisSpacing: 60,
          //     crossAxisSpacing: 5,
          //     crossAxisCount: 2,
          //     children: List.generate(4, (index) {
          //       return Container(
          //         color: Colors.amber,
          //         child: Column(
          //           children: [Text('主机$index'), Text('armbian')],
          //         ),
          //       );
          //     }),
          //   ),
          // ),
        ],
      ),
    );
  }
}

/// cpu信息卡片
class CpuCard extends StatelessWidget {
  const CpuCard({super.key});

  @override
  Widget build(BuildContext context) {
    final appThemeState = context.read<AppThemeState>();
    final textStylePrimary = TextStyle(color: appThemeState.textPrimary);
    final textStyleSecondary = TextStyle(color: appThemeState.textSecondary);
    return Container(
      width: 250,
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: appThemeState.bgTertiary,
        border: Border.all(
          width: 1,
          style: BorderStyle.solid,
          color: appThemeState.borderStrong,
        ),
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        spacing: 30,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  VecIcon(
                    assetPath: 'assets/svg/profiler/cpu-charge-outline.svg',
                    size: 16,
                    color: appThemeState.iconWhiteSoft,
                  ),
                  Text(' CPU', style: textStylePrimary),
                ],
              ),
              Text('4核', style: textStyleSecondary),
            ],
          ),
          Row(
            spacing: 15,
            children: [
              // 仪表盘
              FlatBottomSemicircle(radius: 40, color: Colors.lightBlueAccent),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('平均使用率:', style: textStylePrimary),
                        Text(
                          '5%',
                          style: TextStyle(color: appThemeState.primary),
                        ),
                      ],
                    ),
                    Stack(
                      children: [
                        CustomPaint(
                          size: Size(130, 30),
                          painter: LinePainter(
                            color: appThemeState.borderStrong,
                          ),
                        ),
                        CustomPaint(
                          size: Size(20, 30),
                          painter: LinePainter(color: appThemeState.primary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 0),
        ],
      ),
    );
  }
}

/// 内存信息卡片
class RamCard extends StatelessWidget {
  const RamCard({super.key});

  @override
  Widget build(BuildContext context) {
    final appThemeState = context.read<AppThemeState>();
    final textStylePrimary = TextStyle(color: appThemeState.textPrimary);
    final textStyleSecondary = TextStyle(color: appThemeState.textSecondary);
    return Container(
      width: 250,
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: appThemeState.bgTertiary,
        border: Border.all(
          width: 1,
          style: BorderStyle.solid,
          color: appThemeState.borderStrong,
        ),
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        spacing: 20,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  VecIcon(
                    assetPath: 'assets/svg/profiler/cpu-charge-outline.svg',
                    size: 16,
                    color: appThemeState.iconWhiteSoft,
                  ),
                  Text(' 内存', style: textStylePrimary),
                ],
              ),
              Text('刷新中...', style: textStyleSecondary),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Row(
                spacing: 20,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('使用中', style: textStyleSecondary),
                      Text('13.1 GB', style: textStylePrimary),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('可用', style: textStyleSecondary),
                      Text('2.2 GB', style: textStylePrimary),
                    ],
                  ),
                ],
              ),
              WaveForm(name: ProfilerNameList.ram, size: Size(240, 60)),
            ],
          ),
          // SizedBox(height: 0),
        ],
      ),
    );
  }
}

/// 网络信息卡片
class NetWorkCard extends StatelessWidget {
  const NetWorkCard({super.key});

  @override
  Widget build(BuildContext context) {
    final appThemeState = context.read<AppThemeState>();
    final textStylePrimary = TextStyle(color: appThemeState.textPrimary);
    final textStyleSecondary = TextStyle(color: appThemeState.textSecondary);
    return Container(
      width: 250,
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: appThemeState.bgTertiary,
        border: Border.all(
          width: 1,
          style: BorderStyle.solid,
          color: appThemeState.borderStrong,
        ),
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        spacing: 20,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  VecIcon(
                    assetPath: 'assets/svg/profiler/network_dark.svg',
                    size: 16,
                  ),
                  Text(' 网络', style: textStylePrimary),
                ],
              ),
              Text('刷新中...'),
            ],
          ),
          Column(
            spacing: 10,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: appThemeState.borderStrong,
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
                padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('eth0', style: textStylePrimary),
                    Row(
                      children: [
                        Text(
                          '⬆ 3.85 kb/s',
                          style: TextStyle(color: appThemeState.warning),
                        ),
                        Text(' / ', style: textStyleSecondary),
                        Text(
                          '⬇ 3.85 kb/s',
                          style: TextStyle(color: appThemeState.error),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: appThemeState.borderStrong,
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
                padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('lo', style: textStylePrimary),
                    Row(
                      children: [
                        Text(
                          '⬆ 3.85 kb/s',
                          style: TextStyle(color: appThemeState.warning),
                        ),
                        Text(' / ', style: textStyleSecondary),
                        Text(
                          '⬇ 3.85 kb/s',
                          style: TextStyle(color: appThemeState.error),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          // SizedBox(height: 0),
        ],
      ),
    );
  }
}

/// 硬盘信息卡片
class DiskCard extends StatelessWidget {
  const DiskCard({super.key});

  @override
  Widget build(BuildContext context) {
    final list = context.select<ProfilerState, List<String>>(
      (value) => value.diskList,
    );
    final appThemeState = context.read<AppThemeState>();
    final textStylePrimary = TextStyle(color: appThemeState.textPrimary);
    final textStyleSecondary = TextStyle(color: appThemeState.textSecondary);
    return Container(
      width: 250,
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: appThemeState.bgTertiary,
        border: Border.all(
          width: 1,
          style: BorderStyle.solid,
          color: appThemeState.borderStrong,
        ),
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        spacing: 20,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  VecIcon(
                    assetPath: 'assets/svg/profiler/network_dark.svg',
                    size: 16,
                  ),
                  Text(' 硬盘', style: textStylePrimary),
                ],
              ),
              Text('刷新中...', style: textStyleSecondary),
            ],
          ),
          Column(
            spacing: 10,
            children: list
                .map(
                  (el) => Container(
                    decoration: BoxDecoration(
                      color: appThemeState.borderStrong,
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                    padding: EdgeInsets.all(5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 5,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(el, style: textStylePrimary),
                            Text(
                              '11%',
                              style: TextStyle(color: appThemeState.primary),
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsetsGeometry.only(left: 2),
                          child: CustomPaint(
                            size: Size(215, 4),
                            painter: LinePainter(),
                          ),
                        ),
                        Text('3.05 GB / 28.07 GB', style: textStyleSecondary),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

/// 仪表盘绘制
class FlatBottomSemicircle extends StatelessWidget {
  final Color color;
  final double radius;

  const FlatBottomSemicircle({
    super.key,
    required this.color,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(radius * 2, radius), // 宽度是直径，高度是半径
      painter: _FlatBottomPainter(color: color),
    );
  }
}

class _FlatBottomPainter extends CustomPainter {
  final Color color;
  _FlatBottomPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final rect = Rect.fromLTWH(0, -8, size.width, size.width);
    canvas.drawArc(rect, 3 * pi / 4, 3 * pi / 2, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 直线绘制
class LinePainter extends CustomPainter {
  Color? color;
  LinePainter({this.color});
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..color = color ?? Colors.grey;
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 性能图绘制
class WaveForm extends StatelessWidget {
  final ProfilerNameList name;
  final Size size;
  const WaveForm({super.key, required this.name, required this.size});

  @override
  Widget build(BuildContext context) {
    print('======== 性能图重绘了 ========');
    final list = context.select<ProfilerState, List<double>>(
      (value) => value.map[name]!,
    );
    return Stack(
      children: [
        RepaintBoundary(
          child: CustomPaint(size: size, painter: _TablePainter()),
        ),
        CustomPaint(
          size: size,
          painter: _WaveFormPainter(list: list),
        ),
      ],
    );
  }
}

/// 表格绘制
class _TablePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    print('绘制了表格');
    var paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..color = Colors.grey
      ..strokeWidth = 0.5;

    var rect = Rect.fromLTWH(0, 0, size.width, size.height);
    // 画横线
    for (var i = 0; i <= (size.height / 3); i++) {
      double dy = rect.top + i * 3;
      canvas.drawLine(Offset(rect.left, dy), Offset(rect.right, dy), paint);
    }
    // 画竖线
    for (var i = 0; i <= (size.width / 3); i++) {
      double dx = rect.left + i * 3;
      canvas.drawLine(Offset(dx, rect.top), Offset(dx, rect.bottom), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 波形图
class _WaveFormPainter extends CustomPainter {
  final List<double> list;
  _WaveFormPainter({required this.list});
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..isAntiAlias = true
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    var rect = Rect.fromLTWH(0, 0, size.width, size.height);
    // 画波浪线
    var path = Path();
    var h = size.height / 3; // 表格高度的格子数
    path.moveTo(rect.right - (list.length - 1) * 3, (h - list[0]) * 3);
    for (var i = 1; i < list.length; i++) {
      path.lineTo(rect.right - (list.length - i - 1) * 3, (h - list[i]) * 3);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
