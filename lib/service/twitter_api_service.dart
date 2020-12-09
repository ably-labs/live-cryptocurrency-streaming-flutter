import 'dart:convert';

import 'package:ably_cryptocurrency/config.dart';
import 'package:http/http.dart';
import 'package:twitter_api/twitter_api.dart';

class TwitterAPIService {
  TwitterAPIService({this.queryTag});

  final String queryTag;

  static const String path = "search/tweets.json";

  Future<List> getTweetsQuery() async {
    try {
      final _twitterOauth = new twitterApi(
        consumerKey: OAuthConsumerKey,
        consumerSecret: OAuthConsumerSercert,
        token: OAuthToken,
        tokenSecret: OAuthTokenSecret,
      );

      // Make the request to twitter
      Response response = await _twitterOauth.getTwitterRequest(
        // Http Method
        "GET",
        // Endpoint you are trying to reach
        path,
        // The options for the request
        options: {
          "q": queryTag,
        },
      );

      final decodedResponse = json.decode(response.body);

      return decodedResponse['statuses'] as List;
    } catch (error) {
      rethrow;
    }
  }
}
