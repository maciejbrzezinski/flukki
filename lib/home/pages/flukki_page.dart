import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/current_project/current_project_controller.dart';
import '../widgets/ai_ui.dart';

class FlukkiPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        if (currentProjectController.loading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        return Scaffold(
          body: Column(
            children: [Expanded(child: AiUi())],
          ),
        );
      },
    );
  }
}
