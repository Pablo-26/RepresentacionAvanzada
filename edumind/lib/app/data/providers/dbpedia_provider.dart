import 'dart:convert';
import 'package:edumind/app/data/models/resource_detail_model.dart';
import 'package:http/http.dart' as http;
import '../models/resource_model.dart';

class DBPediaProvider {
  final String endpoint = 'https://dbpedia.org/sparql';

  Future<List<ResourceModel>> fetchEvents({String queryText = ''}) async {
    final query = '''
      PREFIX dbo: <http://dbpedia.org/ontology/>
      PREFIX dbr: <http://dbpedia.org/resource/>
      PREFIX dct: <http://purl.org/dc/terms/>
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

      SELECT DISTINCT ?evento ?eventoLabel
      WHERE {
        {
          ?evento a dbo:MilitaryConflict .
          ?evento dbo:place dbr:Ecuador .
        }
        UNION {
          ?evento dct:subject <http://dbpedia.org/resource/Category:Battles_involving_Ecuador> .
        }
        UNION {
          ?evento dct:subject <http://dbpedia.org/resource/Category:Revolutions_in_Ecuador> .
        }
        UNION {
          ?evento dbp:partof dbr:Ecuadorian_War_of_Independence .
        }
        ?evento rdfs:label ?eventoLabel .
        FILTER(LANG(?eventoLabel) = "es") .
        ${queryText.isNotEmpty ? 'FILTER(CONTAINS(LCASE(?eventoLabel), "${queryText.toLowerCase()}")) .' : ''}
      }
      ORDER BY ASC(?eventoLabel)
    ''';

    final uri = Uri.parse(
        '$endpoint?query=${Uri.encodeQueryComponent(query)}&format=json');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final results = json.decode(response.body)['results']['bindings'] as List;
      return results.map((e) => ResourceModel.fromJson(e, 'evento')).toList();
    } else {
      throw Exception('Error al consultar DBpedia');
    }
  }

  Future<List<ResourceModel>> fetchPlaces({String queryText = ''}) async {
    final query = '''
    PREFIX dct: <http://purl.org/dc/terms/>
    PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
    PREFIX schema: <http://schema.org/>
    PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>

    SELECT DISTINCT ?provincia ?provinciaLabel
    WHERE {
      ?provincia dct:subject <http://dbpedia.org/resource/Category:Provinces_of_Ecuador> .
      ?provincia rdf:type schema:AdministrativeArea .
      ?provincia rdfs:label ?provinciaLabel .
      FILTER(LANG(?provinciaLabel) = "es") .
      ${queryText.isNotEmpty ? 'FILTER(CONTAINS(LCASE(?provinciaLabel), "${queryText.toLowerCase()}")) .' : ''}
    }
    ORDER BY ?provinciaLabel
  ''';

    final uri = Uri.parse(
        '$endpoint?query=${Uri.encodeQueryComponent(query)}&format=json');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final results = json.decode(response.body)['results']['bindings'] as List;
      return results
          .map((e) => ResourceModel.fromJson(e, 'provincia'))
          .toList();
    } else {
      throw Exception('Error al consultar provincias desde DBpedia');
    }
  }

  Future<List<ResourceDetail>> fetchResourceDetails(String resourceUri) async {
    final query = '''
    PREFIX dbo: <http://dbpedia.org/ontology/>
    PREFIX dbr: <http://dbpedia.org/resource/>
    PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

    SELECT DISTINCT ?propiedad ?propiedadLabel ?valor ?valorLabel
    WHERE {
      VALUES ?batalla { <${resourceUri}> }
      ?batalla ?propiedad ?valor .
      FILTER(!isLiteral(?valor) || lang(?valor) = "es" || lang(?valor) = "")
      FILTER(!STRSTARTS(STR(?propiedad), "http://www.w3.org/1999/02/22-rdf-syntax-ns#"))
      FILTER(!STRSTARTS(STR(?propiedad), "http://www.w3.org/2002/07/owl#"))
      FILTER(!STRSTARTS(STR(?propiedad), "http://xmlns.com/foaf/0.1/"))
      FILTER(?propiedad != <http://dbpedia.org/ontology/wikiPageWikiLink>)
      FILTER(?propiedad != <http://dbpedia.org/ontology/wikiPageExternalLink>)
      FILTER(?propiedad != <http://dbpedia.org/property/wikiPageUsesTemplate>)
      OPTIONAL { ?propiedad rdfs:label ?propiedadLabel . FILTER(LANG(?propiedadLabel) = "es") }
      OPTIONAL { ?valor rdfs:label ?valorLabel . FILTER(ISURI(?valor) && LANG(?valorLabel) = "es") }
    }
    ORDER BY ?propiedadLabel
  ''';

    final uri = Uri.parse(
        '$endpoint?query=${Uri.encodeQueryComponent(query)}&format=json');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final results = json.decode(response.body)['results']['bindings'] as List;
      return results.map((e) => ResourceDetail.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener detalles del recurso');
    }
  }
}
