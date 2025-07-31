import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/resource_model.dart';
import '../models/resource_detail_model.dart';

class WikidataProvider {
  final String endpoint = 'https://query.wikidata.org/sparql';

  Future<List<ResourceModel>> fetchHistoricalFigures(
      {String queryText = ''}) async {
    final query = '''
    SELECT DISTINCT ?personaje ?label
    WHERE {
      {
        ?personaje wdt:P19 wd:Q736 .   # Nacido en
      }
      UNION
      {
        ?personaje wdt:P27 wd:Q736 .   # Nacionalidad
      }
      ?personaje wdt:P31 wd:Q5 .
      ?personaje wdt:P106 ?ocupacion .
      ?personaje wdt:P570 ?fechaFallecimiento .

      FILTER(?ocupacion IN (
        wd:Q30461,  # Presidente
        wd:Q483501, # Artista
        wd:Q1028181,# Pintor
        wd:Q36180,  # Escritor
        wd:Q49757,  # Poeta
        wd:Q39631,  # Médico
        wd:Q901,    # Científico
        wd:Q639669, # Músico
        wd:Q33999,  # Actor
        wd:Q82955   # Político
      ))

      ?personaje rdfs:label ?label .
      FILTER(LANG(?label) = "es")

      ${queryText.isNotEmpty ? 'FILTER(CONTAINS(LCASE(?label), "${queryText.toLowerCase()}")) .' : ''}
    }
    ORDER BY ?label
    ''';

    final uri = Uri.parse(
        '$endpoint?query=${Uri.encodeQueryComponent(query)}&format=json');
    final response = await http
        .get(uri, headers: {'Accept': 'application/sparql-results+json'});

    if (response.statusCode == 200) {
      final results = json.decode(response.body)['results']['bindings'] as List;
      return results
          .map((e) => ResourceModel.fromJson(e, 'personaje'))
          .toList();
    } else {
      throw Exception('Error al consultar personajes históricos en Wikidata');
    }
  }

  Future<List<ResourceModel>> fetchHistoricalInstitutions(
      {String queryText = ''}) async {
    final query = '''
    SELECT DISTINCT ?organizacion ?label 
    WHERE {
      ?organizacion wdt:P17 wd:Q736 .
      ?organizacion wdt:P31 ?tipo .

      FILTER(?tipo IN (
        wd:Q7278,       # Partido político
        wd:Q43229,      # Organización
        wd:Q15911314,   # Asociación
        wd:Q4830453,    # Empresa
        wd:Q1530022,    # Institución educativa
        wd:Q16917,      # Hospital
        wd:Q33506,      # Museo
        wd:Q2085381,    # Editorial
        wd:Q1664720,    # Institución
        wd:Q2467461,    # Organización sin fines de lucro
        wd:Q1391145,    # Organización religiosa
        wd:Q4204501,    # Organización gubernamental
        wd:Q875538,     # Universidad
        wd:Q3918,       # Escuela
        wd:Q11315,      # Institución cultural
        wd:Q1127431,    # Fundación cultural
        wd:Q2861147     # Organización cultural
      ))

      ?organizacion rdfs:label ?label .
      FILTER(LANG(?label) = "es")

      ${queryText.isNotEmpty ? 'FILTER(CONTAINS(LCASE(?label), "${queryText.toLowerCase()}")) .' : ''}
    }
    ORDER BY ?label
    ''';

    final uri = Uri.parse(
        '$endpoint?query=${Uri.encodeQueryComponent(query)}&format=json');
    final response = await http
        .get(uri, headers: {'Accept': 'application/sparql-results+json'});

    if (response.statusCode == 200) {
      final results = json.decode(response.body)['results']['bindings'] as List;
      return results
          .map((e) => ResourceModel.fromJson(e, 'organizacion'))
          .toList();
    } else {
      throw Exception(
          'Error al consultar instituciones históricas en Wikidata');
    }
  }

  Future<List<ResourceDetail>> fetchResourceDetails(String resourceUri) async {
    // Extraer QID de la URI
    final resourceId = resourceUri.split('/').last;

    final query = '''
    SELECT DISTINCT ?propiedad ?propiedadLabel ?valor ?valorLabel
    WHERE {
      VALUES ?recurso { wd:$resourceId }

      ?recurso ?propiedadWDT ?valor .
      FILTER(STRSTARTS(STR(?propiedadWDT), "http://www.wikidata.org/prop/direct/"))

      # Permite la Consulta de Metadatos de la Propiedad
      BIND(IRI(REPLACE(STR(?propiedadWDT), "http://www.wikidata.org/prop/direct/", "http://www.wikidata.org/entity/")) AS ?propiedad)

      OPTIONAL {
        ?propiedad rdfs:label ?propiedadLabel .
        FILTER(LANG(?propiedadLabel) = "es" || LANG(?propiedadLabel) = "en")
      }

      OPTIONAL {
        ?valor rdfs:label ?valorLabel .
        FILTER(LANG(?valorLabel) = "es" || LANG(?valorLabel) = "en")
      }

      FILTER(
        (!isLiteral(?valor)) ||
        (LANG(?valor) = "es" || LANG(?valor) = "")
      )
    }
    ORDER BY ?propiedadLabel
    ''';

    final uri = Uri.parse(
        '$endpoint?query=${Uri.encodeQueryComponent(query)}&format=json');
    final response = await http
        .get(uri, headers: {'Accept': 'application/sparql-results+json'});

    if (response.statusCode == 200) {
      final results = json.decode(response.body)['results']['bindings'] as List;
      return results.map((e) => ResourceDetail.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener detalles del recurso en Wikidata');
    }
  }
}
