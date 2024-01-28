import 'package:flukki/core/output/widgets/output_textfield.dart';
import 'package:flukki/home/controllers/status_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' as g;

class CurrentStatus extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return g.Obx(
      () {
        final progress = statusController.progress;
        return Card(
            elevation: 0,
            margin: const EdgeInsets.all(0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                                child: Text(
                                    'Current job: ${statusController.currentJob}')),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                                child: Text(
                                    'Step: ${statusController.currentStep}')),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      TextButton(
                          style: TextButton.styleFrom(
                            primary: Colors.grey,
                          ),
                          onPressed: () => showDialog(
                              context: context,
                              builder: (_) => OutputTextField()),
                          child: Text('View full log')),
                      Chip(
                        label: Text(progress.title),
                        avatar: Icon(
                          progress.icon,
                          size: 16,
                        ),
                        backgroundColor: progress.color.withOpacity(.5),
                      ),
                    ],
                  ),
                ],
              ),
            ));
      },
    );
  }
}
