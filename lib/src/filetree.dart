// // ignore_for_file: avoid_print

// import 'dart:async';

// import 'package:dartssh2/dartssh2.dart';
// import 'package:flutter/material.dart';
// import 'package:mssh/src/appstate.dart';
// import 'package:mssh/src/floatingbox.dart';
// import 'package:mssh/src/vecicon.dart';
// import 'package:provider/provider.dart';

// class Filetree extends StatefulWidget {
//   const Filetree({super.key});

//   @override
//   State<Filetree> createState() => _FiletreeState();
// }

// class _FiletreeState extends State<Filetree> {
//   String lastPath = 'no path';
//   final List<String> _iconPathList = [
//     'assets/svg/filetree/arrow-left-outline.svg',
//     'assets/svg/filetree/folder-up-outline.svg',
//     'assets/svg/filetree/folder-down-outline.svg',
//     'assets/svg/filetree/folder-add-outline.svg',
//     'assets/svg/filetree/file-plus-outline.svg',
//     'assets/svg/filetree/refresh-outline.svg',
//   ];
//   // dd
//   // bool _isHover = false;
//   // // MouseCursor _cursor = SystemMouseCursors.basic;
//   // final FloatingBoxController _floatingBoxController = FloatingBoxController();
//   // Timer? _timer;
//   // final _rightFloatingBox = FloatingBoxController();

//   Widget _createIconBtn(String assetPath) {
//     return MouseRegion(
//       key: GlobalKey(debugLabel: assetPath),
//       child: GestureDetector(
//         child: Container(
//           decoration: BoxDecoration(),
//           padding: EdgeInsets.all(3),
//           child: VecIcon(assetPath: assetPath, size: 18),
//         ),
//       ),
//     );
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//   }

//   @override
//   Widget build(BuildContext context) {
//     print('========== FileTree build ==========');
//     final activeTagNum = context.select<Appstate, int>(
//       (val) => val.activeTagNum,
//     );
//     final fileList = context.select<Appstate, List<SftpName>>(
//       (val) => val.tags[activeTagNum].sftpUtils?.fileList ?? [],
//     );
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: _iconPathList.map((el) => _createIconBtn(el)).toList(),
//           ),
//         ),
//         Expanded(
//           child: ListView.builder(
//             itemCount: fileList.length,
//             itemExtent: 30,
//             itemBuilder: (con, index) {
//               final info = fileList[index];
//               final widget = Row(
//                 key: GlobalKey(debugLabel: 'item-row-$index'),
//                 children: [
//                   info.attr.isDirectory
//                       ? VecIcon(
//                           assetPath: 'assets/svg/filetree/folder-outline.svg',
//                           size: 18,
//                           color: Colors.lightBlue,
//                         )
//                       : VecIcon(
//                           assetPath: 'assets/svg/filetree/file-outline.svg',
//                           size: 18,
//                           color: Colors.lightBlue,
//                         ),
//                   Expanded(
//                     child: Text(
//                       info.filename,
//                       style: TextStyle(backgroundColor: Colors.cyanAccent),
//                       maxLines: 1,
//                       overflow: TextOverflow.clip,
//                       softWrap: false,
//                     ),
//                   ),
//                 ],
//               );
//               final floatingBox = Column(children: [Text(info.longname)]);
//               return ItemView(
//                 key: GlobalKey(debugLabel: 'item$index'),
//                 index: index,
//                 widget: widget,
//                 floatingBox: floatingBox,
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }

// class ItemView extends StatefulWidget {
//   final int index;
//   final Widget widget;
//   final Widget floatingBox;
//   const ItemView({
//     super.key,
//     required this.index,
//     required this.widget,
//     required this.floatingBox,
//   });

//   @override
//   State<ItemView> createState() => _ItemViewState();
// }

// class _ItemViewState extends State<ItemView> {
//   bool _isHover = false;
//   // MouseCursor _cursor = SystemMouseCursors.basic;
//   final FloatingBoxController _floatingBoxController = FloatingBoxController();
//   Timer? _timer;
//   final _rightFloatingBox = FloatingBoxController();

//   @override
//   void dispose() {
//     _floatingBoxController.hideFloatingBox();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     print('ItemView build: ${widget.index} - date: ${DateTime.now()}');
//     final activeTagNum = context.select<TagItemState, int>(
//       (val) => val.activeTagNum,
//     );
//     final tagItem = context.select<TagItemState, TagItem>(
//       (val) => val.tags[activeTagNum],
//     );
//     final appstate = context.read<Appstate>();
//     final fileTreeState = context.read<FiletreeState>();
//     final selectIndex = context.select<FiletreeState, int>(
//       (value) => value.selectedIndex,
//     );

//     return Stack(
//       children: [
//         Container(
//           color: widget.index == selectIndex ? Colors.grey : Colors.white,
//           child: MouseRegion(
//             cursor: SystemMouseCursors.click,
//             onEnter: (event) {
//               setState(() {
//                 _isHover = true;
//               });
//             },
//             onHover: (event) {
//               if (_timer?.isActive ?? false) return;
//               _floatingBoxController.hideFloatingBox();
//               _floatingBoxController.showFloatingBox(
//                 context,
//                 position: Offset(
//                   event.position.dx + 10,
//                   event.position.dy + 10,
//                 ),
//                 clickToClose: false,
//                 customChild: widget.floatingBox,
//               );
//               _timer = Timer(
//                 const Duration(milliseconds: 30),
//                 () => _timer = null,
//               );
//             },
//             onExit: (event) {
//               _timer?.cancel();
//               _floatingBoxController.hideFloatingBox();
//               setState(() {
//                 _isHover = false;
//               });
//             },
//             child: GestureDetector(
//               onDoubleTap: () {
//                 print("click item ${widget.index}");
//                 if (tagItem
//                         .sftpUtils
//                         ?.fileList[widget.index]
//                         .attr
//                         .isDirectory ??
//                     false) {
//                   appstate.setActiveTagRemotePathAndUpdateList(
//                     '${tagItem.sftpUtils?.currentPath}/${tagItem.sftpUtils?.fileList[widget.index].filename}',
//                   );
//                 }
//               },
//               onTap: () {
//                 // print('click ${DateTime.now()}');
//                 fileTreeState.setIndex(widget.index);
//                 // print('clicked ${DateTime.now()}');
//               },
//               onSecondaryTapUp: (details) {
//                 print('right click');
//                 _rightFloatingBox.showFloatingBox(
//                   context,
//                   position: details.globalPosition,
//                   customChild: Column(
//                     children: [
//                       Row(
//                         children: [
//                           VecIcon(
//                             assetPath:
//                                 'assets/svg/filetree/folder-open-outline.svg',
//                             size: 14,
//                             // color: Colors.amber,
//                           ),
//                           Text(' open'),
//                         ],
//                       ),
//                     ],
//                   ),
//                 );
//               },
//               child: widget.widget,
//             ),
//           ),
//         ),
//       ],
//     );
//     // return Container(
//     //   // color: isSelected ? Colors.grey : Colors.white,
//     //   // color: _setColor(context),
//     //   child: MouseRegion(
//     //     cursor: SystemMouseCursors.click,
//     //     onEnter: (event) {
//     //       setState(() {
//     //         _isHover = true;
//     //       });
//     //     },
//     //     onHover: (event) {
//     //       if (_timer?.isActive ?? false) return;
//     //       _floatingBoxController.hideFloatingBox();
//     //       _floatingBoxController.showFloatingBox(
//     //         context,
//     //         position: Offset(event.position.dx + 10, event.position.dy + 10),
//     //         clickToClose: false,
//     //         customChild: widget.floatingBox,
//     //       );
//     //       _timer = Timer(const Duration(milliseconds: 30), () => _timer = null);
//     //     },
//     //     onExit: (event) {
//     //       _timer?.cancel();
//     //       _floatingBoxController.hideFloatingBox();
//     //       setState(() {
//     //         _isHover = false;
//     //       });
//     //     },
//     //     child: GestureDetector(
//     //       onDoubleTap: () {
//     //         print("click item ${widget.index}");
//     //         if (tagItem.sftpUtils?.fileList[widget.index].attr.isDirectory ??
//     //             false) {
//     //           appstate.setActiveTagRemotePathAndUpdateList(
//     //             '${tagItem.sftpUtils?.currentPath}/${tagItem.sftpUtils?.fileList[widget.index].filename}',
//     //           );
//     //         }
//     //       },
//     //       onTap: () {
//     //         // print('click ${DateTime.now()}');
//     //         fileTreeState.setIndex(widget.index);
//     //         // print('clicked ${DateTime.now()}');
//     //       },
//     //       onSecondaryTapUp: (details) {
//     //         print('right click');
//     //         _rightFloatingBox.showFloatingBox(
//     //           context,
//     //           position: details.globalPosition,
//     //           customChild: Column(
//     //             children: [
//     //               Row(
//     //                 children: [
//     //                   VecIcon(
//     //                     assetPath:
//     //                         'assets/svg/filetree/folder-open-outline.svg',
//     //                     size: 14,
//     //                     // color: Colors.amber,
//     //                   ),
//     //                   Text(' open'),
//     //                 ],
//     //               ),
//     //             ],
//     //           ),
//     //         );
//     //       },
//     //       child: widget.widget,
//     //     ),
//     //   ),
//     // );

//     // return ValueListenableBuilder(
//     //   valueListenable: selected,
//     //   builder: (context, isSelected, child) {
//     //     return Container(
//     //       color: isSelected ? Colors.grey : Colors.white,
//     //       // color: _setColor(context),
//     //       child: MouseRegion(
//     //         cursor: SystemMouseCursors.click,
//     //         onEnter: (event) {
//     //           // setState(() {
//     //           //   _isHover = true;
//     //           // });
//     //         },
//     //         onHover: (event) {
//     //           // if (_timer?.isActive ?? false) return;
//     //           // _floatingBoxController.hideFloatingBox();
//     //           // _floatingBoxController.showFloatingBox(
//     //           //   context,
//     //           //   position: Offset(
//     //           //     event.position.dx + 10,
//     //           //     event.position.dy + 10,
//     //           //   ),
//     //           //   clickToClose: false,
//     //           //   customChild: widget.floatingBox,
//     //           // );
//     //           // _timer = Timer(
//     //           //   const Duration(milliseconds: 30),
//     //           //   () => _timer = null,
//     //           // );
//     //         },
//     //         onExit: (event) {
//     //           // _timer?.cancel();
//     //           // _floatingBoxController.hideFloatingBox();
//     //           // setState(() {
//     //           //   _isHover = false;
//     //           // });
//     //         },
//     //         child: GestureDetector(
//     //           onDoubleTap: () {
//     //             // print("click item ${widget.index}");
//     //             // if (tagItem
//     //             //         .sftpUtils
//     //             //         ?.fileList[widget.index]
//     //             //         .attr
//     //             //         .isDirectory ??
//     //             //     false) {
//     //             //   appstate.setActiveTagRemotePathAndUpdateList(
//     //             //     '${tagItem.sftpUtils?.currentPath}/${tagItem.sftpUtils?.fileList[widget.index].filename}',
//     //             //   );
//     //             // }
//     //           },
//     //           onTap: () {
//     //             // print('click ${DateTime.now()}');
//     //             fileTreeState.setIndex(widget.index);
//     //             // print('clicked ${DateTime.now()}');
//     //           },
//     //           onSecondaryTapUp: (details) {
//     //             // print('right click');
//     //             // _rightFloatingBox.showFloatingBox(
//     //             //   context,
//     //             //   position: details.globalPosition,
//     //             //   customChild: Column(
//     //             //     children: [
//     //             //       Row(
//     //             //         children: [
//     //             //           VecIcon(
//     //             //             assetPath:
//     //             //                 'assets/svg/filetree/folder-open-outline.svg',
//     //             //             size: 14,
//     //             //             // color: Colors.amber,
//     //             //           ),
//     //             //           Text(' open'),
//     //             //         ],
//     //             //       ),
//     //             //     ],
//     //             //   ),
//     //             // );
//     //           },
//     //           child: widget.widget,
//     //         ),
//     //       ),
//     //     );
//     //   },
//     //   child: ,
//     // );
//   }
// }
