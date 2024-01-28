import 'package:flukki/home/widgets/generate_tests_dialog.dart';
import 'package:flukki/home/widgets/settings_dialog.dart';
import 'package:flutter/material.dart';

import '../../current_project/controllers/current_project_controller.dart';

class Header extends StatelessWidget {
  final openAIApiKeyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (currentProjectController.openAIKey != null &&
        openAIApiKeyController.text.isEmpty) {
      openAIApiKeyController.text = currentProjectController.openAIKey ?? '';
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                    'Current project: ${currentProjectController.currentProjectPath?.split('/').last ?? 'Not set (required)'}'),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: () => currentProjectController.clearProject(),
                  child: const Text('Close project'),
                ),
              ],
            ),
          ),
          Row(
            children: [
              TextButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => GenerateTestsDialog(),
                ),
                child: const Text('Generate unit tests'),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => SettingsDialog(),
                  );
                },
                icon: Icon(Icons.settings),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
