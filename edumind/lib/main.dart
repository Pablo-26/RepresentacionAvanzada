import 'package:edumind/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/routes/app_pages.dart';
import 'app/core/bindings/initial_bindings.dart';

void main() {
  runApp(EdumindApp());
}

class EdumindApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'EDUMIND',
      initialRoute: AppRoutes.HOME,
      getPages: AppPages.pages,
      debugShowCheckedModeBanner: false,
      initialBinding: InitialBindings(),  
    );
  }
}