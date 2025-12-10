import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

class FaqUtil {
  /// Widget 转 Image
  static Future<Uint8List?> buildGenericImage<T>({
    required T data,
    required Widget Function(T data) itemBuilder,
    required BuildContext context,
    double pixelRatio = 2,
  }) async {
    try {
      final overlay = Overlay.of(context);

      final repaintKey = GlobalKey();
      final widget = RepaintBoundary(
        key: repaintKey,
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: itemBuilder(data),
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

      /// 等待渲染完成
      await waitRepaintBoundaryPainted(repaintKey).timeout(const Duration(milliseconds: 500));

      final boundary = repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

      final image = await boundary.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      entry.remove();
      return byteData?.buffer.asUint8List();
    } catch (e) {
      return null;
    }
  }

  static Future<void> waitRepaintBoundaryPainted(
    GlobalKey repaintKey, {
    Duration timeout = const Duration(milliseconds: 500),
  }) async {
    Completer<void> completer = Completer<void>();
    bool timedOut = false;

    // 启动超时计时器
    Future.delayed(timeout).then((_) {
      if (!completer.isCompleted) {
        timedOut = true;
        completer.completeError(TimeoutException(
          "Wait for RepaintBoundary paint timed out after $timeout",
        ));
      }
    });

    void checkPaint(_) {
      if (timedOut) return;

      final renderObj = repaintKey.currentContext?.findRenderObject();

      if (renderObj is RenderRepaintBoundary && !renderObj.debugNeedsPaint) {
        if (!completer.isCompleted) completer.complete();
      } else {
        // 下一帧继续检查
        SchedulerBinding.instance.addPostFrameCallback(checkPaint);
      }
    }

    // 从下一帧开始检查
    SchedulerBinding.instance.addPostFrameCallback(checkPaint);

    return completer.future;
  }
}
