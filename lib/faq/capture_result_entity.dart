import 'dart:typed_data';

class CaptureResultEntity {
  /// 截图
  Uint8List imageBytes;

  /// 图片宽度(单位像素)
  double width;

  /// 图片高度(单位像素)
  double height;

  CaptureResultEntity({
    required this.imageBytes,
    required this.width,
    required this.height,
  });
}
