import 'package:algolia_client_search/algolia_client_search.dart';
import 'package:travelaca/Model/LocationClass.dart';
class SearchService {
  final SearchClient client = SearchClient(
    appId: 'II0KZCI1S7',
    apiKey: 'c7098683e22377aabe4633f00fc116dd',
  );
  Future<List<Location>> performSearch(String query) async {
    try {
      print("Starting search for query: $query");

      final response = await client.search(
        searchMethodParams: SearchMethodParams(
          requests: [
            SearchForHits(
              indexName: "sample",
              query: query,
              hitsPerPage: 50,
            ),
          ],
        ),
      );

      // Extract results and process hits
      final resultsList = response.results;
      if (resultsList.isEmpty) {
        print("No results found in 'results'.");
        return [];
      }
      final firstResult = resultsList.first; // Get the first result from the results
      final hits = firstResult['hits'] as List<dynamic>; // Extract hits as a list

      // Map hits to SearchResult objects
      return hits.map<Location>((hit) {
        return Location.fromJson(hit as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      return [];
    }
  }

}