import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/brain/flukki_brain_controller.dart';
import '../../core/output/controllers/output_controller.dart';
import '../../current_project/controllers/current_project_controller.dart';

class GenerateTestsDialog extends StatefulWidget {
  @override
  State<GenerateTestsDialog> createState() => _GenerateTestsDialogState();
}

class _GenerateTestsDialogState extends State<GenerateTestsDialog> {
  final searchController = TextEditingController();
  var files = [];

  @override
  void initState() {
    super.initState();
    files = currentProjectController.getCurrentProjectDartFilesToTest();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        height: 400,
        width: 500,
        child: Column(
          children: [
            const Text('Generate tests', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 16),
            const Text('Choose the file you want to generate tests for:'),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  hintText: 'Search',
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
                      currentProjectController.currentProjectPath!)[1];
                  return Card(
                    child: ListTile(
                      title: Text(pathWithoutProject),
                      trailing: Obx(
                        () => ElevatedButton(
                          onPressed: flukkiBrainController.isWorking
                              ? null
                              : () {
                                startGeneration(file);
                                Navigator.pop(context);
                              },
                          child: Text(flukkiBrainController.isWorking
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
    );
  }

  Future<void> startGeneration(String path) async {
    try {
      flukkiBrainController.isWorking = true;
      await flukkiBrainController.generateTests(path);
      flukkiBrainController.isWorking = false;
    } catch (e) {
      flukkiBrainController.isWorking = false;
      addOutputLine(e.toString());
    }
  }
}
