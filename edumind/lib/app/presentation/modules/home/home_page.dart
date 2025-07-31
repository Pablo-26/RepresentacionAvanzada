import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'home_controller.dart';
import '../../widgets/category_card.dart';

class HomePage extends StatelessWidget {
  final controller = Get.put(HomeController());
  final double progress = 0.5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(238, 242, 245, 1),
      appBar: AppBar(
        toolbarHeight: 100,
        title: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Buenas tardes',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 18,
                  color: const Color.fromARGB(255, 137, 137, 137),
                ),
              ),
              SizedBox(
                height: 4,
              ),
              Text(
                'Pablo David',
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        backgroundColor: Color.fromRGBO(238, 242, 245, 1),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 30),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Color.fromARGB(255, 137, 137, 137),
                  width: 1,
                ),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () {},
                padding: EdgeInsets.all(8),
                color: Color.fromARGB(255, 137, 137, 137),
                icon: Icon(
                  HugeIcons.strokeRoundedNotification02,
                  size: 32,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.all(8),
              padding: EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 18,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bienvenido, Explorador!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Text(
                    'Descubre la riqueza de historia de cultura del Ecuador de manera interactiva y divertida.',
                    style: TextStyle(
                        fontSize: 13,
                        color: const Color.fromARGB(255, 126, 126, 126)),
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Text(
                            '47',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: Color.fromRGBO(37, 99, 235, 1),
                            ),
                          ),
                          Text(
                            'Temas\nExplorados',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: const Color.fromARGB(255, 181, 181, 181),
                            ),
                          )
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            '12',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: Color.fromRGBO(5, 150, 105, 1),
                            ),
                          ),
                          Text(
                            'Favoritos\n ',
                            style: TextStyle(
                              fontSize: 12,
                              color: const Color.fromARGB(255, 181, 181, 181),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: controller.categories
                    .map((cat) => CategoryCard(
                          name: cat['name'] is String
                              ? cat['name'] as String
                              : 'Nombre no válido',
                          icon: cat['icon'] is IconData
                              ? cat['icon'] as IconData
                              : Icons.error, // Validación y cast
                          color: cat['color'] is Color
                              ? cat['color'] as Color
                              : Colors.grey, // Validación y cast
                        ))
                    .toList(),
              ),
            ),
            /* Container(
              margin: EdgeInsets.all(8),
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tu progreso',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: const Color.fromARGB(255, 126, 126, 126),
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Stack(
                    children: [
                      // Barra de fondo personalizada con grosor
                      Container(
                        height: 24,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 238, 242, 245),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),

                      // Barra de progreso
                      FractionallySizedBox(
                        widthFactor: progress,
                        child: Container(
                          height: 24,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [
                              const Color.fromRGBO(5, 150, 105, 1),
                              const Color.fromRGBO(37, 99, 235, 1),
                            ]),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),

                      Positioned(
                        left: MediaQuery.of(context).size.width * progress - 38,
                        top: 0,
                        child: Icon(
                          HugeIcons
                              .strokeRoundedWorkoutRun, // 🔹 Puedes usar otro ícono o imagen
                          size: 24,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ), */
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        elevation: 4,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        selectedIconTheme: const IconThemeData(size: 28),
        unselectedIconTheme: const IconThemeData(size: 24),
        selectedItemColor: const Color.fromRGBO(37, 99, 235, 1),
        unselectedItemColor: const Color.fromARGB(255, 126, 126, 126),
        onTap: (index) {
          // Aquí manejas la navegación entre tabs
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(HugeIcons.strokeRoundedHome03),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(HugeIcons.strokeRoundedStar),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(
            icon: Icon(HugeIcons.strokeRoundedUser03),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
