import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class FaqUtil {
  /// Widget 转 Image
  static Future<Uint8List?> buildGenericImage<T>({
    required T data,
    required Widget Function(T data) itemBuilder,
    required BuildContext context,
    Future<void> Function(T data)? preCacheUtil,
    double pixelRatio = 2,
  }) async {
    try {
      if (preCacheUtil != null) {
        await preCacheUtil(data);
      }
      final overlay = Overlay.of(context);

      final repaintKey = GlobalKey();
      final extra = pixelRatio.ceil().toDouble();
      final widget = RepaintBoundary(
        key: repaintKey,
        child: Stack(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width.floorToDouble(),
              child: itemBuilder(data),
            ),
            // 补偿RepaintBoundary截图带来的高度精度损失问题
            Positioned(
              left: 0,
              right: 0,
              bottom: -extra,
              height: extra * 2,
              child: const ColoredBox(color: Colors.white),
            ),
          ],
        ),
      );

      final entry = OverlayEntry(
        builder: (_) => Positioned(
          left: 0,
          top: MediaQuery.of(context).size.height,
          child: widget,
        ),
      );

      overlay.insert(entry);

      await WidgetsBinding.instance.endOfFrame;
      // 加个保险
      await Future<void>.delayed(Duration.zero);

      final boundary = repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

      final image = await boundary.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      entry.remove();
      return byteData?.buffer.asUint8List();
    } catch (e) {
      return null;
    }
  }
}
