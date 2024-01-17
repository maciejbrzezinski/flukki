import 'package:flutter/material.dart';

import '../controllers/output_controller.dart';

class OutputTextField extends StatelessWidget {
  final outputScrollController = ScrollController();

  OutputTextField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      try {
        outputScrollController.animateTo(
            outputScrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeInOut);
      } catch (_) {}
    });
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        scrollController: outputScrollController,
        controller: TextEditingController()..text = outputController.output,
        expands: true,
        readOnly: true,
        maxLines: null,
        textAlign: TextAlign.left,
        textAlignVertical: TextAlignVertical.top,
        decoration: const InputDecoration(
          hintText: 'Output',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
