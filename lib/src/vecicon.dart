// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:vector_graphics/vector_graphics.dart';

class VecIcon extends StatelessWidget {
  final String assetPath;
  final double size;
  final Color? color;
  final String? semanticLabel;

  const VecIcon({
    super.key,
    required this.assetPath,
    this.size = 24,
    this.color,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return VectorGraphic(
      loader: AssetBytesLoader(assetPath),
      width: size,
      height: size,
      semanticsLabel: semanticLabel,
      colorFilter: color != null
          ? ColorFilter.mode(color!, BlendMode.srcIn)
          : null,
    );
  }
}

// 使用方式简洁且安全
// IconButton(
//   onPressed: () {},
//   icon: VecIcon(
//     assetPath: "assets/svg/security.svg",
//     semanticLabel: '安全设置',
//   ),
// )
