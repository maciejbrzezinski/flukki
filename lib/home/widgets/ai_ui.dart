import 'package:flukki/core/output/widgets/output_textfield.dart';
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
    return Obx(
      () {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Header(),
            if (currentProjectController.isEverythingPrepared) ...[
              Expanded(
                // height: 300,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 16.0),
                                  child: TextField(
                                    controller: taskController,
                                    maxLines: 4,
                                    minLines: 4,
                                    decoration: InputDecoration(
                                      hintText:
                                          'Don\'t just stand there, code something!',
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 120,
                                height: 48,
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
                                                      .start(
                                                          taskController.text);
                                                  isWorking.value = false;
                                                } catch (e) {
                                                  isWorking.value = false;
                                                  addOutputLine(e.toString());
                                                }
                                              },
                                        child: Text(isWorking.value
                                            ? 'Working...'
                                            : 'Do the task'));
                                  });
                                }),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: OutputTextField(),
              ),
            ],
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => launchUrlString(
                        'https://github.com/maciejbrzezinski/flukki'),
                    style: TextButton.styleFrom(primary: Colors.grey),
                    child: const Text(
                        'https://github.com/maciejbrzezinski/flukki'),
                  ),
                  TextButton(
                    onPressed: () => launchUrlString('https://flukki.com'),
                    style: TextButton.styleFrom(primary: Colors.grey),
                    child: const Text('https://flukki.com'),
                  )
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
