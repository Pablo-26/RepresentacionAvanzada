import 'package:edumind/app/data/providers/dbpedia_provider.dart';
import 'package:get/get.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    // Proveedor de datos para DBpedia disponible en toda la app
    Get.lazyPut<DBPediaProvider>(() => DBPediaProvider(), fenix: true);
  }
}
