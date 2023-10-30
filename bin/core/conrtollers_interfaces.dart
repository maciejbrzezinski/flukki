import 'package:get/get.dart';

abstract class DependentController<T extends GetxController>
    extends LoadingController {
  T getDependency();

  @override
  void onInit() {
    super.onInit();
    getDependency().addListenerId('update', () {
      loading = true;
      loadData().then((value) {
        update(['update']);
        return loading = false;
      });
    });
    getDependency().addListenerId('clear', () {
      clear();
      update(['clean']);
    });
  }

  Future<void> loadData();

  void clear();
}

T handleDependency<T>(T Function() create) {
  if (Get.isRegistered<T>()) {
    return Get.find<T>();
  } else {
    return Get.put(create());
  }
}

/// typ kontrolera, który ładuje się tylko raz, przy starcie aplikacji
/// [loadData] duje dane przy starcie aplikacji
abstract class RegularController extends LoadingController {
  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    loading = true;
    await loadData();
    loading = false;
  }

  Future<void> loadData();
}

class LoadingController extends GetxController {
  final _loading = RxBool(false);

  set loading(bool value) => _loading.value = value;

  bool get loading => _loading.value;
}
