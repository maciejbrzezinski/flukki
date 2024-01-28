import 'package:flukki/current_project/pages/choose_project_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../current_project/controllers/current_project_controller.dart';
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
        if (currentProjectController.currentProjectPath == null) {
          return Scaffold(
            body: Column(
              children: [Expanded(child: ChooseProjectPage())],
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
