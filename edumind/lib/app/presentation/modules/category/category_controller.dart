import 'package:get/get.dart';
import '../../../data/models/resource_model.dart';
import '../../../data/providers/dbpedia_provider.dart';
import '../../../data/providers/wikidata_provider.dart';

class CategoryController extends GetxController {
  final dbpediaProvider = DBPediaProvider();
  final wikidataProvider = WikidataProvider();

  final resources = <ResourceModel>[].obs;
  final query = ''.obs;
  late final String category;

  @override
  void onInit() {
    super.onInit();
    category = Get.arguments as String? ?? '';
    fetchResources();
    debounce(query, (_) => fetchResources(), time: Duration(milliseconds: 500));
  }

  void fetchResources() async {
    try {
      List<ResourceModel> result = [];

      switch (category) {
        case 'Eventos':
          result = await dbpediaProvider.fetchEvents(queryText: query.value);
          break;
        case 'Lugares':
          result = await dbpediaProvider.fetchPlaces(queryText: query.value);
          break;
        case 'Personajes':
          result = await wikidataProvider.fetchHistoricalFigures(queryText: query.value);
          break;
        case 'Instituciones':
          result = await wikidataProvider.fetchHistoricalInstitutions(queryText: query.value);
          break;
        default:
          result = [];
      }

      resources.assignAll(result);
    } catch (e) {
      print('Error al obtener recursos: $e');
    }
  }
}
