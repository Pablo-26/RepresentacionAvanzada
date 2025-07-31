import 'package:get/get.dart';
// Importa graphview con un prefijo
import 'package:graphview/GraphView.dart' as gv;
import '../../../data/models/resource_detail_model.dart';
import '../../../data/providers/dbpedia_provider.dart';

class ResourceGraphController extends GetxController {
  final isLoading = true.obs;
  // Usa el prefijo 'gv' para Graph
  final graph = gv.Graph().obs;
  final provider = DBPediaProvider();

  // Usa el prefijo 'gv' para el algoritmo
  //final builder = gv.FruchtermanReingoldAlgorithm(iterations: 2500);
  final builder = gv.BuchheimWalkerConfiguration()
  ..siblingSeparation = (20)
  ..levelSeparation = (40)
  ..subtreeSeparation = (30)
  ..orientation = gv.BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM;



  @override
  void onInit() {
    super.onInit();
    final String resourceUri = Get.arguments;
    fetchAndBuildConfig(resourceUri);
  }

  void fetchAndBuildConfig(String resourceUri) async {
    try {
      isLoading.value = true;
      final List<ResourceDetail> details =
          await provider.fetchResourceDetails(resourceUri);
      buildGraph(details, resourceUri);
    } catch (e) {
      print('Error al construir el grafo: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void buildGraph(List<ResourceDetail> details, String centralResourceUri) {
    // Usa el prefijo 'gv' para Graph y Node
    final newGraph = gv.Graph();
    final Map<String, gv.Node> nodeMap = {};

    final centralNodeLabel =
        centralResourceUri.split('/').last.replaceAll('_', ' ');
    final centralNode = gv.Node.Id(centralResourceUri);
    nodeMap[centralResourceUri] = centralNode;
    newGraph.addNode(centralNode);

    for (var detail in details) {
      gv.Node valueNode;
      if (nodeMap.containsKey(detail.value)) {
        valueNode = nodeMap[detail.value]!;
      } else {
        valueNode = gv.Node.Id(detail.value);
        nodeMap[detail.value] = valueNode;
        newGraph.addNode(valueNode);
      }

      newGraph.addEdge(centralNode, valueNode);
    }

    graph.value = newGraph;
  }
}
