import 'package:algolia_client_search/algolia_client_search.dart';
import 'package:travelaca/Model/LocationClass.dart';
class SearchService {
  final SearchClient client = SearchClient(
    appId: 'II0KZCI1S7',
    apiKey: 'c7098683e22377aabe4633f00fc116dd',
  );
    Future<List<Location>> performSearch(String query) async {
      try {
        final response = await client.search(
          searchMethodParams: SearchMethodParams(
            requests: [
              SearchForHits(
                indexName: "dev_locations",
                query: query,
                hitsPerPage: 10,
              ),
            ],
          ),
        );

        final resultsList = response.results;
        if (resultsList.isEmpty) {
          print("No results found in 'results'.");
          return [];
        }

        final firstResult = resultsList.first;
        final hits = firstResult['hits'] as List<dynamic>;

        print("Hits: ${hits.length}"); // Log number of hits
        return hits.map<Location>((hit) {
          return Location.fromJson(hit as Map<String, dynamic>);
        }).toList();

      } catch (e) {
        ; // Log error
        return [];
      }
    }

}
