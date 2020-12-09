import 'dart:convert';

import 'package:ably_cryptocurrency/config.dart';
import 'package:http/http.dart';
import 'package:twitter_api/twitter_api.dart';

class TwitterAPIService {
  TwitterAPIService({this.queryTag}) {
    _twitterApi = twitterApi(
      consumerKey: OAuthConsumerKey,
      consumerSecret: OAuthConsumerSercert,
      token: OAuthToken,
      tokenSecret: OAuthTokenSecret,
    );
  }

  twitterApi _twitterApi;
  final String queryTag;

  static const String path = "search/tweets.json";

  Future<List> getTweetsQuery() async {
    try {
      // Make the request to twitter
      Response response = await _twitterApi.getTwitterRequest(
        // Http Method
        "GET",
        // Endpoint you are trying to reach
        path,
        // The options for the request
        options: {
          "q": queryTag,
          "count": "50",
        },
      );

      final decodedResponse = json.decode(response.body);

      return decodedResponse['statuses'] as List;
    } catch (error) {
      rethrow;
    }
  }
}
