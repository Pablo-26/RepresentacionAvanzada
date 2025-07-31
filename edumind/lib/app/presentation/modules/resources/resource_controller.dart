// lib/presentation/modules/resources/resource_controller.dart
import 'package:edumind/app/presentation/modules/graph/graph_page.dart' as gp;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphview/GraphView.dart' as gv;
import '../../../data/models/resource_detail_model.dart';
import '../../../data/providers/dbpedia_provider.dart';
import '../../../data/providers/wikidata_provider.dart';
import 'package:edumind/app/data/models/graphnodemodel .dart' as gm;

class ResourceController extends GetxController {
  final dbpediaProvider = DBPediaProvider();
  final wikidataProvider = WikidataProvider();

  final details = <ResourceDetail>[].obs;
  final graph = gv.Graph().obs;
  final builder = gv.BuchheimWalkerConfiguration();
  final isLoading = true.obs;
  final showGraph = false.obs;
  final title = ''.obs;
  // Map para guardar labels de nodos
  final labels = <String, String>{}.obs;

  // Map para guardar labels de las relaciones/aristas con clave 'origen_destino'
  final edgeLabels = <String, String>{}.obs;

  late final String uri;
  late final String resourceLabel;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map;
    uri = args['uri'];
    resourceLabel = args['label'];
    title.value = resourceLabel;
    loadData();
  }

  void toggleView() {
    showGraph.toggle();
  }

  void loadData() async {
    isLoading.value = true;

    try {
      if (uri.contains("wikidata.org")) {
        details.assignAll(await wikidataProvider.fetchResourceDetails(uri));
      } else {
        details.assignAll(await dbpediaProvider.fetchResourceDetails(uri));
      }

      final g = gv.Graph();
      final root = gv.Node.Id(uri);
      g.addNode(root);

      labels[uri] = resourceLabel;

      for (var detail in details) {
        final node = gv.Node.Id(detail.value);
        g.addNode(node);
        g.addEdge(root, node);

        labels[detail.value] = detail.valueLabel ?? detail.value;

        // Guarda el label de la relación/arista, usando key "uri_del_nodo_origen_uri_del_nodo_destino"
        edgeLabels['$uri|${detail.value}'] = detail.propertyLabel;
      }

      graph.value = g;
    } catch (e) {
      print("Error al cargar detalles: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Dentro de ResourceController:
  List<gm.Node> getGraphNodes() {
    final List<gm.Node> nodes = [];
    nodes.add(gm.Node(uri, resourceLabel, Offset(100, 300)));

    double startY = 150;
    final double gapY = 80;
    for (int i = 0; i < details.length; i++) {
      final d = details[i];
      final label = d.valueLabel ?? d.value;
      nodes.add(gm.Node(d.value, label, Offset(350, startY + i * gapY)));
    }
    return nodes;
  }

  List<gm.Edge> getGraphEdges() {
    final List<gm.Edge> edges = [];
    for (var d in details) {
      final label = d.propertyLabel.isNotEmpty ? d.propertyLabel : 'relación';
      edges.add(gm.Edge(uri, d.value, label));
    }
    return edges;
  }
}
