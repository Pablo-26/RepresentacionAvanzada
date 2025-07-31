// lib/presentation/modules/resources/resource_page.dart
import 'package:edumind/app/presentation/modules/graph/graph_page.dart';
import 'package:edumind/app/presentation/modules/resources/resource_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphview/GraphView.dart' as gv;
import 'package:url_launcher/url_launcher.dart';

class ResourcePage extends StatelessWidget {
  final controller = Get.put(ResourceController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.title.value)),
        backgroundColor: Color.fromARGB(255, 245, 247, 250),
        actions: [
          Obx(
            () => Switch(
              value: controller.showGraph.value,
              onChanged: (val) => controller.toggleView(),
              activeColor: Color.fromRGBO(5, 150, 105, 1),
            ),
          )
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Container(
              color: Color.fromARGB(255, 245, 247, 250),
              child: Center(child: CircularProgressIndicator()));
        }
        return controller.showGraph.value
            ? SimpleGraphView(
                nodes: controller.getGraphNodes(),
                edges: controller.getGraphEdges(),
              )
            : ResourceDetailListView();
      }),
    );
  }
}

class ResourceDetailListView extends StatelessWidget {
  final controller = Get.find<ResourceController>();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: controller.details.length,
      itemBuilder: (_, index) {
        final item = controller.details[index];

        final property = item.propertyLabel.isNotEmpty
            ? item.propertyLabel
            : item.propertyUri.split('/').last;

        final valueToShow =
            item.valueLabel.isNotEmpty ? item.valueLabel : item.value;

        final isLink = item.value.startsWith('http');

        return Container(
          color: const Color.fromARGB(255, 245, 247, 250),
          child: ListTile(
            title: Text(
              property,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(valueToShow),
            trailing: isLink ? const Icon(Icons.open_in_new) : null,
            onTap: isLink
                ? () async {
                    final url = Uri.parse(item.value);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    }
                  }
                : null,
          ),
        );
      },
    );
  }
}

class ResourceGraphView extends StatelessWidget {
  final controller = Get.find<ResourceController>();

  @override
  Widget build(BuildContext context) {
    // Configurar orientación y separaciones del grafo
    controller.builder
      ..siblingSeparation = 50
      ..levelSeparation = 70
      ..subtreeSeparation = 50
      ..orientation = gv.BuchheimWalkerConfiguration.ORIENTATION_LEFT_RIGHT;

    if (controller.graph.value.nodeCount() <= 1) {
      return Center(child: Text('No se encontraron relaciones para mostrar.'));
    }

    return Container(
      color: const Color.fromARGB(255, 245, 247, 250),
      child: InteractiveViewer(
        constrained: false,
        boundaryMargin:
            const EdgeInsets.symmetric(horizontal: 80, vertical: 100),
        minScale: 0.2,
        maxScale: 3.0,
        child: gv.GraphView(
          graph: controller.graph.value,
          algorithm: gv.BuchheimWalkerAlgorithm(
            controller.builder,
            gv.TreeEdgeRenderer(controller.builder),
          ),
          builder: (gv.Node node) {
            // Obtener ID del nodo (URI completa o valor)
            final String nodeId = node.key!.value as String;

            // Usar label amigable si está disponible, si no, extraer el ID legible
            final String label = controller.labels[nodeId] ??
                nodeId.split('/').last.replaceAll('_', ' ');

            // Estilo especial para el nodo raíz
            final bool isRoot =
                node == controller.graph.value.getNodeAtPosition(0);

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              constraints: const BoxConstraints(minWidth: 80, maxWidth: 140),
              decoration: BoxDecoration(
                color: isRoot ? Colors.blue.shade100 : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.grey.shade300, blurRadius: 4),
                ],
                border: Border.all(color: Colors.blue.shade300),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.blue.shade900,
                  fontWeight: isRoot ? FontWeight.bold : FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
                textAlign: TextAlign.center,
              ),
            );
          },
        ),
      ),
    );
  }
}
