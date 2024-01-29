import 'package:flukki/core/output/controllers/output_controller.dart';
import 'package:flukki/core/utils/di_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

StatusController statusController = handleDependency(() => StatusController());

class StatusController {
  final _currentJob = RxString('not started yet');
  final _currentStep = RxString('waiting for instructions');
  final _progress = Rx<Progress>(Progress.notStarted);
  final _jobStartTimestamp = Rxn<DateTime>();
  final _jobFinishTimestamp = Rxn<DateTime>();

  String get currentJob => _currentJob.value;

  String get currentStep => _currentStep.value;

  Progress get progress => _progress.value;

  set currentJob(String job) {
    _currentJob.value = job;
    _progress.value = Progress.inProgress;
    _jobStartTimestamp.value = DateTime.now();
    _jobFinishTimestamp.value = null;
  }

  set currentStep(String step) {
    _currentStep.value = step;
  }

  void finish(String message) {
    addOutputLine(message);
    _currentStep.value = message;
    _progress.value = Progress.done;
    _jobFinishTimestamp.value = DateTime.now();
  }

  void finishWithError(String error) {
    addOutputLine(error);
    _currentStep.value = error;
    _progress.value = Progress.error;
    _jobFinishTimestamp.value = DateTime.now();
  }

  int get durationInSeconds {
    if (_jobStartTimestamp.value == null) {
      return 0;
    }
    return (_jobFinishTimestamp.value ?? DateTime.now())
        .difference(_jobStartTimestamp.value!)
        .inSeconds;
  }
}

enum Progress {
  done(Colors.green, 'Done', Icons.check_circle_outline),
  error(Colors.red, 'Error', Icons.error_outline),
  inProgress(Colors.yellow, 'In progress', Icons.timer_outlined),
  notStarted(Colors.grey, 'Not started', Icons.wb_sunny_outlined);

  const Progress(this.color, this.title, this.icon);

  final String title;
  final Color color;
  final IconData icon;
}
