import 'package:get/get.dart';

T handleDependency<T>(T Function() create) {
  if (Get.isRegistered<T>()) {
    return Get.find<T>();
  } else {
    return Get.put(create());
  }
}
