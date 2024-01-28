import 'package:flukki/core/utils/di_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

StatusController statusController = handleDependency(() => StatusController());

class StatusController {
  final _currentJob = RxString('not started yet');
  final _currentStep = RxString('waiting for instructions');
  final _progress = Rx<Progress>(Progress.notStarted);

  String get currentJob => _currentJob.value;

  String get currentStep => _currentStep.value;

  Progress get progress => _progress.value;

  set currentJob(String job) {
    _currentJob.value = job;
    _progress.value = Progress.inProgress;
  }

  set currentStep(String step) {
    _currentStep.value = step;
  }

  void finish(String message) {
    _currentStep.value = message;
    _progress.value = Progress.done;
  }

  void finishWithError(String error) {
    _currentStep.value = error;
    _progress.value = Progress.error;
  }
}

enum Progress {
  done(Colors.green, 'Done', Icons.check_circle_outline),
  error(Colors.red, 'Error', Icons.error_outline),
  inProgress(Colors.yellow, 'In progress', Icons.timer_outlined),
  notStarted(Colors.grey, 'Not started yet', Icons.wb_sunny_outlined);

  const Progress(this.color, this.title, this.icon);

  final String title;
  final Color color;
  final IconData icon;
}
