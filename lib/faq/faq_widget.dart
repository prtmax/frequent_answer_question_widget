import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frequent_answer_question_widget/faq/faq_controller.dart';
import 'package:frequent_answer_question_widget/faq/faq_mode.dart';

class FaqWidget<T> extends StatefulWidget {
  final FaqController? faqController;
  final Widget Function(FaqMode faqMode, int index, T data) itemBuilder;
  final List<T> data;

  const FaqWidget({
    super.key,
    required this.itemBuilder,
    this.faqController,
    this.data = const [],
  });

  @override
  State<FaqWidget<T>> createState() => _FaqWidgetState<T>();
}

class _FaqWidgetState<T> extends State<FaqWidget<T>> {
  late final FaqController faqController;

  @override
  void initState() {
    super.initState();

    faqController = widget.faqController ?? FaqController<T>();
    faqController.setNewData(widget.data);
  }

  @override
  void dispose() {
    super.dispose();

    faqController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: faqController,
      builder: (context, child) {
        if (faqController.faqMode == FaqMode.single) {
          return ListView.separated(
            padding: EdgeInsetsDirectional.symmetric(horizontal: 30.w, vertical: 10.w),
            itemCount: faqController.itemCount,
            itemBuilder: (context, index) {
              T item = faqController.data[index];
              return widget.itemBuilder(faqController.faqMode, index, item);
            },
            separatorBuilder: (context, index) {
              return SizedBox(
                height: 8.w,
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
