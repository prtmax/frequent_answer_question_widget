import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class FaqUtil {
  /// Widget转Image
  static Future<Uint8List?> buildGenericImage<T>({
    required T data,
    required Widget Function(T data) itemBuilder,
    required BuildContext context,
    Future<void> Function(T data)? preCacheUtil,
    double pixelRatio = 2,
  }) async {
    OverlayEntry? entry;
    final repaintKey = GlobalKey();

    // 强制增加的底部安全边框，例如 4 像素，以补偿精度误差
    const double safetyPadding = 4.0;

    try {
      if (preCacheUtil != null) {
        await preCacheUtil(data);
      }
      final overlay = Overlay.of(context);

      // 1. 构建带有安全边框的 RepaintBoundary
      final widget = RepaintBoundary(
        key: repaintKey,
        child: Container(
          color: Colors.white, // 确保整个截图有一个白色基底
          child: Column(
            mainAxisSize: MainAxisSize.min, // 确保 Column 尽可能小
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width.floorToDouble(),
                child: itemBuilder(data), // 核心内容
              ),
              // 2. 底部安全区域：确保 RepaintBoundary 的高度多出 safetyPadding
              SizedBox(height: safetyPadding, child: const ColoredBox(color: Colors.white)),
            ],
          ),
        ),
      );

      // 将 Widget 放置在屏幕外
      entry = OverlayEntry(
        builder: (_) => Positioned(
          left: 0,
          top: MediaQuery.of(context).size.height,
          child: widget,
        ),
      );

      overlay.insert(entry);

      // 确保渲染已完成，解决异步加载或布局延迟，只用简单的延迟
      await WidgetsBinding.instance.endOfFrame;
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final boundary = repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

      // --- 核心截图逻辑 ---
      final image = await boundary.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final fullImageBytes = byteData?.buffer.asUint8List();

      if (fullImageBytes == null) {
        return null;
      }

      // --- 裁剪多余的安全边框 ---
      final imgCodec = await ui.instantiateImageCodec(fullImageBytes);
      final frame = await imgCodec.getNextFrame();
      final fullImage = frame.image;

      // 3. 计算最终目标高度：去除 safetyPadding * pixelRatio
      final targetHeight = (fullImage.height - safetyPadding * pixelRatio).round();

      if (targetHeight <= 0) {
        return fullImageBytes;
      }

      // 使用 Canvas 进行裁剪
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder, Rect.fromLTWH(0, 0, fullImage.width.toDouble(), targetHeight.toDouble()));

      // 绘制时，只取上部区域（即去除底部的 safetyPadding 区域）
      canvas.drawImageRect(
        fullImage,
        Rect.fromLTWH(0, 0, fullImage.width.toDouble(), targetHeight.toDouble()), // 源矩形：只取上部区域
        Rect.fromLTWH(0, 0, fullImage.width.toDouble(), targetHeight.toDouble()), // 目标矩形：填充整个画布
        Paint(),
      );

      final croppedPicture = recorder.endRecording();
      final croppedImage = await croppedPicture.toImage(fullImage.width, targetHeight);
      final croppedByteData = await croppedImage.toByteData(format: ui.ImageByteFormat.png);

      return croppedByteData?.buffer.asUint8List();
    } catch (e) {
      return null;
    } finally {
      entry?.remove();
    }
  }
}
