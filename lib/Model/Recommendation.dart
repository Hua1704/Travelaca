// import 'package:algoliasearch/algoliasearch.dart';
// import 'package:algolia_client_recommend/algolia_client_recommend.dart';
// void main() async {
//   // Initialize the client
//   final client = RecommendClient(
//       appId: 'II0KZCI1S7', apiKey: 'c7098683e22377aabe4633f00fc116dd');
//
//   var requests = [
//     LookingSimilarQuery(
//       model: LookingSimilarModel.fromJson("looking-similar"),
//       objectID: "3c70fdf8-9423-4e8a-aa01-5ed861268cfd",
//       indexName: 'dev_locations',
//       threshold: 50,
//       maxRecommendations: 3,
//     ),
//     LookingSimilarQuery(
//       model: LookingSimilarModel.fromJson("looking-similar"),
//       objectID: '07e9fa69-8ec2-40d6-875a-a25c42488afc',
//       indexName: 'dev_locations',
//       threshold: 50,
//       maxRecommendations: 3,
//     ),
//     LookingSimilarQuery(
//       model: LookingSimilarModel.fromJson("looking-similar"),
//       objectID: '5ba39e01-1641-4d81-8bb7-a56e2c022396',
//       indexName: 'dev_locations',
//       threshold: 50,
//       maxRecommendations: 3,
//     ),
//   ];
//   final response = await client.getRecommendations(
//     getRecommendationsParams: GetRecommendationsParams(requests: requests),
//   );
//   var results = response.results;
//   for (final result in results) {
//     print(result.hits);
//   }
//
//
// }