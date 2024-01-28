import 'package:flukki/core/output/widgets/output_textfield.dart';
import 'package:flukki/home/controllers/status_controller.dart';
import 'package:flukki/home/widgets/current_status.dart';
import 'package:flukki/home/widgets/footer.dart';
import 'package:flukki/home/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../core/brain/flukki_brain_controller.dart';
import '../../core/output/controllers/output_controller.dart';
import '../../current_project/controllers/current_project_controller.dart';

class AiUi extends StatefulWidget {
  @override
  State<AiUi> createState() => _AiUiState();
}

class _AiUiState extends State<AiUi> {
  final taskController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Header(),
          ),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 108,
                  child: TextField(
                    controller: taskController,
                    maxLines: 4,
                    minLines: 4,
                    decoration: InputDecoration(
                      hintText:
                          'Describe precisely what you want to change in your app',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 140,
                height: 108,
                child: Builder(builder: (context) {
                  final isWorking = false.obs;
                  return Obx(() {
                    return ElevatedButton(
                        onPressed: isWorking.value
                            ? null
                            : () async {
                                try {
                                  isWorking.value = true;
                                  await flukkiBrainController
                                      .start(taskController.text);
                                  isWorking.value = false;
                                } catch (e) {
                                  isWorking.value = false;
                                  addOutputLine(e.toString());
                                  statusController
                                      .finishWithError(e.toString());
                                }
                              },
                        child: Text(isWorking.value ? 'Working...' : 'Start'));
                  });
                }),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: CurrentStatus(),
          ),
          Footer(),
        ],
      ),
    );
  }
}
