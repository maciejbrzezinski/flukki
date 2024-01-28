import 'package:flutter/material.dart';

import '../../current_project/controllers/current_project_controller.dart';

class SettingsDialog extends StatelessWidget {
  SettingsDialog({Key? key}) : super(key: key);

  final openAIApiKeyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (currentProjectController.openAIKey != null &&
        openAIApiKeyController.text.isEmpty) {
      openAIApiKeyController.text = currentProjectController.openAIKey ?? '';
    }

    return Dialog(
      child: Container(
        height: 300,
        width: 500,
        child: Column(
          children: [
            const Text('Settings', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 16),
            const Text('OpenAI key:'),
            const SizedBox(height: 4),
            SizedBox(
              width: 400,
              height: 24,
              child: TextField(
                controller: openAIApiKeyController,
                decoration: const InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  hintText: 'Not set (required)',
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, height: 1.2),
              ),
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () => currentProjectController
                  .saveOpenAIKey(openAIApiKeyController.text),
              child: const Text('Save OpenAI key'),
            ),
            const SizedBox(height: 32),
            const Text('Dart SDK path:'),
            const SizedBox(height: 4),
            Text(
                '${currentProjectController.dartSdkPath ?? 'Not set (required)'}'),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () => currentProjectController.chooseDartSdkPath(),
              child: const Text('Set Dart SDK Path'),
            ),
          ],
        ),
      ),
    );
  }
}
