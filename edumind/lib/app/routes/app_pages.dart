import 'package:edumind/app/presentation/modules/graph/graph_page.dart';
import 'package:edumind/app/presentation/modules/resources/resource_page.dart';
import 'package:get/get.dart';
import '../presentation/modules/home/home_page.dart';
import '../presentation/modules/category/category_page.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.HOME,
      page: () => HomePage(),
    ),
    GetPage(
      name: AppRoutes.CATEGORY,
      page: () => CategoryPage(),
    ),
    GetPage(
      name: AppRoutes.RESOURCE,
      page: () => ResourcePage(),
    ),
  ];
}
