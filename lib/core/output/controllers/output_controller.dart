import 'package:flukki/home/controllers/status_controller.dart';
import 'package:get/get.dart';

import '../../utils/di_utils.dart';

OutputController get outputController =>
    handleDependency(() => OutputController());

void addOutputLine(String line) {
  outputController.addOutputLine(line);
  if (line.isNotEmpty) {
    statusController.currentStep = line;
  }
}

class OutputController {
  final _output = RxString('');

  String get output => _output.value;

  void addOutputLine(String line) {
    _output.value = '${_output.value}$line\n';
  }
}
