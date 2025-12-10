import 'package:flutter/material.dart';
import 'package:frequent_answer_question_widget/faq/faq_mode.dart';

class FaqController<T> extends ChangeNotifier {
  /// 模式
  FaqMode faqMode;

  /// 背景颜色
  Color backgroundColor;

  /// 数据集
  List<T> data;

  FaqController({
    this.faqMode = FaqMode.single,
    this.backgroundColor = Colors.transparent,
    this.data = const [],
  }) {
    initEvents();
  }

  /// 初始化
  void initEvents() {}

  /// 释放资源
  void clearEvents() {}

  int get itemCount => data.length;

  /// 设置模式
  void setFaqMode(FaqMode faqMode) {
    this.faqMode = faqMode;
    notifyListeners();
  }

  /// 设置背景颜色
  void setBackgroundColor(Color backgroundColor) {
    this.backgroundColor = backgroundColor;
    notifyListeners();
  }

  /// 设置数据集
  void setNewData(List<T> data) {
    this.data = data;
    notifyListeners();
  }

  void addNewItem(T item) {
    this.data.add(item);
    notifyListeners();
  }

  void addNewItems(List<T> item) {
    this.data.addAll(item);
    notifyListeners();
  }

  void clearData() {
    this.data.clear();
    notifyListeners();
  }

  void removeItem(int index) {
    if (this.data.length > index) {
      this.data.removeAt(index);
      notifyListeners();
    }
  }

  /// 通知刷新
  void notifyChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();

    clearEvents();
  }
}
