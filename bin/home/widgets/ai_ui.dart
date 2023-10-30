import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../ai/controllers/flukki_brain_controller.dart';
import '../controllers/current_project_controller.dart';

class AiUi extends StatefulWidget {
  @override
  State<AiUi> createState() => _AiUiState();
}

class _AiUiState extends State<AiUi> {
  final outputScrollController = ScrollController();

  final searchController = TextEditingController();
  final openAIApiKeyController = TextEditingController();

  var files = [];

  @override
  void initState() {
    super.initState();
    openAIApiKeyController.text = currentProjectController.openAIKey ?? '';
    files = currentProjectController.getCurrentProjectDartFilesToTest();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          try {
            outputScrollController.animateTo(
                outputScrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 100),
                curve: Curves.easeInOut);
          } catch (_) {}
        });
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16, top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Current OpenAI key:'),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 200,
                    height: 24,
                    child: TextField(
                      controller: openAIApiKeyController,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 0),
                        hintText: currentProjectController.openAIKey ??
                            'Not set (required)',
                        border: const OutlineInputBorder(),
                      ),
                      style: const TextStyle(fontSize: 12, height: 1.2),
                      onChanged: (value) {
                        setState(
                          () {
                            openAIApiKeyController.text = value;
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed: () => currentProjectController
                        .saveOpenAIKey(openAIApiKeyController.text),
                    style: currentProjectController.currentProjectPath == null
                        ? null
                        : TextButton.styleFrom(primary: Colors.grey),
                    child: const Text('Save key'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                      'Current project: ${currentProjectController.currentProjectPath?.split('/').last ?? 'Not set (required)'}'),
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed: () => currentProjectController.chooseProject(),
                    style: currentProjectController.currentProjectPath == null
                        ? null
                        : TextButton.styleFrom(primary: Colors.grey),
                    child: const Text('Set project'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                      'Dart SDK: ${currentProjectController.dartSdkPath ?? 'Not set (required)'}'),
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed: () =>
                        currentProjectController.chooseDartSdkPath(),
                    style: currentProjectController.dartSdkPath == null
                        ? null
                        : TextButton.styleFrom(primary: Colors.grey),
                    child: const Text('Set Dart SDK Path'),
                  ),
                ],
              ),
            ),
            if (currentProjectController.isEverythingPrepared) ...[
              Expanded(
                // height: 300,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextField(
                                controller: searchController,
                                decoration: const InputDecoration(
                                  hintText: 'Search',
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (value) {
                                  setState(
                                    () {
                                      files = currentProjectController
                                          .getCurrentProjectDartFilesToTest()
                                          .where((element) => element
                                              .toLowerCase()
                                              .contains(value.toLowerCase()))
                                          .toList();
                                    },
                                  );
                                },
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                itemCount: files.length,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  final file = files[index];
                                  final pathWithoutProject = file.split(
                                      currentProjectController
                                          .currentProjectPath!)[1];
                                  return Card(
                                    color: Colors.grey[200],
                                    child: ListTile(
                                      title: Text(pathWithoutProject),
                                      trailing: Obx(
                                        () => ElevatedButton(
                                          onPressed:
                                              flukkiBrainController.isWorking
                                                  ? null
                                                  : () => startGeneration(file),
                                          child: Text(
                                              flukkiBrainController.isWorking
                                                  ? 'Generating tests...'
                                                  : 'Generate tests'),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          scrollController: outputScrollController,
                          controller: TextEditingController()
                            ..text = flukkiBrainController.output,
                          expands: true,
                          readOnly: true,
                          maxLines: null,
                          // minLines: 15,
                          textAlign: TextAlign.left,
                          textAlignVertical: TextAlignVertical.top,
                          decoration: const InputDecoration(
                            hintText: 'Output',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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

  Future<void> startGeneration(String path) async {
    try {
      flukkiBrainController.isWorking = true;
      await flukkiBrainController.start(path);
      flukkiBrainController.isWorking = false;
    } catch (e) {
      flukkiBrainController.isWorking = false;
      flukkiBrainController.addOutputLine(e.toString());
    }
  }
}
