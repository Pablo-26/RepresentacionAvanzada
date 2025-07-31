import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

class HomeController extends GetxController {
  final categories = [
    {'name': 'Eventos', 'icon': HugeIcons.strokeRoundedSword03, 'color': const Color.fromRGBO(239, 68, 68, 1)},
    {'name': 'Personajes', 'icon': HugeIcons.strokeRoundedUserGroup02, 'color': const Color.fromRGBO(37, 99, 235, 1)},
    {'name': 'Lugares', 'icon': HugeIcons.strokeRoundedLocation03, 'color': const Color.fromRGBO(245, 158, 11, 1)},
    {'name': 'Instituciones', 'icon': HugeIcons.strokeRoundedBuilding03, 'color': const Color.fromRGBO(5, 150, 105, 1)},
  ];
}