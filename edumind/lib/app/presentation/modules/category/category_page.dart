import 'package:edumind/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'category_controller.dart';

class CategoryPage extends StatelessWidget {
  final controller = Get.put(CategoryController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(controller.category),
        backgroundColor: Color.fromRGBO(238, 242, 245, 1),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              HugeIcons.strokeRoundedArrowLeft01,
              size: 34,
            )),
      ),
      backgroundColor: Color.fromRGBO(238, 242, 245, 1),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (val) => controller.query.value = val,
              decoration: InputDecoration(
                hintText: 'Buscar evento...',
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                filled: true,
                fillColor: Color.fromARGB(255, 245, 247, 250),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(20.0), // 🔹 Bordes redondeados
                  borderSide: BorderSide.none, // 🔹 Sin borde visible
                ),
                hintStyle: TextStyle(color: Colors.grey[500]),
              ),
              style: TextStyle(fontSize: 16.0),
            ),
          ),
          Expanded(
            child: Obx(
              () => Padding(
                padding: const EdgeInsets.all(
                  16.0,
                ),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: controller.resources.length,
                  itemBuilder: (_, i) {
                    final item = controller.resources[i];
                    return GestureDetector(
                      onTap: () => Get.toNamed(
                        AppRoutes.RESOURCE,
                        arguments: {
                          'uri': item.uri,
                          'label': item.label,
                        },
                      ),
                      child: Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(getIconForCategory(controller.category),
                                      size: 32),
                                  Spacer(),
                                  Icon(
                                    HugeIcons.strokeRoundedStar,
                                    size: 20,
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(
                                item.label,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData getIconForCategory(String category) {
    switch (category) {
      case 'Eventos':
        return HugeIcons.strokeRoundedSword03;
      case 'Lugares':
        return HugeIcons.strokeRoundedLocation05;
      case 'Personajes':
        return HugeIcons.strokeRoundedUserFullView;
      case 'Instituciones':
        return HugeIcons.strokeRoundedHut;
      default:
        return HugeIcons.strokeRoundedMolecules;
    }
  }
}
